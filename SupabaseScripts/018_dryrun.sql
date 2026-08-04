-- 018_dryrun.sql
--
-- Runs 018 against the real database and then throws it away.
--
-- Postgres does DDL transactionally, so the migration can be applied, proven
-- against live data as real authenticated users, and rolled back without
-- anything persisting. The final RAISE is what aborts the transaction -- it is
-- the mechanism, not a failure. "FEHLGESCHLAGEN: 0 von 12" is a pass.
--
-- Do not point this at a database you would mind seeing an aborted transaction
-- in. It writes and deletes one row with game_id 999999001 as part of the
-- checks; the rollback removes it.
--
-- Result on 2026-08-04, before the migration was applied for real:
--   12 von 12 gruen, Produktion danach unveraendert (6 Blankett-Politiken noch
--   da, 218 Zeilen in user_games, keine Testzeile uebrig).

begin;


-- ---------------------------------------------------------------- user_games

drop policy if exists "authenticated_users_all_access"      on public.user_games;
drop policy if exists "enable_all_for_authenticated_users"  on public.user_games;

-- Own rows, in full. Distinct from the three public-visibility policies, which
-- deliberately expose only the flagged rows (rated / wishlisted / recommended)
-- of profiles that opted in.
create policy "Users can view own games"
  on public.user_games for select to authenticated
  using (auth.uid() = user_id);

create policy "Users can insert own games"
  on public.user_games for insert to authenticated
  with check (auth.uid() = user_id);

-- USING decides which rows may be updated, WITH CHECK what they may become.
-- Both are required: without WITH CHECK a user could hand a row to someone
-- else by rewriting user_id.
create policy "Users can update own games"
  on public.user_games for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete own games"
  on public.user_games for delete to authenticated
  using (auth.uid() = user_id);

-- ------------------------------------------------------------ user_top_three

drop policy if exists "authenticated_users_all_access"      on public.user_top_three;
drop policy if exists "enable_all_for_authenticated_users"  on public.user_top_three;

-- The existing SELECT policy only covers profiles that are public *and* have
-- show_top_three set, so without this one a private user cannot see their own
-- top three. Insert/update/delete already exist and are correct.
create policy "Users can view own top three"
  on public.user_top_three for select to authenticated
  using (auth.uid() = user_id);

-- -------------------------------------------------------------- user_follows

drop policy if exists "authenticated_users_all_access"      on public.user_follows;
drop policy if exists "enable_all_for_authenticated_users"  on public.user_follows;

-- ------------------------------------------------------------- verification
--
-- Every migration in this project ends by proving it took effect, because a
-- policy change that silently did nothing looks exactly like one that worked.

do $$
declare
  blanket_count int;
  missing       text;
begin
  select count(*) into blanket_count
  from pg_policies
  where schemaname = 'public'
    and tablename in ('user_games', 'user_top_three', 'user_follows')
    and cmd = 'ALL'
    and coalesce(qual, '') = 'true';

  if blanket_count <> 0 then
    raise exception 'still % blanket policies left', blanket_count;
  end if;

  select string_agg(needed, ', ') into missing
  from (
    values
      ('user_games',     'Users can view own games'),
      ('user_games',     'Users can insert own games'),
      ('user_games',     'Users can update own games'),
      ('user_games',     'Users can delete own games'),
      ('user_top_three', 'Users can view own top three')
  ) as want(tbl, needed)
  where not exists (
    select 1 from pg_policies p
    where p.schemaname = 'public'
      and p.tablename = want.tbl
      and p.policyname = want.needed
  );

  if missing is not null then
    raise exception 'policies missing: %', missing;
  end if;

  raise notice 'RLS policies fixed on user_games, user_top_three, user_follows';
end $$;



do $$
declare r text := ''; n int; ok boolean; failed int := 0;
  procedure_note text;
