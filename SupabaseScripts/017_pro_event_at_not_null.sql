-- ============================================================
-- 017 — pro_event_at braucht einen Wert, keinen NULL
-- ============================================================
--
-- 016 hat die Spalte nullable angelegt, und der Webhook prüfte deshalb
-- „ist null ODER älter als dieses Ereignis". Genau diese `or`-Gruppe
-- verträgt PostgREST auf einem UPDATE nicht: sie wird als
-- `profiles.pro_event_at` qualifiziert, und in der UPDATE-Anweisung heißt
-- die Relation nicht `profiles` — Postgres antwortet mit
-- „column profiles.pro_event_at does not exist" (42703), obwohl die Spalte
-- da ist. Auf einem SELECT läuft dieselbe Gruppe durch, was die Sache beim
-- Lesen unsichtbar macht.
--
-- Bekommt die Spalte stattdessen einen Anfangswert, reicht ein einfacher
-- Vergleich, und der funktioniert auf UPDATE.
--
-- Run in the Supabase SQL editor.
-- ============================================================

UPDATE public.profiles
SET pro_event_at = '-infinity'
WHERE pro_event_at IS NULL;

ALTER TABLE public.profiles
  ALTER COLUMN pro_event_at SET DEFAULT '-infinity',
  ALTER COLUMN pro_event_at SET NOT NULL;

COMMENT ON COLUMN public.profiles.pro_event_at IS
  'event_timestamp_ms des RevenueCat-Ereignisses, das is_pro zuletzt '
  'geschrieben hat. -infinity heißt: noch keines. Nur die '
  'revenuecat-webhook-Function schreibt hier; ältere Ereignisse werden '
  'verworfen.';

-- ============================================================
-- VERIFY
-- ============================================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles'
      AND column_name = 'pro_event_at' AND is_nullable = 'YES'
  ) THEN
    RAISE EXCEPTION 'pro_event_at ist noch nullable';
  END IF;

  RAISE NOTICE 'pro_event_at ready';
END $$;
