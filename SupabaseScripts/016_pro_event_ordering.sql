-- ============================================================
-- 016 — Remember which billing event last wrote the Pro state
-- ============================================================
--
-- The webhook applied every event it received, in the order it happened to
-- receive them. RevenueCat guarantees neither: it retries failed deliveries and
-- does not promise ordering. Two ways that goes wrong:
--
--   * A retried EXPIRATION arrives after the RENEWAL that followed it, and
--     revokes Pro from someone who is paying.
--   * A duplicate delivery re-applies an event that was already applied.
--
-- Both disappear if the row remembers the timestamp of the event that wrote it
-- and refuses anything older. Retries reuse the same `event_timestamp_ms`, so
-- a strict `<` comparison also makes replays no-ops.
--
-- Run in the Supabase SQL editor.
-- ============================================================

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS pro_event_at timestamptz;

COMMENT ON COLUMN public.profiles.pro_event_at IS
  'event_timestamp_ms of the RevenueCat event that last wrote is_pro. '
  'Written only by the revenuecat-webhook function; older events are ignored.';

-- The guard from 014 covers is_pro and pro_expires_at. This column decides
-- whether those two may be written at all, so a client that could set it
-- backwards could replay an old grant. Same rule, same trigger.
CREATE OR REPLACE FUNCTION public.guard_pro_columns()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF (NEW.is_pro IS DISTINCT FROM OLD.is_pro
      OR NEW.pro_expires_at IS DISTINCT FROM OLD.pro_expires_at
      OR NEW.pro_event_at IS DISTINCT FROM OLD.pro_event_at)
     AND current_setting('request.jwt.claims', true) IS NOT NULL
     AND coalesce(auth.role(), '') <> 'service_role'
  THEN
    RAISE EXCEPTION 'Pro status is managed by the billing provider'
      USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;

-- ============================================================
-- VERIFY
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'pro_event_at'
  ) THEN
    RAISE EXCEPTION 'profiles.pro_event_at missing';
  END IF;

  RAISE NOTICE 'pro event ordering ready';
END $$;
