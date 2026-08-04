-- 022_blocked_profiles_full_row.sql
--
-- Corrects 021: blocked_profiles() returned four hand-picked columns, and
-- UserModel.fromJson parses created_at and updated_at unconditionally
-- (DateTime.parse on a null would throw at runtime, not at compile time).
--
-- Rather than widening the column list and having it drift again the next time
-- the model grows a field, the function now returns the profile row itself.
-- `setof public.profiles` means the shape follows the table, and the client
-- keeps using the same parser it uses everywhere else.
--
-- Needs DROP first: CREATE OR REPLACE cannot change a function's return type.
-- Safe here because nothing has called it yet -- 021 is minutes old and the
-- client change ships with this.

begin;

drop function if exists public.blocked_profiles();

create function public.blocked_profiles()
returns setof public.profiles
language sql
stable
security definer
set search_path = public
as $$
  select p.*
  from public.user_blocks b
  join public.profiles p on p.id = b.blocked_id
  where b.blocker_id = auth.uid()
  order by p.username;
$$;

revoke all on function public.blocked_profiles() from public;
revoke all on function public.blocked_profiles() from anon;
grant execute on function public.blocked_profiles() to authenticated;

do $$
declare
  cols int;
begin
  select count(*) into cols
  from information_schema.columns
  where table_schema = 'public' and table_name = 'profiles';

  -- If this ever fails it means the function stopped mirroring the table,
  -- which is the exact drift 022 exists to prevent.
  if cols < 20 then
    raise exception 'profiles has only % columns — check the assumption', cols;
  end if;

  if has_function_privilege('anon', 'public.blocked_profiles()', 'EXECUTE') then
    raise exception 'anon can execute blocked_profiles';
  end if;

  if not has_function_privilege(
    'authenticated', 'public.blocked_profiles()', 'EXECUTE'
  ) then
    raise exception 'authenticated cannot execute blocked_profiles';
  end if;

  raise notice 'blocked_profiles returns full profile rows';
end $$;

commit;
