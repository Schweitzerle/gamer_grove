-- 019_dryrun.sql
--
-- Applies 019 against the real database, proves it as real authenticated
-- users, and rolls it back. The closing RAISE is the mechanism that aborts the
-- transaction, not a failure -- "FEHLGESCHLAGEN: 0 von 10" is a pass.
--
-- The last two checks are the ones worth having: they delete a profile and
-- assert that its blocks and reports go with it, which is the difference
-- between a foreign key that is declared and one that cascades.
--
-- Result on 2026-08-04, before 019 was applied for real: 10 von 10 gruen.

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



do $$
declare r text := ''; n int; failed int := 0; msg text;
begin
  perform set_config('role','authenticated',true);
  perform set_config('request.jwt.claims','{"sub":"c809cb14-338a-4321-86d8-3ef6acf997f3","role":"authenticated"}',true);

  insert into user_blocks (blocker_id, blocked_id) values ('c809cb14-338a-4321-86d8-3ef6acf997f3','e661b5e3-2120-4ba6-af56-40c4f4eeeb91');
  r := r || 'A blockiert B: ok' || chr(10);

  select count(*) into n from user_blocks where blocker_id='c809cb14-338a-4321-86d8-3ef6acf997f3';
  r := r || format('A sieht eigene Blocks: %s (erwartet 1)%s', n, chr(10));
  if n <> 1 then failed := failed + 1; end if;

  begin
    insert into user_blocks (blocker_id, blocked_id) values ('0f47f300-4d21-473e-aa86-41157f6924c4','c809cb14-338a-4321-86d8-3ef6acf997f3');
    n := 1;
  exception when others then n := 0;
  end;
  r := r || format('A blockiert IM NAMEN von C: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  begin
    insert into user_blocks (blocker_id, blocked_id) values ('c809cb14-338a-4321-86d8-3ef6acf997f3','c809cb14-338a-4321-86d8-3ef6acf997f3');
    n := 1;
  exception when others then n := 0;
  end;
  r := r || format('A blockiert sich selbst: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  insert into user_reports (reporter_id, reported_id, reason, description)
  values ('c809cb14-338a-4321-86d8-3ef6acf997f3','e661b5e3-2120-4ba6-af56-40c4f4eeeb91','harassment','dry run');
  r := r || 'A meldet B: ok' || chr(10);

  begin
    insert into user_reports (reporter_id, reported_id, reason)
    values ('c809cb14-338a-4321-86d8-3ef6acf997f3','e661b5e3-2120-4ba6-af56-40c4f4eeeb91','nonsense_reason');
    n := 1;
  exception when others then n := 0;
  end;
  r := r || format('A meldet mit ungueltigem Grund: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  begin
    update user_reports set status='resolved' where reporter_id='c809cb14-338a-4321-86d8-3ef6acf997f3';
    get diagnostics n = row_count;
  exception when others then n := -1;
  end;
  r := r || format('A setzt eigenen Report auf resolved: %s (erwartet 0 oder -1)%s', n, chr(10));
  if n > 0 then failed := failed + 1; end if;

  -- B darf nicht sehen, dass er blockiert/gemeldet wurde
  perform set_config('request.jwt.claims','{"sub":"e661b5e3-2120-4ba6-af56-40c4f4eeeb91","role":"authenticated"}',true);

  select count(*) into n from user_blocks;
  r := r || format('B sieht Blocks (auch gegen sich): %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  select count(*) into n from user_reports;
  r := r || format('B sieht Reports gegen sich: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  -- Kaskade: verschwindet ein Block, wenn das Profil geht?
  perform set_config('role','none',true);
  reset role;
  delete from profiles where id='e661b5e3-2120-4ba6-af56-40c4f4eeeb91';
  select count(*) into n from user_blocks where blocked_id='e661b5e3-2120-4ba6-af56-40c4f4eeeb91';
  r := r || format('Blocks nach Loeschen von B: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;
  select count(*) into n from user_reports where reported_id='e661b5e3-2120-4ba6-af56-40c4f4eeeb91';
  r := r || format('Reports nach Loeschen von B: %s (erwartet 0)%s', n, chr(10));
  if n <> 0 then failed := failed + 1; end if;

  raise exception E'
=== DRY RUN 019 (wird zurueckgerollt) ===
%FEHLGESCHLAGEN: % von 10', r, failed;
end $$;

rollback;
