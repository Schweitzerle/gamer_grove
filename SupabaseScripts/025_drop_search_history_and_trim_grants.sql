-- 025_drop_search_history_and_trim_grants.sql
--
-- Zwei Aufräumarbeiten, die 024 offen gelassen hat.
--
-- 1. Von zwei Tabellen für dieselbe Sache bleibt eine.
-- 2. `authenticated` durfte Tabellen leeren und Trigger anlegen.
--
-- ------------------------------------------------- user_search_history fällt
--
-- Es gab `user_search_history` und `user_search_queries`, beide leer, beide
-- ohne GRANT, beide für "zuletzt gesucht". Behalten wird die, an der etwas
-- hängt:
--
--   user_search_queries    Fremdschlüssel auf profiles, RLS mit drei
--                          Eigenzeilen-Politiken, und cleanup_old_activity()
--                          räumt sie nach drei Monaten auf
--   user_search_history    nichts davon, im Client nirgends genannt
--
-- 024 hat auf user_search_history noch RLS gelegt. Das war richtig, solange
-- offen war, welche bleibt -- eine Tabelle ohne RLS ist eine Falle, auch eine
-- leere. Jetzt ist es entschieden, und die Falle wird nicht abgesichert,
-- sondern entfernt.
--
-- Die Tabelle ist nachweislich leer (0 Zeilen am 2026-08-06) und über
-- PostgREST nie erreichbar gewesen; es geht kein Nutzerdatum verloren.

begin;

drop table if exists public.user_search_history;

-- --------------------------------------------------------- zu viele Rechte
--
-- Aus einem frühen `grant all on all tables in schema public to authenticated`
-- trägt die Rolle bis heute TRUNCATE, TRIGGER und REFERENCES auf fünf
-- Tabellen. PostgREST braucht davon nichts -- vier Rechte reichen für alles,
-- was die App tut.
--
-- Bemerkenswert ist TRUNCATE: es umgeht RLS vollständig. Eine Zeilenpolitik
-- entscheidet über Zeilen, und TRUNCATE fragt keine einzige. Ausprobiert,
-- bevor das hier stand -- als `authenticated` mit gesetztem
-- request.jwt.claims lief `truncate public.user_games` durch und nahm alle
-- 201 Zeilen mit (in einer Transaktion, zurückgerollt). Die sorgfältig
-- gebauten Eigenzeilen-Politiken aus 018 hätten das nicht aufgehalten.
--
-- Nicht übertreiben: PostgREST bildet HTTP-Verben auf SELECT/INSERT/UPDATE/
-- DELETE und RPCs ab, es gibt keinen Weg, darüber ein TRUNCATE abzusetzen,
-- und keine SECURITY-INVOKER-Funktion, die eines enthielte. Das Recht ist
-- also falsch, aber über die öffentliche Schnittstelle heute nicht erreichbar
-- -- so wie die drei Tabellen ohne RLS in #163 nicht erreichbar waren. Der
-- Grund, es trotzdem wegzunehmen, ist derselbe: die nächste Funktion, die es
-- erreichbar macht, ist nicht vorhersehbar.

revoke truncate, trigger, references on public.profiles       from authenticated;
revoke truncate, trigger, references on public.user_games     from authenticated;
revoke truncate, trigger, references on public.user_top_three from authenticated;
revoke truncate, trigger, references on public.user_activity  from authenticated;
revoke truncate, trigger, references on public.user_follows   from authenticated;

-- ============================================================ Nachweis

do $$
declare
  n int;
begin
  if exists (
    select 1 from pg_class c join pg_namespace s on s.oid = c.relnamespace
    where s.nspname = 'public' and c.relname = 'user_search_history'
  ) then
    raise exception 'user_search_history ist noch da';
  end if;

  if not exists (
    select 1 from pg_class c join pg_namespace s on s.oid = c.relnamespace
    where s.nspname = 'public' and c.relname = 'user_search_queries'
      and c.relrowsecurity
  ) then
    raise exception 'user_search_queries fehlt oder hat kein RLS';
  end if;

  select count(*) into n
  from information_schema.role_table_grants
  where table_schema = 'public'
    and grantee = 'authenticated'
    and privilege_type in ('TRUNCATE', 'TRIGGER', 'REFERENCES');
  if n <> 0 then
    raise exception 'authenticated hat noch % ueberzaehlige Rechte', n;
  end if;

  -- Was die App wirklich braucht, muss geblieben sein.
  select count(*) into n
  from information_schema.role_table_grants
  where table_schema = 'public'
    and grantee = 'authenticated'
    and table_name = 'user_games'
    and privilege_type in ('SELECT', 'INSERT', 'UPDATE', 'DELETE');
  if n <> 4 then
    raise exception 'user_games: authenticated hat nur % der vier noetigen Rechte', n;
  end if;

  raise notice 'eine Suchtabelle statt zwei; authenticated kann nicht mehr leeren';
end $$;

commit;
