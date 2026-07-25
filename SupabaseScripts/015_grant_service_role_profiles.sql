-- ============================================================
-- 015 — Let the service role write the Pro flag on profiles
-- ============================================================
--
-- The revenuecat-webhook function writes profiles.is_pro with the service role.
-- The service role bypasses RLS policies, but NOT table-level GRANTs — and in
-- this project the default privileges do not cover it (012 had to grant
-- explicitly too). Without this the webhook fails with:
--
--   permission denied for table profiles
--
-- Verified against the deployed function, which returned exactly that.
--
-- Run in the Supabase SQL editor.
-- ============================================================

-- SELECT is needed for the id filter, UPDATE for the write itself. No INSERT
-- or DELETE: the webhook must never create or remove a profile.
GRANT SELECT, UPDATE ON public.profiles TO service_role;

-- ============================================================
-- VERIFY
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.role_table_grants
    WHERE table_schema = 'public'
      AND table_name = 'profiles'
      AND grantee = 'service_role'
      AND privilege_type = 'UPDATE'
  ) THEN
    RAISE EXCEPTION 'service_role still cannot update profiles';
  END IF;
  RAISE NOTICE 'service_role can update profiles';
END $$;
