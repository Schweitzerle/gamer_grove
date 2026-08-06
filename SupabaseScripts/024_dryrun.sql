-- 024_dryrun.sql
--
-- Applies 024 inside a transaction, asserts against it as real roles, then
-- aborts. The RAISE at the end IS the rollback -- "FEHLGESCHLAGEN: 0 von N" is
-- a pass, and the exception that follows is the migration being undone.
--
-- What this harness cannot do is the part that matters most: a storage upload
-- goes through the Storage API, not through SQL, so "does anon still get a
-- 200" has to be asked of the live endpoint after applying. That check is in
-- the PR, not here.

begin;

\set ON_ERROR_STOP on

-- ---------------------------------------------------------- the migration

alter table public.user_search_history enable row level security;

drop policy if exists "Users can view own search history" on public.user_search_history;
create policy "Users can view own search history"
  on public.user_search_history for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own search history" on public.user_search_history;
create policy "Users can insert own search history"
  on public.user_search_history for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Users can delete own search history" on public.user_search_history;
create policy "Users can delete own search history"
  on public.user_search_history for delete to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Anyone can upload an avatar"                     on storage.objects;
drop policy if exists "Authenticated users can upload their own avatar" on storage.objects;
drop policy if exists "Users can upload own avatar"                     on storage.objects;
drop policy if exists "Authenticated users can update their own avatar" on storage.objects;
drop policy if exists "Users can update own avatar"                     on storage.objects;
drop policy if exists "Authenticated users can delete their own avatar" on storage.objects;
drop policy if exists "Users can delete own avatar"                     on storage.objects;
drop policy if exists "Avatar images are publicly accessible"           on storage.objects;
drop policy if exists "Public read access for avatars"                  on storage.objects;

create policy "Avatars are publicly readable"
  on storage.objects for select to public
  using (bucket_id = 'avatars');

create policy "Users write their own avatar"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and coalesce(nullif((storage.foldername(name))[1], ''),
                 (storage.foldername(name))[2]) = auth.uid()::text
  );

create policy "Users replace their own avatar"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'avatars'
    and coalesce(nullif((storage.foldername(name))[1], ''),
                 (storage.foldername(name))[2]) = auth.uid()::text
  );

create policy "Users remove their own avatar"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'avatars'
    and coalesce(nullif((storage.foldername(name))[1], ''),
                 (storage.foldername(name))[2]) = auth.uid()::text
  );

update storage.buckets
set file_size_limit = 5 * 1024 * 1024,
    allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp']
where id = 'avatars';

-- ------------------------------------------------------------- assertions
--
-- The table has no GRANT for `authenticated` -- that is what keeps it closed
-- today, and the migration deliberately does not add one. But a GRANT is
-- exactly what a future feature would add, and the whole point of #163 is that
-- RLS has to be in place BEFORE that happens. So the harness grants inside the
-- transaction and checks that the policies then hold. The rollback takes the
-- grant with it.

grant select, insert, delete on public.user_search_history to authenticated;

do $$
declare
  failed int := 0;
  total  int := 0;
  notes  text[] := '{}';
  victim uuid;
  other  uuid;
  n      int;

  procedure_note text;
