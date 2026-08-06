-- 026_dryrun.sql
--
-- Wendet 026 in einer Transaktion an, prueft als echte Rolle nach und bricht
-- ab. "FEHLGESCHLAGEN: 0 von N" ist ein bestandener Lauf; die Ausnahme danach
-- ist der Rollback.
--
-- Test 2 und 3 sind die eigentliche Sicherheitsaussage: der Anon-Key kommt
-- nicht durch, ein angemeldeter Nutzer schon -- und zwar nur bis zur Grenze.

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


do $$
declare
  failed int := 0;
  total  int := 0;
  notes  text[] := '{}';
  nutzer uuid;
  n int;
  meldung text;
begin
  select id into nutzer from public.profiles order by created_at limit 1;

  -- 1: die Tabelle ist ueber PostgREST nicht erreichbar
  total := total + 1;
  select count(*) into n
  from information_schema.role_table_grants
  where table_schema = 'public' and table_name = 'igdb_rate_limit'
    and grantee in ('anon', 'authenticated', 'service_role');
  if n <> 0 then
    failed := failed + 1;
    notes := notes || format('1 igdb_rate_limit hat %s GRANTs', n);
  end if;

  -- 2: mit dem Anon-Key (keine uid) wird abgewiesen
  total := total + 1;
  begin
    set local role anon;
    perform set_config('request.jwt.claims',
      json_build_object('role', 'anon')::text, true);
    perform public.igdb_rate_limit_hit();
    reset role;
    failed := failed + 1;
    notes := notes || '2 anon kam durch';
  exception when others then
    reset role;
    if sqlstate not in ('28000', '42501') then
      failed := failed + 1;
      notes := notes || format('2 unerwartet %s: %s', sqlstate, sqlerrm);
    end if;
  end;

  -- 3: ein angemeldeter Nutzer kommt durch
  total := total + 1;
  begin
    set local role authenticated;
    perform set_config('request.jwt.claims',
      json_build_object('sub', nutzer::text, 'role', 'authenticated')::text, true);
    perform public.igdb_rate_limit_hit();
    reset role;
  exception when others then
    reset role;
    failed := failed + 1;
    notes := notes || format('3 angemeldeter Nutzer abgewiesen: %s', sqlerrm);
  end;

  -- 4: und die Grenze greift
  total := total + 1;
  begin
    set local role authenticated;
    perform set_config('request.jwt.claims',
      json_build_object('sub', nutzer::text, 'role', 'authenticated')::text, true);
    -- Grenze 3, und Test 3 hat schon einen Treffer gesetzt: der vierte Aufruf
    -- insgesamt muss fliegen.
    perform public.igdb_rate_limit_hit(3);
    perform public.igdb_rate_limit_hit(3);
    perform public.igdb_rate_limit_hit(3);
    reset role;
    failed := failed + 1;
    notes := notes || '4 die Grenze greift nicht';
  exception when others then
    reset role;
    if sqlstate <> '54000' then
      failed := failed + 1;
      notes := notes || format('4 falscher Fehler %s: %s', sqlstate, sqlerrm);
    end if;
  end;

  -- 5: gezaehlt wird pro Nutzer, nicht global -- sonst legt ein Missbraucher
  --    alle anderen mit lahm
  total := total + 1;
  begin
    set local role authenticated;
    perform set_config('request.jwt.claims',
      json_build_object('sub',
        (select id::text from public.profiles where id <> nutzer limit 1),
        'role', 'authenticated')::text, true);
    perform public.igdb_rate_limit_hit(3);
    reset role;
  exception when others then
    reset role;
    failed := failed + 1;
    notes := notes || format('5 zweiter Nutzer mitgesperrt: %s', sqlerrm);
  end;

  meldung := format('FEHLGESCHLAGEN: %s von %s | %s',
                    failed, total, array_to_string(notes, ' ;; '));
  raise exception '%', meldung;
end $$;

rollback;
