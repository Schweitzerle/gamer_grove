-- ============================================================
-- 014 — Pro status in Postgres + server-side collection limit
-- ============================================================
--
-- The 3-collection free limit was enforced only in the client, so a modified
-- client could create any number. Enforcing it in the database needs the Pro
-- state here, because entitlements live in RevenueCat.
--
--   profiles.is_pro / pro_expires_at   mirrored from RevenueCat by the
--                                      `revenuecat-webhook` edge function
--   guard trigger                      users cannot grant themselves Pro
--   limit trigger                      rejects the 4th collection for free users
--
-- Run in the Supabase SQL editor.
-- ============================================================

-- ============================================================
-- 1. PRO STATE
-- ============================================================

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS is_pro boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS pro_expires_at timestamptz;

COMMENT ON COLUMN public.profiles.is_pro IS
  'Mirrored from RevenueCat by the revenuecat-webhook function. Never written by clients.';

-- Effective Pro: flagged and not expired. An open end date means "active with
-- no known expiry" (e.g. a lifetime grant).
CREATE OR REPLACE FUNCTION public.is_pro_user(uid uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    (SELECT is_pro AND (pro_expires_at IS NULL OR pro_expires_at > now())
     FROM public.profiles WHERE id = uid),
    false
  );
$$;

-- Only the triggers below call this, and they run as SECURITY DEFINER. Leaving
-- it callable would let anyone probe whether a given user id is Pro.
REVOKE ALL ON FUNCTION public.is_pro_user(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.is_pro_user(uuid) FROM anon;
REVOKE ALL ON FUNCTION public.is_pro_user(uuid) FROM authenticated;

-- ============================================================
-- 2. USERS MUST NOT BE ABLE TO GRANT THEMSELVES PRO
-- ============================================================
-- The owner UPDATE policy on profiles covers the whole row, so without this
-- guard a crafted request could simply set is_pro = true.

CREATE OR REPLACE FUNCTION public.guard_pro_columns()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF (NEW.is_pro IS DISTINCT FROM OLD.is_pro
      OR NEW.pro_expires_at IS DISTINCT FROM OLD.pro_expires_at)
     AND current_setting('request.jwt.claims', true) IS NOT NULL
     AND coalesce(auth.role(), '') <> 'service_role'
  THEN
    RAISE EXCEPTION 'Pro status is managed by the billing provider'
      USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS profiles_guard_pro_columns ON public.profiles;
CREATE TRIGGER profiles_guard_pro_columns
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_pro_columns();

-- ============================================================
-- 3. COLLECTION LIMIT
-- ============================================================
-- Keep in sync with kFreeCollectionLimit in
-- lib/core/entitlements/free_limits.dart.

CREATE OR REPLACE FUNCTION public.enforce_collection_limit()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  free_limit constant int := 3;
  existing int;
BEGIN
  IF public.is_pro_user(NEW.user_id) THEN
    RETURN NEW;
  END IF;

  SELECT count(*) INTO existing
  FROM public.user_collections
  WHERE user_id = NEW.user_id;

  IF existing >= free_limit THEN
    -- Distinct SQLSTATE so the client can tell this apart from a generic
    -- failure and open the paywall instead of showing an error.
    RAISE EXCEPTION 'Free accounts are limited to % collections', free_limit
      USING ERRCODE = 'P0100';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS user_collections_enforce_limit ON public.user_collections;
CREATE TRIGGER user_collections_enforce_limit
  BEFORE INSERT ON public.user_collections
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_collection_limit();

-- ============================================================
-- VERIFY
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'is_pro'
  ) THEN
    RAISE EXCEPTION 'profiles.is_pro missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'user_collections_enforce_limit'
  ) THEN
    RAISE EXCEPTION 'collection limit trigger missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'profiles_guard_pro_columns'
  ) THEN
    RAISE EXCEPTION 'pro column guard missing';
  END IF;

  RAISE NOTICE 'pro status + collection limit ready';
END $$;
