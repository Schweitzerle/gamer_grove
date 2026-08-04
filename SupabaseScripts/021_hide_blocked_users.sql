-- 021_hide_blocked_users.sql
--
-- Makes a block actually hide people, in both directions.
--
-- WHAT ALREADY WORKS WITHOUT THIS
--
-- block_user (020) dissolves the follow relationship both ways, and the
-- activity feed and the follower lists are built from user_follows -- so a
-- blocked user is already gone from those. They are not filtered here because
-- there is nothing left to filter.
--
-- WHAT DOES NOT
--
-- User search, the leaderboard and "popular users" read profiles freely. Those
-- are the surfaces where a blocked account still turns up.
--
-- TWO PATHS, BOTH NEEDED
--
-- The direct queries (leaderboard, user search) go through PostgREST and are
-- governed by RLS. get_popular_users and search_users are SECURITY DEFINER and
-- therefore **bypass RLS entirely** -- a policy alone would silently miss
-- them. Both are covered below.
--
-- WHY MUTUAL
--
-- If A blocks B, B stops seeing A as well. Anything less lets the blocked
-- party keep watching, which is the situation blocking exists to end.
--
-- WHY THE BLOCK LIST NEEDS ITS OWN FUNCTION
--
-- Once the policy hides blocked profiles, the blocked-accounts screen can no
-- longer read them either -- it would render a list of nothing. Re-admitting
-- them through a second policy would also re-admit them to search, because
-- permissive policies are OR-combined (the mistake 018 had to undo). So the
-- screen gets a SECURITY DEFINER function scoped to exactly that question
-- instead.

begin;

-- Shared predicate: is there a block between me and this profile, either way?
-- STABLE so the planner may cache it within a statement; SECURITY DEFINER
-- because user_blocks is only readable by the blocker, and this has to see
-- both directions without telling anybody which one applied.
create or replace function public.is_blocked_with(other_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.user_blocks b
    where (b.blocker_id = auth.uid() and b.blocked_id = other_id)
       or (b.blocker_id = other_id    and b.blocked_id = auth.uid())
  );
$$;

revoke all on function public.is_blocked_with(uuid) from public;
revoke all on function public.is_blocked_with(uuid) from anon;
grant execute on function public.is_blocked_with(uuid) to authenticated;

-- ------------------------------------------------------------------- RLS path

drop policy if exists "select_public_profiles" on public.profiles;

create policy "select_public_profiles"
  on public.profiles for select to authenticated
  using (is_profile_public = true and not public.is_blocked_with(id));

-- select_own_profile is untouched: a user must always see themselves, and
-- no_self_block already makes a self-block impossible.

-- --------------------------------------------------- SECURITY DEFINER path

-- Signature and return type copied verbatim from the deployed function
-- (pg_get_function_arguments / pg_get_function_result): CREATE OR REPLACE
-- refuses to change either, and guessing "varchar" where it says "text"
-- fails with a misleading "cannot change return type" error.
create or replace function public.get_popular_users(
  p_limit int default 20,
  p_offset int default 0,
  p_min_followers int default 1
)
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  bio text,
  followers_count int,
  total_games_rated int,
  average_rating numeric
)
language plpgsql
security definer
set search_path = public
as $$
BEGIN
  RETURN QUERY
  SELECT
    u.id,
    u.username,
    u.display_name,
    u.avatar_url,
    u.bio,
    u.followers_count,
    u.total_games_rated,
    u.average_rating
  FROM public.profiles u
  WHERE u.is_profile_public = true
    AND u.followers_count >= p_min_followers
    AND NOT public.is_blocked_with(u.id)
  ORDER BY
    u.followers_count DESC,
    u.total_games_rated DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

create or replace function public.search_users(
  p_query text,
  p_limit int default 20,
  p_offset int default 0
)
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  bio text,
  followers_count int,
  is_profile_public boolean
)
language plpgsql
security definer
set search_path = public
as $$
BEGIN
  RETURN QUERY
  SELECT
    u.id,
    u.username,
    u.display_name,
    u.avatar_url,
    u.bio,
    u.followers_count,
    u.is_profile_public
  FROM public.profiles u
  WHERE (
      u.username ILIKE '%' || p_query || '%' OR
      u.display_name ILIKE '%' || p_query || '%'
    )
    AND u.is_profile_public = true
    AND NOT public.is_blocked_with(u.id)
  ORDER BY
    CASE WHEN LOWER(u.username) = LOWER(p_query) THEN 0 ELSE 1 END,
    u.followers_count DESC,
    u.username ASC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

-- ------------------------------------------------------- the block list screen

create or replace function public.blocked_profiles()
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text
)
language sql
stable
security definer
set search_path = public
as $$
  select p.id, p.username, p.display_name, p.avatar_url
  from public.user_blocks b
  join public.profiles p on p.id = b.blocked_id
  where b.blocker_id = auth.uid()
  order by p.username;
$$;

revoke all on function public.blocked_profiles() from public;
revoke all on function public.blocked_profiles() from anon;
grant execute on function public.blocked_profiles() to authenticated;

-- ------------------------------------------------------------- verification

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles'
      and policyname = 'select_public_profiles'
      and qual like '%is_blocked_with%'
  ) then
    raise exception 'profiles policy does not filter blocks';
  end if;

  if has_function_privilege('anon', 'public.blocked_profiles()', 'EXECUTE') then
    raise exception 'anon can execute blocked_profiles';
  end if;

  if not exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'is_blocked_with' and p.prosecdef
  ) then
    raise exception 'is_blocked_with missing or not SECURITY DEFINER';
  end if;

  raise notice 'blocked users are hidden from search, leaderboard and popular users';
end $$;

commit;
