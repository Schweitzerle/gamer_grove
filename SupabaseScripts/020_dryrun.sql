-- 020_dryrun.sql
--
-- Applies 020, exercises block_user as a real authenticated user, and rolls it
-- back. The closing RAISE is what aborts the transaction; "FEHLGESCHLAGEN: 0
-- von 7" is a pass.
--
-- The followers_count check is the one that would catch a rewrite of the
-- function into something that deletes follows without letting the triggers
-- see it -- the counter on profiles is maintained by AFTER DELETE, so a
-- "clever" bulk path would silently desynchronise it.
--
-- Result on 2026-08-04, before 020 was applied for real: 7 von 7 gruen,
-- followers_count 2 -> 1.

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



do $$
declare r text := ''; n int; failed int := 0; fc_before int; fc_after int;
begin
  -- Ausgangslage: A folgt C und C folgt A
  insert into user_follows (follower_id, following_id) values ('c809cb14-338a-4321-86d8-3ef6acf997f3','0f47f300-4d21-473e-aa86-41157f6924c4') on conflict do nothing;
  insert into user_follows (follower_id, following_id) values ('0f47f300-4d21-473e-aa86-41157f6924c4','c809cb14-338a-4321-86d8-3ef6acf997f3') on conflict do nothing;
  select followers_count into fc_before from profiles where id='c809cb14-338a-4321-86d8-3ef6acf997f3';

  perform set_config('role','authenticated',true);
  perform set_config('request.jwt.claims','{"sub":"c809cb14-338a-4321-86d8-3ef6acf997f3","role":"authenticated"}',true);

  perform block_user('0f47f300-4d21-473e-aa86-41157f6924c4');
  r := r || 'A blockiert C via RPC: ok' || chr(10);

  select count(*) into n from user_blocks where blocker_id='c809cb14-338a-4321-86d8-3ef6acf997f3' and blocked_id='0f47f300-4d21-473e-aa86-41157f6924c4';
  r := r || format('Block angelegt: %s (erwartet 1)%s', n, chr(10));
  if n <> 1 then failed := failed + 1; end if;

  perform block_user('0f47f300-4d21-473e-aa86-41157f6924c4');
  select count(*) into n from user_blocks where blocker_id='c809cb14-338a-4321-86d8-3ef6acf997f3' and blocked_id='0f47f300-4d21-473e-aa86-41157f6924c4';
  r := r || format('Zweiter Aufruf idempotent: %s (erwartet 1)%s', n, chr(10));
  if n <> 1 then failed := failed + 1; end if;

  perform set_config('role','none',true); reset role;
  select count(*) into n from user_follows
    where (follower_id='c809cb14-338a-4321-86d8-3ef6acf997f3' and following_id='0f47f300-4d21-473e-aa86-41157f6924c4') or (follower_id='0f47f300-4d21-473e-aa86-41157f6924c4' and following_id='c809cb14-338a-4321-86d8-3ef6acf997f3');
  r := r || format('Folgebeziehungen beide weg: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  select followers_count into fc_after from profiles where id='c809cb14-338a-4321-86d8-3ef6acf997f3';
  r := r || format('followers_count von A: %s -> %s (Trigger muss zaehlen)%s', fc_before, fc_after, chr(10));
  if fc_after >= fc_before then failed := failed + 1; end if;

  select count(*) into n from user_activity where activity_type='followed_user'
    and created_at > now() - interval '5 seconds' and user_id='0f47f300-4d21-473e-aa86-41157f6924c4';
  r := r || format('Blockieren erzeugt keine neue Feed-Notiz: %s (erwartet 0)%s', n, chr(10));

  -- Selbstblockade
  perform set_config('role','authenticated',true);
  perform set_config('request.jwt.claims','{"sub":"c809cb14-338a-4321-86d8-3ef6acf997f3","role":"authenticated"}',true);
  begin
    perform block_user('c809cb14-338a-4321-86d8-3ef6acf997f3'); n := 1;
  exception when others then n := 0;
  end;
  r := r || format('A blockiert sich selbst: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  begin
    perform block_user('00000000-0000-0000-0000-000000000000'); n := 1;
  exception when others then n := 0;
  end;
  r := r || format('Block auf unbekannte id: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  raise exception E'
=== DRY RUN 020 (wird zurueckgerollt) ===
%FEHLGESCHLAGEN: % von 7', r, failed;
end $$;

rollback;