begin
  select id into victim from public.profiles order by created_at limit 1;
  select id into other  from public.profiles where id <> victim limit 1;

  -- 1: RLS is on
  total := total + 1;
  if not exists (
    select 1 from pg_class c join pg_namespace s on s.oid = c.relnamespace
    where s.nspname = 'public' and c.relname = 'user_search_history'
      and c.relrowsecurity
  ) then
    failed := failed + 1;
    notes := notes || format('1 user_search_history: RLS still off');
  end if;

  -- 2: a user sees only their own history rows
  total := total + 1;
  begin
    insert into public.user_search_history (id, user_id, query)
    values (gen_random_uuid(), victim, 'meine suche'),
           (gen_random_uuid(), other,  'fremde suche');

    set local role authenticated;
    perform set_config('request.jwt.claims',
      json_build_object('sub', victim::text, 'role', 'authenticated')::text, true);

    select count(*) into n from public.user_search_history;
    reset role;

    if n <> 1 then
      failed := failed + 1;
      notes := notes || format('2 user_search_history: sees %s rows, expected 1', n);
    end if;
  exception when others then
    reset role;
    failed := failed + 1;
    notes := notes || format('2 user_search_history: %s', sqlerrm);
  end;

  -- 3: writing a row under somebody else's id is refused
  total := total + 1;
  begin
    set local role authenticated;
    perform set_config('request.jwt.claims',
      json_build_object('sub', victim::text, 'role', 'authenticated')::text, true);

    insert into public.user_search_history (id, user_id, query)
    values (gen_random_uuid(), other, 'untergeschoben');

    reset role;
    failed := failed + 1;
    notes := notes || format('3 user_search_history: foreign row accepted');
  exception
    when insufficient_privilege then reset role;
    when others then
      reset role;
      failed := failed + 1;
      notes := notes || format('3 user_search_history: unexpected %s', sqlerrm);
  end;

  -- 4: no write policy on avatars without an owner check
  total := total + 1;
  if exists (
    select 1 from pg_policies
    where schemaname = 'storage' and cmd in ('INSERT', 'UPDATE', 'DELETE')
      and coalesce(with_check, qual) like '%avatars%'
      and coalesce(with_check, qual) not like '%auth.uid()%'
  ) then
    failed := failed + 1;
    notes := notes || format('4 avatars: a write policy still has no owner check');
  end if;

  -- 5: one policy per operation, not nine
  total := total + 1;
  select count(*) into n from pg_policies where schemaname = 'storage';
  if n <> 4 then
    failed := failed + 1;
    notes := notes || format('5 avatars: %s policies, expected 4', n);
  end if;

  -- 6: the owner check accepts the path shape the app actually sends
  --    (leading slash) as well as the plain one
  total := total + 1;
  if coalesce(nullif((storage.foldername('/' || victim::text || '/avatar.jpg'))[1], ''),
              (storage.foldername('/' || victim::text || '/avatar.jpg'))[2])
     is distinct from victim::text
  then
    failed := failed + 1;
    notes := notes || format('6 avatars: leading-slash path does not resolve to the owner');
  end if;

  total := total + 1;
  if coalesce(nullif((storage.foldername(victim::text || '/avatar.jpg'))[1], ''),
              (storage.foldername(victim::text || '/avatar.jpg'))[2])
     is distinct from victim::text
  then
    failed := failed + 1;
    notes := notes || format('7 avatars: plain path does not resolve to the owner');
  end if;

  -- 8: a path belonging to someone else must NOT resolve to the actor
  total := total + 1;
  if coalesce(nullif((storage.foldername(other::text || '/avatar.jpg'))[1], ''),
              (storage.foldername(other::text || '/avatar.jpg'))[2])
     = victim::text
  then
    failed := failed + 1;
    notes := notes || format('8 avatars: a foreign path resolves to the actor');
  end if;

  -- 9a: the migration itself must not hand out a GRANT
  total := total + 1;
  if exists (
    select 1 from information_schema.role_table_grants
    where table_schema = 'public' and table_name = 'user_search_history'
      and grantee in ('anon', 'service_role')
  ) then
    failed := failed + 1;
    notes := notes || format('9a user_search_history: unexpected grant');
  end if;

  -- 9: the bucket has a size and a mime limit
  total := total + 1;
  if not exists (
    select 1 from storage.buckets
    where id = 'avatars'
      and file_size_limit = 5 * 1024 * 1024
      and allowed_mime_types @> array['image/jpeg']
  ) then
    failed := failed + 1;
    notes := notes || format('9 avatars: bucket limits not set');
  end if;

  procedure_note := format('FEHLGESCHLAGEN: %s von %s | %s', failed, total, array_to_string(notes, ' ;; '));
  raise exception '%', procedure_note;
end $$;

rollback;
