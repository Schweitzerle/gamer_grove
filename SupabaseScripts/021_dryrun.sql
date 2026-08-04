-- 021_dryrun.sql
--
-- Applies 021, checks it from both sides of a block, and rolls back. The
-- closing RAISE aborts the transaction; "FEHLGESCHLAGEN: 0 von 9" is a pass.
--
-- The last three checks are the ones that matter most: the blocked party must
-- also stop seeing the blocker, must not be able to tell that from a block
-- list of their own, and must still see themselves.
--
-- Result on 2026-08-04, before 021 was applied for real: 9 von 9 gruen.

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


do $$
declare r text := ''; n int; failed int := 0;
begin
  perform set_config('role','authenticated',true);
  perform set_config('request.jwt.claims','{"sub":"c809cb14-338a-4321-86d8-3ef6acf997f3","role":"authenticated"}',true);

  select count(*) into n from profiles where id='0f47f300-4d21-473e-aa86-41157f6924c4';
  r := r || format('vor dem Block: A sieht C: %s (erwartet 1)%s', n, chr(10));
  if n <> 1 then failed := failed + 1; end if;

  select count(*) into n from search_users('play');
  r := r || format('vor dem Block: Suche findet C: %s (erwartet 1)%s', n, chr(10));
  if n <> 1 then failed := failed + 1; end if;

  perform block_user('0f47f300-4d21-473e-aa86-41157f6924c4');

  select count(*) into n from profiles where id='0f47f300-4d21-473e-aa86-41157f6924c4';
  r := r || format('nach Block: A sieht C in profiles: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  select count(*) into n from search_users('play');
  r := r || format('nach Block: Suche findet C: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  select count(*) into n from get_popular_users(50, 0, 0) where id='0f47f300-4d21-473e-aa86-41157f6924c4';
  r := r || format('nach Block: beliebte Nutzer zeigt C: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  select count(*) into n from blocked_profiles() where id='0f47f300-4d21-473e-aa86-41157f6924c4';
  r := r || format('Blockliste zeigt C trotzdem: %s (erwartet 1)%s', n, chr(10));
  if n <> 1 then failed := failed + 1; end if;

  -- Gegenrichtung: C darf A auch nicht mehr sehen
  perform set_config('request.jwt.claims','{"sub":"0f47f300-4d21-473e-aa86-41157f6924c4","role":"authenticated"}',true);

  select count(*) into n from profiles where id='c809cb14-338a-4321-86d8-3ef6acf997f3';
  r := r || format('C (der Blockierte) sieht A: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  select count(*) into n from blocked_profiles();
  r := r || format('C sieht eine Blockliste: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  select count(*) into n from profiles where id='0f47f300-4d21-473e-aa86-41157f6924c4';
  r := r || format('C sieht sich selbst weiterhin: %s (erwartet 1)%s', n, chr(10));
  if n <> 1 then failed := failed + 1; end if;

  raise exception E'
=== DRY RUN 021 (wird zurueckgerollt) ===
%FEHLGESCHLAGEN: % von 9', r, failed;
end $$;

rollback;
