-- 019_blocks_and_reports.sql
--
-- Makes user_blocks and user_reports actually usable. Google Play requires
-- in-app reporting and blocking for apps with social features and user
-- generated content; GamerGrove has public profiles, follows, an activity feed,
-- a leaderboard and user search, so the requirement applies.
--
-- WHAT WAS THERE
--
-- Both tables exist and are well designed -- CHECK constraints against
-- self-blocking and self-reporting, a reason enum, a status enum, a unique
-- (blocker_id, blocked_id), and sensible indexes. What they did not have:
--
--   * RLS disabled, zero policies
--   * no GRANTs at all, so they are unreachable through PostgREST
--   * no foreign keys, so PostgREST cannot embed profiles and a row could
--     outlive the account it points at
--   * delete_own_account never touched them
--
-- Nothing has ever been written to either table (0 rows on 2026-08-04), which
-- is consistent with the repository methods for blocking and reporting never
-- having been reachable from the UI.
--
-- The foreign keys follow the pattern every other table here uses: reference
-- profiles(id) ON DELETE CASCADE, and profiles in turn cascades from
-- auth.users. That is also what lets the client embed
-- `profiles!user_blocks_blocked_id_fkey(*)` -- PostgREST derives embedding from
-- the foreign key, so without it the join fails no matter how the query reads.

begin;

-- ------------------------------------------------------- referential integrity

alter table public.user_blocks
  add constraint user_blocks_blocker_id_fkey
    foreign key (blocker_id) references public.profiles(id) on delete cascade,
  add constraint user_blocks_blocked_id_fkey
    foreign key (blocked_id) references public.profiles(id) on delete cascade;

-- A report outlives neither party. Moderation happens while both accounts
-- exist; keeping a dangling report after a deletion would preserve personal
-- data about a deleted user for no purpose (Art. 17).
alter table public.user_reports
  add constraint user_reports_reporter_id_fkey
    foreign key (reporter_id) references public.profiles(id) on delete cascade,
  add constraint user_reports_reported_id_fkey
    foreign key (reported_id) references public.profiles(id) on delete cascade;

-- ------------------------------------------------------------------- user_blocks

alter table public.user_blocks enable row level security;

-- A block is private to the blocker. The blocked user must not be able to see
-- that they were blocked -- that turns a safety feature into a notification.
create policy "Users can view own blocks"
  on public.user_blocks for select to authenticated
  using (auth.uid() = blocker_id);

create policy "Users can block others"
  on public.user_blocks for insert to authenticated
  with check (auth.uid() = blocker_id);

create policy "Users can unblock others"
  on public.user_blocks for delete to authenticated
  using (auth.uid() = blocker_id);

-- No UPDATE policy: a block is created or removed, never edited.

grant select, insert, delete on public.user_blocks to authenticated;

-- ------------------------------------------------------------------ user_reports

alter table public.user_reports enable row level security;

-- Reporters see their own reports, so the UI can say "already reported"
-- instead of silently accepting a duplicate.
create policy "Users can view own reports"
  on public.user_reports for select to authenticated
  using (auth.uid() = reporter_id);

create policy "Users can report others"
  on public.user_reports for insert to authenticated
  with check (auth.uid() = reporter_id);

-- Deliberately no UPDATE and no DELETE for users: status, resolved_at and
-- resolved_by belong to moderation, and a report that the reporter can delete
-- is a report an abuser can pressure away.

grant select, insert on public.user_reports to authenticated;

-- Moderation runs server-side. Narrowest set that works, as with profiles in
-- 015: read the queue, resolve entries. No INSERT (only users file reports),
-- no DELETE (the audit trail stays).
grant select, update on public.user_reports to service_role;
grant select, delete on public.user_blocks to service_role;

-- ------------------------------------------------------------------- verification

do $$
declare
  n int;
  missing text;
begin
  select count(*) into n
  from pg_class c join pg_namespace ns on ns.oid = c.relnamespace
  where ns.nspname = 'public'
    and c.relname in ('user_blocks', 'user_reports')
    and c.relrowsecurity;
  if n <> 2 then
    raise exception 'RLS not enabled on both tables (got %)', n;
  end if;

  select count(*) into n
  from pg_constraint
  where contype = 'f'
    and conrelid::regclass::text in ('user_blocks', 'user_reports');
  if n <> 4 then
    raise exception 'expected 4 foreign keys, found %', n;
  end if;

  select string_agg(format('%s/%s', tbl, priv), ', ') into missing
  from (
    values
      ('user_blocks',  'SELECT'), ('user_blocks',  'INSERT'), ('user_blocks',  'DELETE'),
      ('user_reports', 'SELECT'), ('user_reports', 'INSERT')
  ) as want(tbl, priv)
  where not exists (
    select 1 from information_schema.role_table_grants g
    where g.table_schema = 'public'
      and g.table_name = want.tbl
      and g.grantee = 'authenticated'
      and g.privilege_type = want.priv
  );
  if missing is not null then
    raise exception 'grants missing for authenticated: %', missing;
  end if;

  raise notice 'user_blocks and user_reports are reachable and protected';
end $$;

commit;
