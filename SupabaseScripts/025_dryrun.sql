-- 025_dryrun.sql
--
-- Wendet 025 in einer Transaktion an, prueft als echte Rolle nach und bricht
-- ab. Das abschliessende `raise` IST der Rollback: "FEHLGESCHLAGEN: 0 von N"
-- ist ein bestandener Lauf.
--
-- Der interessanteste Test ist Nummer 4: dieselbe TRUNCATE-Anweisung, die vor
-- der Migration durchlief, muss danach abgewiesen werden.

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


do $$
declare
  failed int := 0;
  total  int := 0;
  notes  text[] := '{}';
  n      int;
  meldung text;
begin
  -- 1: die doppelte Tabelle ist weg
  total := total + 1;
  if exists (
    select 1 from pg_class c join pg_namespace s on s.oid = c.relnamespace
    where s.nspname = 'public' and c.relname = 'user_search_history'
  ) then
    failed := failed + 1;
    notes := notes || '1 user_search_history noch da';
  end if;

  -- 2: die verbleibende steht samt RLS
  total := total + 1;
  if not exists (
    select 1 from pg_class c join pg_namespace s on s.oid = c.relnamespace
    where s.nspname = 'public' and c.relname = 'user_search_queries'
      and c.relrowsecurity
  ) then
    failed := failed + 1;
    notes := notes || '2 user_search_queries fehlt oder ohne RLS';
  end if;

  -- 3: keine ueberzaehligen Rechte mehr
  total := total + 1;
  select count(*) into n
  from information_schema.role_table_grants
  where table_schema = 'public' and grantee = 'authenticated'
    and privilege_type in ('TRUNCATE', 'TRIGGER', 'REFERENCES');
  if n <> 0 then
    failed := failed + 1;
    notes := notes || format('3 noch %s ueberzaehlige Rechte', n);
  end if;

  -- 4: und das Recht ist wirklich weg, nicht nur im Katalog
  total := total + 1;
  begin
    set local role authenticated;
    perform set_config('request.jwt.claims',
      json_build_object('sub', gen_random_uuid()::text,
                        'role', 'authenticated')::text, true);
    truncate public.user_games;
    reset role;
    failed := failed + 1;
    notes := notes || '4 TRUNCATE lief immer noch durch';
  exception
    when insufficient_privilege then reset role;
    when others then
      reset role;
      failed := failed + 1;
      notes := notes || format('4 unerwartet: %s', sqlerrm);
  end;

  -- 5: was die App braucht, ist geblieben
  total := total + 1;
  select count(*) into n
  from information_schema.role_table_grants
  where table_schema = 'public' and grantee = 'authenticated'
    and table_name = 'user_games'
    and privilege_type in ('SELECT', 'INSERT', 'UPDATE', 'DELETE');
  if n <> 4 then
    failed := failed + 1;
    notes := notes || format('5 user_games: nur %s von 4 noetigen Rechten', n);
  end if;

  -- 6: und die Zeilen stehen noch (Test 4 darf nichts angerichtet haben)
  total := total + 1;
  select count(*) into n from public.user_games;
  if n = 0 then
    failed := failed + 1;
    notes := notes || '6 user_games ist leer -- der Test hat Daten geloescht';
  end if;

  meldung := format('FEHLGESCHLAGEN: %s von %s | %s',
                    failed, total, array_to_string(notes, ' ;; '));
  raise exception '%', meldung;
end $$;

rollback;
