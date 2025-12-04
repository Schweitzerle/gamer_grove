-- ============================================================
-- Fix user_activity foreign key constraints to reference profiles
-- Description: Updates foreign keys that still reference old users table
-- ============================================================

-- ============================================================
-- 1. CHECK CURRENT FOREIGN KEYS
-- ============================================================

-- First, let's see what foreign keys exist
SELECT
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = 'user_activity'
  AND tc.table_schema = 'public'
ORDER BY tc.constraint_name;

-- ============================================================
-- 2. DROP OLD FOREIGN KEY CONSTRAINTS
-- ============================================================

-- Drop the old foreign keys that reference 'users' table
ALTER TABLE public.user_activity
  DROP CONSTRAINT IF EXISTS user_activity_user_id_fkey;

-- ============================================================
-- 3. CREATE NEW FOREIGN KEY CONSTRAINTS
-- ============================================================

-- Add new foreign keys that reference 'profiles' table
ALTER TABLE public.user_activity
  ADD CONSTRAINT user_activity_user_id_fkey
  FOREIGN KEY (user_id)
  REFERENCES public.profiles(id)
  ON DELETE CASCADE;

-- ============================================================
-- 4. VERIFY FOREIGN KEYS
-- ============================================================

DO $$
DECLARE
  fk_count INTEGER;
  user_fk_exists BOOLEAN;
BEGIN
  -- Count total foreign keys
  SELECT COUNT(*) INTO fk_count
  FROM information_schema.table_constraints
  WHERE table_name = 'user_activity'
    AND constraint_type = 'FOREIGN KEY'
    AND table_schema = 'public';

  -- Check user_id foreign key
  SELECT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints AS tc
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
    WHERE tc.table_name = 'user_activity'
      AND tc.constraint_type = 'FOREIGN KEY'
      AND tc.constraint_name = 'user_activity_user_id_fkey'
      AND ccu.table_name = 'profiles'
  ) INTO user_fk_exists;

  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ user_activity foreign keys updated!';
  RAISE NOTICE '============================================================';
  RAISE NOTICE 'Total foreign keys: %', fk_count;
  RAISE NOTICE 'user_id → profiles: %', user_fk_exists;
  RAISE NOTICE '============================================================';

  IF user_fk_exists THEN
    RAISE NOTICE '✨ All foreign keys correctly reference profiles table!';
  ELSE
    RAISE WARNING '⚠️ Some foreign keys may not be correctly configured';
  END IF;
END $$;
