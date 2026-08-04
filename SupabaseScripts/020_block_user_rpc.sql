-- 020_block_user_rpc.sql
--
-- Blocking has to dissolve the follow relationship in BOTH directions,
-- otherwise the blocked user keeps appearing in the blocker's follower list and
-- keeps seeing their activity -- a block that only half works.
--
-- The client cannot do this. 018 left user_follows with
--     DELETE USING (auth.uid() = follower_id)
-- so a user may remove their own follow but not somebody else's follow of them.
-- That policy is correct and should stay; the way around it is a function that
-- runs as owner, with the actor taken from auth.uid() and never from an
-- argument.
--
-- The two triggers on user_follows behave correctly under this:
--   update_follow_counts fires AFTER INSERT *and* AFTER DELETE, so
--     profiles.followers_count / following_count stay right.
--   log_follow_activity fires AFTER INSERT only, so blocking does not write
--     "unfollowed" noise into the activity feed.
--
-- Modelled on delete_own_account (013): pinned search_path, explicit
-- not-authenticated raise, EXECUTE revoked from PUBLIC and anon.

begin;

create or replace function public.block_user(target_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  -- user_blocks already has a CHECK against this, but failing here gives the
  -- client a clear error instead of a constraint violation.
  if uid = target_id then
    raise exception 'Cannot block yourself' using errcode = '22023';
  end if;

  if not exists (select 1 from public.profiles where id = target_id) then
    raise exception 'No such user' using errcode = '23503';
  end if;

  -- Blocking twice is not an error; the second call should be a no-op so the
  -- UI never has to care whether a block already existed.
  insert into public.user_blocks (blocker_id, blocked_id)
  values (uid, target_id)
  on conflict (blocker_id, blocked_id) do nothing;

  delete from public.user_follows
  where (follower_id = uid       and following_id = target_id)
     or (follower_id = target_id and following_id = uid);
end;
$$;

-- Functions are executable by PUBLIC unless revoked -- the same trap that let
-- is_pro_user leak whether an arbitrary id was a paying customer (014).
revoke all on function public.block_user(uuid) from public;
revoke all on function public.block_user(uuid) from anon;
grant execute on function public.block_user(uuid) to authenticated;

do $$
begin
  if not exists (
    select 1 from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'block_user' and p.prosecdef
  ) then
    raise exception 'block_user missing or not SECURITY DEFINER';
  end if;

  if has_function_privilege('anon', 'public.block_user(uuid)', 'EXECUTE') then
    raise exception 'anon can still execute block_user';
  end if;

  if not has_function_privilege('authenticated', 'public.block_user(uuid)', 'EXECUTE') then
    raise exception 'authenticated cannot execute block_user';
  end if;

  raise notice 'block_user is in place';
end $$;

commit;
