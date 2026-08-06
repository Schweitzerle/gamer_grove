-- 024_search_history_rls_and_avatar_bucket.sql
--
-- Two things, found while working through #163.
--
-- 1. user_search_history is the last table in public without RLS.
-- 2. The avatars bucket accepted uploads from ANYONE. That one is live and
--    exploitable, and it is the reason this migration is not just about (1).
--
-- ---------------------------------------------------------------- THE HOLE
--
-- storage.objects carried this:
--
--     "Anyone can upload an avatar"  INSERT  to public
--     WITH CHECK (bucket_id = 'avatars')
--
-- `public` includes `anon`. No owner check, no size limit on the bucket
-- (file_size_limit was null), no mime restriction (allowed_mime_types was
-- null), and the bucket is world-readable. So: anyone holding the anon key --
-- which sits in this repository's git history -- could upload a file of any
-- type and any size under any path and have it served publicly.
--
-- Proven, not deduced. On 2026-08-06 a plain text file was uploaded with the
-- anon key and no session (HTTP 200), read back over the public URL, and
-- removed again with the service role.
--
-- The correct policy for authenticated users existed the whole time. It did
-- not help: permissive policies are OR-combined, so the blanket one decided
-- every case. That is the same mechanism as #6, in the storage schema.
--
-- ------------------------------------------------------- WHY BOTH PREFIXES
--
-- The app uploads to `/{uid}/avatar.ext` -- with a leading slash
-- (edit_profile_page.dart). storage.foldername('/abc/x.jpg') returns
-- {'', 'abc'}, so element [1] is the empty string, not the user id. Objects in
-- the table are stored without the slash, so something normalises it, but
-- whether that happens before or after the RLS check is not observable from
-- outside.
--
-- Rather than find out the hard way -- avatar upload silently breaking for
-- every user the moment the blanket policy goes -- the owner check accepts the
-- id in either position. #167 should straighten the client path out; until it
-- does, this policy holds either way.

begin;

-- ============================================================ user_search_history
--
-- Empty, unreachable (no grants for anon/authenticated/service_role) and
-- unreferenced in the client -- there is a second table, user_search_queries,
-- for the same feature, which does have RLS. Harmless today; the trap is that
-- the first GRANT would open it. RLS goes on first so it cannot.
--
-- Which of the two tables survives is not decided here: dropping a table in
-- production is the user's call, not a side effect of a security fix.

alter table public.user_search_history enable row level security;

drop policy if exists "Users can view own search history"
  on public.user_search_history;
create policy "Users can view own search history"
  on public.user_search_history for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own search history"
  on public.user_search_history;
create policy "Users can insert own search history"
  on public.user_search_history for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Users can delete own search history"
  on public.user_search_history;
create policy "Users can delete own search history"
  on public.user_search_history for delete to authenticated
  using (auth.uid() = user_id);

-- No UPDATE policy: a search history entry is a fact about the past. Nothing
-- in it is meaningfully editable, and an absent policy denies by default.

-- ================================================================== avatars
--
-- Nine policies had accumulated for four operations -- three for INSERT alone,
-- two of them correct and one blanket. Duplicates are how a wrong one hides.
-- They are replaced by exactly one policy per operation.

drop policy if exists "Anyone can upload an avatar"                    on storage.objects;
drop policy if exists "Authenticated users can upload their own avatar" on storage.objects;
drop policy if exists "Users can upload own avatar"                     on storage.objects;
drop policy if exists "Authenticated users can update their own avatar" on storage.objects;
drop policy if exists "Users can update own avatar"                     on storage.objects;
drop policy if exists "Authenticated users can delete their own avatar" on storage.objects;
drop policy if exists "Users can delete own avatar"                     on storage.objects;
drop policy if exists "Avatar images are publicly accessible"           on storage.objects;
drop policy if exists "Public read access for avatars"                  on storage.objects;

-- Avatars are shown next to every rating and on every profile, to signed-out
-- readers as well. Public read is the intent, not an oversight.
create policy "Avatars are publicly readable"
  on storage.objects for select to public
  using (bucket_id = 'avatars');

create policy "Users write their own avatar"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and coalesce(
      nullif((storage.foldername(name))[1], ''),
      (storage.foldername(name))[2]
    ) = auth.uid()::text
  );

create policy "Users replace their own avatar"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'avatars'
    and coalesce(
      nullif((storage.foldername(name))[1], ''),
      (storage.foldername(name))[2]
    ) = auth.uid()::text
  );

create policy "Users remove their own avatar"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'avatars'
    and coalesce(
      nullif((storage.foldername(name))[1], ''),
      (storage.foldername(name))[2]
    ) = auth.uid()::text
  );

-- A policy says who may write. It does not say how much. Without a limit the
-- bucket is an open-ended bill: one authenticated account could fill it.
-- 5 MB matches the check the data source already makes client-side
-- (_maxAvatarSize); the difference is that this one cannot be skipped, which
-- is exactly what the second upload path does today (#167).
update storage.buckets
set file_size_limit = 5 * 1024 * 1024,
    allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp']
where id = 'avatars';

-- ============================================================ verification

do $$
declare
  n int;
begin
  if not exists (
    select 1 from pg_class c join pg_namespace s on s.oid = c.relnamespace
    where s.nspname = 'public' and c.relname = 'user_search_history'
      and c.relrowsecurity
  ) then
    raise exception 'user_search_history still has RLS off';
  end if;

  select count(*) into n from pg_policies
  where schemaname = 'public' and tablename = 'user_search_history';
  if n <> 3 then
    raise exception 'expected 3 policies on user_search_history, found %', n;
  end if;

  -- The point of the whole migration: no policy on the avatars bucket may let
  -- a write through without tying it to the writer.
  if exists (
    select 1 from pg_policies
    where schemaname = 'storage' and cmd in ('INSERT', 'UPDATE', 'DELETE')
      and coalesce(with_check, qual) like '%avatars%'
      and coalesce(with_check, qual) not like '%auth.uid()%'
  ) then
    raise exception 'a write policy on avatars still has no owner check';
  end if;

  select count(*) into n from pg_policies where schemaname = 'storage';
  if n <> 4 then
    raise exception 'expected 4 storage policies, found %', n;
  end if;

  if not exists (
    select 1 from storage.buckets
    where id = 'avatars' and file_size_limit = 5 * 1024 * 1024
      and allowed_mime_types is not null
  ) then
    raise exception 'avatars bucket has no size or mime limit';
  end if;

  raise notice 'search history is closed; the avatars bucket no longer takes anonymous uploads';
end $$;

commit;
