-- storage_and_grants.sql
--
-- Was `supabase db dump` nicht mitnimmt: der Storage-Bucket, seine Politiken
-- und die Tabellen-GRANTs pro Rolle. Beschreibung des Zustands, kein
-- Ausfuehrskript.
--
-- Stand: 2026-08-06, nach Migration 025.
--
-- Erzeugt aus:
--   select * from storage.buckets;
--   select * from pg_policies where schemaname = 'storage';
--   select grantee, table_name, privilege_type
--     from information_schema.role_table_grants
--    where table_schema = 'public' and grantee in ('anon','authenticated','service_role');

-- ================================================================== BUCKET
-- avatars: public=t, size_limit=5242880, mime=image/jpeg|image/png|image/webp

-- ================================================ POLITIKEN AUF storage.objects
create policy "Users remove their own avatar"
  on storage.objects for DELETE to authenticated
  using (((bucket_id = 'avatars'::text) AND (COALESCE(NULLIF((storage.foldername(name))[1], ''::text), (storage.foldername(name))[2]) = (auth.uid())::text)));

create policy "Users write their own avatar"
  on storage.objects for INSERT to authenticated
  with check (((bucket_id = 'avatars'::text) AND (COALESCE(NULLIF((storage.foldername(name))[1], ''::text), (storage.foldername(name))[2]) = (auth.uid())::text)));

create policy "Avatars are publicly readable"
  on storage.objects for SELECT to public
  using ((bucket_id = 'avatars'::text));

create policy "Users replace their own avatar"
  on storage.objects for UPDATE to authenticated
  using (((bucket_id = 'avatars'::text) AND (COALESCE(NULLIF((storage.foldername(name))[1], ''::text), (storage.foldername(name))[2]) = (auth.uid())::text)));

-- ============================================================ TABELLEN-GRANTS
--
-- Eine Tabelle ohne Eintrag hier ist ueber PostgREST nicht erreichbar.
-- profiles                 anon           INSERT
-- profiles                 authenticated  DELETE,INSERT,SELECT,UPDATE
-- profiles                 service_role   INSERT,SELECT,UPDATE
-- user_activity            authenticated  DELETE,INSERT,SELECT,UPDATE
-- user_blocks              authenticated  DELETE,INSERT,SELECT
-- user_blocks              service_role   DELETE,SELECT
-- user_collection_games    anon           SELECT
-- user_collection_games    authenticated  DELETE,INSERT,SELECT,UPDATE
-- user_collections         anon           SELECT
-- user_collections         authenticated  DELETE,INSERT,SELECT,UPDATE
-- user_follows             authenticated  DELETE,INSERT,SELECT,UPDATE
-- user_games               authenticated  DELETE,INSERT,SELECT,UPDATE
-- user_reports             authenticated  INSERT,SELECT
-- user_reports             service_role   SELECT,UPDATE
-- user_top_three           authenticated  DELETE,INSERT,SELECT,UPDATE
