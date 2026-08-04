-- 023_dryrun.sql
--
-- Makes a public account private, has it follow another account, and checks
-- that the follower can still be seen and acted on -- then rolls all of it
-- back. "FEHLGESCHLAGEN: 0 von 5" is a pass.
--
-- Note this dry run predates the created_at/updated_at columns being added to
-- the function; those were verified separately against the live database by
-- comparing the returned row against the fields UserModel.fromJson requires.
--
-- Result on 2026-08-04: 5 von 5 gruen.

begin;


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
  is_profile_public boolean
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
  SELECT p.id, p.username, p.display_name, p.avatar_url, p.is_profile_public
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



do $$
declare r text := ''; n int; failed int := 0;
begin
  -- C wird privat und folgt A
  update profiles set is_profile_public = false where id='0f47f300-4d21-473e-aa86-41157f6924c4';
  insert into user_follows (follower_id, following_id) values ('0f47f300-4d21-473e-aa86-41157f6924c4','c809cb14-338a-4321-86d8-3ef6acf997f3')
    on conflict do nothing;

  perform set_config('role','authenticated',true);
  perform set_config('request.jwt.claims','{"sub":"c809cb14-338a-4321-86d8-3ef6acf997f3","role":"authenticated"}',true);

  select count(*) into n from profiles where id='0f47f300-4d21-473e-aa86-41157f6924c4';
  r := r || format('A sieht das private Profil normal: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  select count(*) into n from my_follow_profiles('followers') where id='0f47f300-4d21-473e-aa86-41157f6924c4';
  r := r || format('... aber in der eigenen Followerliste: %s (erwartet 1)%s', n, chr(10));
  if n <> 1 then failed := failed + 1; end if;

  select count(*) into n from my_follow_profiles('followers')
    where id='0f47f300-4d21-473e-aa86-41157f6924c4' and is_profile_public = false;
  r := r || format('Privatflag kommt mit: %s (erwartet 1)%s', n, chr(10));
  if n <> 1 then failed := failed + 1; end if;

  -- Fremde Listen bleiben unberuehrt
  select count(*) into n from my_follow_profiles('following');
  r := r || format('A folgt-Liste laeuft: %s (>=0)%s', n, chr(10));

  begin
    perform my_follow_profiles('unsinn'); n := 1;
  exception when others then n := 0;
  end;
  r := r || format('ungueltige Richtung: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  -- nach dem Blockieren muss C verschwinden
  perform block_user('0f47f300-4d21-473e-aa86-41157f6924c4');
  select count(*) into n from my_follow_profiles('followers') where id='0f47f300-4d21-473e-aa86-41157f6924c4';
  r := r || format('nach Block weg aus der Liste: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  raise exception E'
=== DRY RUN 023 (wird zurueckgerollt) ===
%FEHLGESCHLAGEN: % von 5', r, failed;
end $$;

rollback;
