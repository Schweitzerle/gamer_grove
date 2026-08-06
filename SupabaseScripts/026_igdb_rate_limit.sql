-- 026_igdb_rate_limit.sql
--
-- Gibt der IGDB-Function eine Aufrufer-Identität und eine Obergrenze. Siehe
-- #161.
--
-- ------------------------------------------------------------- das Problem
--
-- Die Function verlangt einen Supabase-Key, und der Client schickt den
-- **Anon-Key**. Der ist aus dem APK auslesbar und liegt zusätzlich in der
-- öffentlichen Git-Historie. Damit ist die Function eine kostenlose IGDB-API
-- auf unseren Twitch-Zugangsdaten: kein Aufrufer, keine Grenze, und IGDB
-- erlaubt insgesamt 4 Anfragen pro Sekunde -- genug, um die App für echte
-- Nutzer lahmzulegen.
--
-- ------------------------------------------------------ warum ein RPC-Aufruf
--
-- Die Function könnte die Identität mit `auth.getUser(jwt)` prüfen und die
-- Grenze getrennt zählen. Das wären zwei Netzrunden. Ein einziger Aufruf
-- dieser Funktion mit dem JWT des Aufrufers erledigt beides:
--
--   * PostgREST prüft die Signatur, bevor die Funktion überhaupt läuft. Ein
--     erfundenes Token kommt nicht durch.
--   * `auth.uid()` ist beim Anon-Key null -- die Funktion weist ihn ab.
--   * derselbe Aufruf zählt den Treffer.
--
-- Wer also hier ohne Ausnahme durchkommt, ist ein echter, angemeldeter Nutzer
-- und liegt unter der Grenze.
--
-- --------------------------------------------------------------- die Grenze
--
-- 120 Aufrufe pro Minute und Konto. Eine Spieldetailseite löst einen Schwall
-- von rund zwanzig Abfragen aus, also muss die Grenze deutlich darüber liegen,
-- sonst trifft sie beim normalen Blättern. Nach oben begrenzt sie einen
-- einzelnen Missbraucher auf zwei Anfragen pro Sekunde statt auf beliebig
-- viele.
--
-- Feste Fenster, kein gleitendes: bei dieser Grössenordnung ist der Unterschied
-- theoretisch, und ein `date_trunc` ist nachvollziehbarer als eine
-- Ringpufferrechnung.

begin;

create table if not exists public.igdb_rate_limit (
  user_id      uuid        not null references auth.users(id) on delete cascade,
  window_start timestamptz not null,
  hits         int         not null default 0,
  primary key (user_id, window_start)
);

-- RLS an, und absichtlich keine einzige Politik: an diese Tabelle kommt nur
-- die SECURITY-DEFINER-Funktion unten. Kein GRANT für anon, authenticated oder
-- service_role -- über PostgREST ist sie nicht erreichbar, und das soll so
-- bleiben. (Ohne RLS wäre sie genau die Falle aus #163.)
alter table public.igdb_rate_limit enable row level security;

comment on table public.igdb_rate_limit is
  'Zähler pro Nutzer und Minute für die IGDB-Edge-Function. Nur über igdb_rate_limit_hit() erreichbar.';

create or replace function public.igdb_rate_limit_hit(
  p_limit int default 120
)
returns void
language plpgsql
security definer
set search_path = public
as $$
DECLARE
  uid uuid := auth.uid();
  bucket timestamptz := date_trunc('minute', now());
  n int;
BEGIN
  -- Der Anon-Key hat keine uid. Das ist die eigentliche Schranke: ab hier ist
  -- belegt, dass ein Mensch mit Konto anfragt und nicht irgendwer mit dem
  -- öffentlichen Schlüssel aus dem APK.
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated' USING ERRCODE = '28000';
  END IF;

  INSERT INTO public.igdb_rate_limit (user_id, window_start, hits)
  VALUES (uid, bucket, 1)
  ON CONFLICT (user_id, window_start)
    DO UPDATE SET hits = public.igdb_rate_limit.hits + 1
  RETURNING hits INTO n;

  IF n > p_limit THEN
    RAISE EXCEPTION 'IGDB rate limit exceeded' USING ERRCODE = '54000';
  END IF;

  -- Aufräumen im Vorbeigehen statt per Cron: alte Fenster interessieren
  -- niemanden mehr, und ein eigener Zeitplan für zwei Zeilen wäre Ballast.
  -- Nur gelegentlich, damit nicht jeder Aufruf einen DELETE mitzieht.
  IF random() < 0.01 THEN
    DELETE FROM public.igdb_rate_limit WHERE window_start < now() - interval '1 hour';
  END IF;
END;
$$;

revoke all on function public.igdb_rate_limit_hit(int) from public;
revoke all on function public.igdb_rate_limit_hit(int) from anon;
grant execute on function public.igdb_rate_limit_hit(int) to authenticated;

-- ============================================================ Nachweis

do $$
declare
  n int;
begin
  if not exists (
    select 1 from pg_class c join pg_namespace s on s.oid = c.relnamespace
    where s.nspname = 'public' and c.relname = 'igdb_rate_limit'
      and c.relrowsecurity
  ) then
    raise exception 'igdb_rate_limit ohne RLS';
  end if;

  select count(*) into n
  from information_schema.role_table_grants
  where table_schema = 'public' and table_name = 'igdb_rate_limit'
    and grantee in ('anon', 'authenticated', 'service_role');
  if n <> 0 then
    raise exception 'igdb_rate_limit ist ueber PostgREST erreichbar (% GRANTs)', n;
  end if;

  if has_function_privilege('anon', 'public.igdb_rate_limit_hit(int)', 'EXECUTE') then
    raise exception 'anon darf igdb_rate_limit_hit aufrufen';
  end if;

  if not has_function_privilege(
    'authenticated', 'public.igdb_rate_limit_hit(int)', 'EXECUTE'
  ) then
    raise exception 'authenticated darf igdb_rate_limit_hit nicht aufrufen';
  end if;

  raise notice 'IGDB-Aufrufe haben jetzt einen Absender und eine Obergrenze';
end $$;

commit;
