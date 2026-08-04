-- 023_own_follow_profiles.sql
--
-- Lets a user see the accounts on their own follow lists even when those
-- accounts are private, so a private follower can be opened, reported and
-- blocked. See #202.
--
-- THE PROBLEM
--
-- user_follows is fully readable (`Anyone can view follows`, USING (true)),
-- profiles is not: private profiles are filtered out. So a follow row comes
-- back from PostgREST with `profiles: null`, and the client's non-nullable cast
-- turns one private follower into a failure for the whole list.
--
-- WHY NOT A POLICY
--
-- The obvious fix -- a permissive profiles policy saying "I may see whoever
-- follows me" -- would also admit those profiles to the leaderboard, which
-- selects from profiles directly. Permissive policies are OR-combined; that is
-- exactly the mechanism that made RLS decorative in #6. So the extra
-- visibility is scoped to a function instead of widened in the table.
--
-- WHAT IS DELIBERATELY NOT EXPOSED
--
-- Only identity, avatar, the privacy flag and the row timestamps. No counts,
-- no ratings, no bio. Enough to render a row and to act on it -- a private
-- account that follows you is not thereby made browsable.
--
-- Scoped to auth.uid()'s OWN lists. Other people's follower lists keep showing
-- public accounts only, which is what the ordinary query already does.

begin;

-- Dropped first because the column list below changed while this migration was
-- being written: created_at and updated_at were added once it was clear the
-- client needs them to build a User entity, and inventing timestamps in Dart
-- would have been a quiet lie of exactly the kind last_active_at already tells.
drop function if exists public.my_follow_profiles(text, int, int);

create or replace function public.my_follow_profiles(
  p_direction text,
  p_limit int default 50,
  p_offset int default 0
)
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  is_profile_public boolean,
  created_at timestamptz,
  updated_at timestamptz
)
language plpgsql
stable
security definer
set search_path = public
as $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated' USING ERRCODE = '28000';
  END IF;

  IF p_direction NOT IN ('followers', 'following') THEN
    RAISE EXCEPTION 'direction must be followers or following'
      USING ERRCODE = '22023';
  END IF;

  RETURN QUERY
  SELECT p.id, p.username, p.display_name, p.avatar_url, p.is_profile_public,
         p.created_at, p.updated_at
  FROM public.user_follows f
  JOIN public.profiles p
    ON p.id = CASE WHEN p_direction = 'followers'
                   THEN f.follower_id ELSE f.following_id END
  WHERE CASE WHEN p_direction = 'followers'
             THEN f.following_id ELSE f.follower_id END = uid
    -- A blocked account is not on your lists at all: block_user dissolves the
    -- relationship, so this is belt and braces rather than a second rule.
    AND NOT public.is_blocked_with(p.id)
  ORDER BY p.username
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

revoke all on function public.my_follow_profiles(text, int, int) from public;
revoke all on function public.my_follow_profiles(text, int, int) from anon;
grant execute on function public.my_follow_profiles(text, int, int)
  to authenticated;

do $$
begin
  if has_function_privilege(
    'anon', 'public.my_follow_profiles(text, int, int)', 'EXECUTE'
  ) then
    raise exception 'anon can execute my_follow_profiles';
  end if;

  if not exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'my_follow_profiles'
      and p.prosecdef
  ) then
    raise exception 'my_follow_profiles missing or not SECURITY DEFINER';
  end if;

  raise notice 'own follow lists can see private accounts minimally';
end $$;

commit;
