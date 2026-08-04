-- 018_fix_blanket_rls_policies.sql
--
-- Removes the blanket policies that made RLS decorative on the three tables
-- holding the app's core data, and replaces them with own-row policies.
--
-- WHAT WAS WRONG
--
-- user_games, user_top_three and user_follows each carried
--     FOR ALL TO authenticated USING (true) WITH CHECK (true)
-- twice, under two names (`authenticated_users_all_access` and
-- `enable_all_for_authenticated_users`). Postgres OR-combines PERMISSIVE
-- policies, so a single USING (true) makes every careful policy beside it
-- irrelevant -- including the three on user_games that gate on
-- profiles.is_profile_public. Private profiles were private in the UI only.
--
-- Verified against production on 2026-08-04, acting as one real authenticated
-- user against another user's rows: 17 of 17 rows of a private profile
-- readable, 1413 rows across all 9 users readable, and 17 rows deletable
-- (inside BEGIN ... ROLLBACK).
--
-- WHY DROPPING THEM ALONE WOULD BREAK THE APP
--
-- user_games has no other write policy and no own-row SELECT policy at all --
-- its three SELECT policies only cover *other people's public* rows. Drop the
-- blankets on their own and nobody can rate a game, and nobody with a private
-- profile can see their own shelf. user_top_three has own-row writes but the
-- same own-row SELECT gap. So the own-row policies below are not an
-- improvement bundled in; they are what keeps the app working.
--
-- user_follows already has own-row INSERT and DELETE and needs no UPDATE
-- (a follow is created or removed, never edited), so there the drop suffices.
--
-- NOT IN SCOPE, ON PURPOSE
--
-- `Anyone can view follows` (USING (true)) stays. It leaks the social graph of
-- private profiles and contradicts is_profile_public, but tightening it can
-- break follower lists and counts, which is a product decision rather than a
-- security fix. Tracked separately; see docs/AUDIT_2026.md Z-10.

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

commit;