begin
  perform set_config('role','authenticated',true);

  -- ---- als A (oeffentlich, 178 eigene Zeilen)
  perform set_config('request.jwt.claims','{"sub":"c809cb14-338a-4321-86d8-3ef6acf997f3","role":"authenticated"}',true);

  select count(*) into n from user_games where user_id='c809cb14-338a-4321-86d8-3ef6acf997f3';
  r := r || format('A sieht eigene Zeilen: %s (erwartet 178)%s', n, chr(10));
  if n <> 178 then failed := failed + 1; end if;

  select count(*) into n from user_games where user_id='e661b5e3-2120-4ba6-af56-40c4f4eeeb91';
  r := r || format('A sieht Zeilen des PRIVATEN B: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  select count(*) into n from user_top_three where user_id='e661b5e3-2120-4ba6-af56-40c4f4eeeb91';
  r := r || format('A sieht Top3 des PRIVATEN B: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  begin
    delete from user_games where user_id='e661b5e3-2120-4ba6-af56-40c4f4eeeb91';
    get diagnostics n = row_count;
  exception when insufficient_privilege then n := -1;
  end;
  r := r || format('A loescht Zeilen von B: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  begin
    update user_games set rating = 1 where user_id='e661b5e3-2120-4ba6-af56-40c4f4eeeb91';
    get diagnostics n = row_count;
  exception when insufficient_privilege then n := -1;
  end;
  r := r || format('A aendert Zeilen von B: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  -- eigene Schreibrechte muessen erhalten bleiben
  begin
    insert into user_games (user_id, game_id, is_wishlisted, wishlisted_at)
    values ('c809cb14-338a-4321-86d8-3ef6acf997f3', 999999001, true, now());
    n := 1;
  exception when others then n := 0; procedure_note := SQLERRM;
  end;
  r := r || format('A legt eigene Zeile an: %s (erwartet 1) %s%s', n, coalesce(procedure_note,''), chr(10));
  if n <> 1 then failed := failed + 1; end if;

  begin
    update user_games set is_recommended = true, recommended_at = now() where user_id='c809cb14-338a-4321-86d8-3ef6acf997f3' and game_id = 999999001;
    get diagnostics n = row_count;
  exception when others then n := -1;
  end;
  r := r || format('A aendert eigene Zeile: %s (erwartet 1)%s', n, chr(10));
  if n <> 1 then failed := failed + 1; end if;

  begin
    delete from user_games where user_id='c809cb14-338a-4321-86d8-3ef6acf997f3' and game_id = 999999001;
    get diagnostics n = row_count;
  exception when others then n := -1;
  end;
  r := r || format('A loescht eigene Zeile: %s (erwartet 1)%s', n, chr(10));
  if n <> 1 then failed := failed + 1; end if;

  -- Fremdzuweisung muss scheitern (WITH CHECK)
  begin
    insert into user_games (user_id, game_id, is_wishlisted, wishlisted_at)
    values ('e661b5e3-2120-4ba6-af56-40c4f4eeeb91', 999999002, true, now());
    n := 1;
  exception when insufficient_privilege then n := 0; when others then n := 0;
  end;
  r := r || format('A legt Zeile FUER B an: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  -- ---- als B (privat) muss B sein eigenes Zeug sehen
  perform set_config('request.jwt.claims','{"sub":"e661b5e3-2120-4ba6-af56-40c4f4eeeb91","role":"authenticated"}',true);

  select count(*) into n from user_games where user_id='e661b5e3-2120-4ba6-af56-40c4f4eeeb91';
  r := r || format('B (privat) sieht eigene Zeilen: %s (erwartet 17)%s', n, chr(10));
  if n <> 17 then failed := failed + 1; end if;

  select count(*) into n from user_top_three where user_id='e661b5e3-2120-4ba6-af56-40c4f4eeeb91';
  r := r || format('B (privat) sieht eigene Top3: %s (erwartet 1)%s', n, chr(10));
  if n <> 1 then failed := failed + 1; end if;

  -- oeffentliche Sichtbarkeit muss erhalten bleiben
  select count(*) into n from user_games where user_id='c809cb14-338a-4321-86d8-3ef6acf997f3' and is_rated;
  r := r || format('B sieht oeffentliche Bewertungen von A: %s (erwartet 153)%s', n, chr(10));
  if n <> 153 then failed := failed + 1; end if;

  raise exception E'
=== DRY RUN (wird zurueckgerollt) ===
%FEHLGESCHLAGEN: % von 12', r, failed;
end $$;

rollback;
