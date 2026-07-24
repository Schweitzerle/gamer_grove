-- ============================================================
-- 013 — Self-service account deletion (GDPR Art. 17 / Play policy)
-- ============================================================
--
-- The client cannot delete a row in auth.users: that needs the service role,
-- which must never ship in an app. This SECURITY DEFINER function runs with the
-- owner's rights and deletes ONLY the caller's own account, derived from
-- auth.uid() — the caller cannot pass someone else's id.
--
-- Data removed:
--   * user_games, user_top_three          — deleted explicitly here
--   * user_collections (+ member games)   — cascade from profiles (012)
--   * user_follows (both directions)      — cascade from profiles (010)
--   * user_activity                       — cascade from profiles (011)
--   * profiles                            — deleted explicitly here
--   * auth.users                          — deleted explicitly here
--
-- Run in the Supabase SQL editor (as postgres, so the function is owned by a
-- role allowed to write auth.users).
-- ============================================================

CREATE OR REPLACE FUNCTION public.delete_own_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated' USING ERRCODE = '28000';
  END IF;

  -- Tables that predate the cascade cleanups; explicit deletes are harmless
  -- even where a cascade would already cover them.
  DELETE FROM public.user_games WHERE user_id = uid;
  DELETE FROM public.user_top_three WHERE user_id = uid;

  -- Cascades to user_collections, user_collection_games, user_follows,
  -- user_activity.
  DELETE FROM public.profiles WHERE id = uid;

  -- Finally the identity itself, so the email can be registered again.
  DELETE FROM auth.users WHERE id = uid;
END;
$$;

-- Only signed-in users may call it; anon has no business here.
REVOKE ALL ON FUNCTION public.delete_own_account() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.delete_own_account() FROM anon;
GRANT EXECUTE ON FUNCTION public.delete_own_account() TO authenticated;

-- ============================================================
-- VERIFY
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.proname = 'delete_own_account'
  ) THEN
    RAISE EXCEPTION 'delete_own_account was not created';
  END IF;
  RAISE NOTICE 'delete_own_account ready';
END $$;
