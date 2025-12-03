-- ============================================================
-- Database Structure Analysis Script
-- Description: Analyzes current database structure
-- ============================================================

-- ============================================================
-- 1. LIST ALL TABLES IN PUBLIC SCHEMA
-- ============================================================
SELECT
  'TABLES IN PUBLIC SCHEMA' as info_type,
  schemaname,
  tablename,
  tableowner
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- ============================================================
-- 2. GET COLUMN DETAILS FOR EACH TABLE
-- ============================================================
SELECT
  'TABLE COLUMNS' as info_type,
  table_name,
  column_name,
  data_type,
  character_maximum_length,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- ============================================================
-- 3. LIST ALL TRIGGERS
-- ============================================================
SELECT
  'TRIGGERS' as info_type,
  n.nspname as schema_name,
  c.relname as table_name,
  t.tgname as trigger_name,
  p.proname as function_name,
  CASE
    WHEN t.tgtype & 1 = 1 THEN 'ROW'
    ELSE 'STATEMENT'
  END as trigger_level,
  CASE
    WHEN t.tgtype & 2 = 2 THEN 'BEFORE'
    WHEN t.tgtype & 64 = 64 THEN 'INSTEAD OF'
    ELSE 'AFTER'
  END as trigger_timing,
  CASE
    WHEN t.tgtype & 4 = 4 THEN 'INSERT'
    WHEN t.tgtype & 8 = 8 THEN 'DELETE'
    WHEN t.tgtype & 16 = 16 THEN 'UPDATE'
    ELSE 'TRUNCATE'
  END as trigger_event
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE n.nspname IN ('public', 'auth')
  AND NOT t.tgisinternal
ORDER BY n.nspname, c.relname, t.tgname;

-- ============================================================
-- 4. LIST ALL FUNCTIONS IN PUBLIC SCHEMA
-- ============================================================
SELECT
  'FUNCTIONS' as info_type,
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_arguments(p.oid) as arguments,
  pg_get_function_result(p.oid) as return_type,
  CASE p.provolatile
    WHEN 'i' THEN 'IMMUTABLE'
    WHEN 's' THEN 'STABLE'
    WHEN 'v' THEN 'VOLATILE'
  END as volatility,
  CASE p.prosecdef
    WHEN true THEN 'DEFINER'
    ELSE 'INVOKER'
  END as security
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.prokind = 'f'
ORDER BY p.proname;

-- ============================================================
-- 5. LIST ALL INDEXES
-- ============================================================
SELECT
  'INDEXES' as info_type,
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- ============================================================
-- 6. LIST ALL CONSTRAINTS
-- ============================================================
SELECT
  'CONSTRAINTS' as info_type,
  tc.table_name,
  tc.constraint_name,
  tc.constraint_type,
  CASE tc.constraint_type
    WHEN 'FOREIGN KEY' THEN (
      SELECT string_agg(kcu.column_name, ', ')
      FROM information_schema.key_column_usage kcu
      WHERE kcu.constraint_name = tc.constraint_name
    )
    ELSE NULL
  END as columns
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'public'
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

-- ============================================================
-- 7. LIST ROW LEVEL SECURITY POLICIES
-- ============================================================
SELECT
  'RLS POLICIES' as info_type,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd as operation,
  qual as using_expression,
  with_check as check_expression
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ============================================================
-- 8. CHECK IF PROFILES TABLE EXISTS
-- ============================================================
SELECT
  'PROFILES TABLE CHECK' as info_type,
  EXISTS (
    SELECT 1
    FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename = 'profiles'
  ) as profiles_table_exists,
  EXISTS (
    SELECT 1
    FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename = 'users'
  ) as users_table_exists;

-- ============================================================
-- 9. CHECK AUTH TRIGGER ON AUTH.USERS
-- ============================================================
SELECT
  'AUTH USER TRIGGER CHECK' as info_type,
  EXISTS (
    SELECT 1
    FROM pg_trigger t
    JOIN pg_class c ON t.tgrelid = c.oid
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE n.nspname = 'auth'
    AND c.relname = 'users'
    AND t.tgname LIKE '%new_user%'
  ) as has_new_user_trigger;

-- ============================================================
-- 10. COUNT RECORDS IN KEY TABLES
-- ============================================================
DO $$
DECLARE
  profiles_count INTEGER;
  users_count INTEGER;
  auth_users_count INTEGER;
BEGIN
  -- Check profiles table
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'profiles') THEN
    EXECUTE 'SELECT COUNT(*) FROM public.profiles' INTO profiles_count;
    RAISE NOTICE 'RECORD COUNTS - profiles: %', profiles_count;
  ELSE
    RAISE NOTICE 'RECORD COUNTS - profiles: table does not exist';
  END IF;

  -- Check users table
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
    EXECUTE 'SELECT COUNT(*) FROM public.users' INTO users_count;
    RAISE NOTICE 'RECORD COUNTS - users: %', users_count;
  ELSE
    RAISE NOTICE 'RECORD COUNTS - users: table does not exist';
  END IF;

  -- Check auth.users
  EXECUTE 'SELECT COUNT(*) FROM auth.users' INTO auth_users_count;
  RAISE NOTICE 'RECORD COUNTS - auth.users: %', auth_users_count;
END $$;
