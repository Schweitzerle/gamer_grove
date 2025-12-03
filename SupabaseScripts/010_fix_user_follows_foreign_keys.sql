-- ============================================================
-- Fix user_follows foreign key constraints to reference profiles
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
  AND tc.table_name = 'user_follows'
  AND tc.table_schema = 'public'
ORDER BY tc.constraint_name;

-- ============================================================
-- 2. DROP OLD FOREIGN KEY CONSTRAINTS
-- ============================================================

-- Drop the old foreign keys that reference 'users' table
ALTER TABLE public.user_follows
  DROP CONSTRAINT IF EXISTS user_follows_follower_id_fkey;

ALTER TABLE public.user_follows
  DROP CONSTRAINT IF EXISTS user_follows_following_id_fkey;

-- ============================================================
-- 3. CREATE NEW FOREIGN KEY CONSTRAINTS
-- ============================================================

-- Add new foreign keys that reference 'profiles' table
ALTER TABLE public.user_follows
  ADD CONSTRAINT user_follows_follower_id_fkey
  FOREIGN KEY (follower_id)
  REFERENCES public.profiles(id)
  ON DELETE CASCADE;

ALTER TABLE public.user_follows
  ADD CONSTRAINT user_follows_following_id_fkey
  FOREIGN KEY (following_id)
  REFERENCES public.profiles(id)
  ON DELETE CASCADE;

-- ============================================================
-- 4. VERIFY FOREIGN KEYS
-- ============================================================

DO $$
DECLARE
  fk_count INTEGER;
  follower_fk_exists BOOLEAN;
  following_fk_exists BOOLEAN;
BEGIN
  -- Count total foreign keys
  SELECT COUNT(*) INTO fk_count
  FROM information_schema.table_constraints
  WHERE table_name = 'user_follows'
    AND constraint_type = 'FOREIGN KEY'
    AND table_schema = 'public';

  -- Check follower_id foreign key
  SELECT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints AS tc
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
    WHERE tc.table_name = 'user_follows'
      AND tc.constraint_type = 'FOREIGN KEY'
      AND tc.constraint_name = 'user_follows_follower_id_fkey'
      AND ccu.table_name = 'profiles'
  ) INTO follower_fk_exists;

  -- Check following_id foreign key
  SELECT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints AS tc
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
    WHERE tc.table_name = 'user_follows'
      AND tc.constraint_type = 'FOREIGN KEY'
      AND tc.constraint_name = 'user_follows_following_id_fkey'
      AND ccu.table_name = 'profiles'
  ) INTO following_fk_exists;

  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ user_follows foreign keys updated!';
  RAISE NOTICE '============================================================';
  RAISE NOTICE 'Total foreign keys: %', fk_count;
  RAISE NOTICE 'follower_id → profiles: %', follower_fk_exists;
  RAISE NOTICE 'following_id → profiles: %', following_fk_exists;
  RAISE NOTICE '============================================================';

  IF follower_fk_exists AND following_fk_exists THEN
    RAISE NOTICE '✨ All foreign keys correctly reference profiles table!';
  ELSE
    RAISE WARNING '⚠️ Some foreign keys may not be correctly configured';
  END IF;
END $$;

-- ============================================================
-- 5. TEST QUERY (Optional - Manual Test)
-- ============================================================

-- You can test the foreign key relationships with this query:
-- This should return follower profile data
-- SELECT
--   uf.follower_id,
--   uf.following_id,
--   p.username,
--   p.display_name
-- FROM user_follows uf
-- JOIN profiles p ON p.id = uf.follower_id
-- LIMIT 5;
