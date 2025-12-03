-- ============================================================
-- Fix user_follows RLS policies to use profiles table
-- Description: Updates RLS policies that reference old users table
-- ============================================================

-- ============================================================
-- 1. CHECK CURRENT RLS POLICIES
-- ============================================================

-- First, let's see what policies exist
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  cmd as operation,
  qual as using_expression
FROM pg_policies
WHERE tablename = 'user_follows'
ORDER BY policyname;

-- ============================================================
-- 2. DROP OLD POLICIES
-- ============================================================

DROP POLICY IF EXISTS "Users can follow others" ON public.user_follows;
DROP POLICY IF EXISTS "Users can unfollow others" ON public.user_follows;
DROP POLICY IF EXISTS "Anyone can view follows" ON public.user_follows;

-- ============================================================
-- 3. CREATE NEW POLICIES FOR USER_FOLLOWS
-- ============================================================

-- Anyone can view follow relationships
CREATE POLICY "Anyone can view follows"
ON public.user_follows
FOR SELECT
USING (true);

-- Users can follow others (insert)
CREATE POLICY "Users can follow others"
ON public.user_follows
FOR INSERT
WITH CHECK (
  auth.uid() = follower_id AND
  follower_id != following_id
);

-- Users can unfollow others (delete their own follows)
CREATE POLICY "Users can unfollow others"
ON public.user_follows
FOR DELETE
USING (auth.uid() = follower_id);

-- ============================================================
-- 4. VERIFY POLICIES
-- ============================================================

DO $$
DECLARE
  policy_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies
  WHERE tablename = 'user_follows';

  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ user_follows RLS policies updated!';
  RAISE NOTICE '============================================================';
  RAISE NOTICE 'Total policies on user_follows: %', policy_count;
  RAISE NOTICE '============================================================';

  IF policy_count >= 3 THEN
    RAISE NOTICE '✨ Follow/unfollow should work now!';
  ELSE
    RAISE WARNING '⚠️ Expected at least 3 policies, found %', policy_count;
  END IF;
END $$;

-- ============================================================
-- 5. TEST FOLLOW RELATIONSHIP (Optional - Manual Test)
-- ============================================================

-- You can test with these queries after running the script:
--
-- Test 1: Check if you can view follows
-- SELECT * FROM user_follows LIMIT 5;
--
-- Test 2: Check if you can insert a follow (replace UUIDs with real ones)
-- INSERT INTO user_follows (follower_id, following_id)
-- VALUES ('your-user-id', 'target-user-id');
--
-- Test 3: Check if you can delete a follow
-- DELETE FROM user_follows
-- WHERE follower_id = 'your-user-id' AND following_id = 'target-user-id';
