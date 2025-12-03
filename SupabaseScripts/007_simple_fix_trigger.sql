-- ============================================================
-- Simple Fix: Update handle_new_user trigger for profiles table
-- Description: Minimal changes to fix registration
-- ============================================================

-- ============================================================
-- 1. UPDATE HANDLE_NEW_USER FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Create user profile in public.profiles
  INSERT INTO public.profiles (
    id,
    username,
    display_name,
    created_at,
    updated_at,
    last_active_at
  ) VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'username',
      'user_' || substring(NEW.id::text, 1, 8)
    ),
    COALESCE(
      NEW.raw_user_meta_data->>'display_name',
      NEW.raw_user_meta_data->>'username'
    ),
    NOW(),
    NOW(),
    NOW()
  );

  RETURN NEW;
EXCEPTION
  WHEN unique_violation THEN
    -- If username already exists, try with a suffix
    INSERT INTO public.profiles (
      id,
      username,
      display_name,
      created_at,
      updated_at,
      last_active_at
    ) VALUES (
      NEW.id,
      'user_' || substring(NEW.id::text, 1, 8),
      COALESCE(
        NEW.raw_user_meta_data->>'display_name',
        NEW.raw_user_meta_data->>'username'
      ),
      NOW(),
      NOW(),
      NOW()
    );
    RETURN NEW;
  WHEN OTHERS THEN
    RAISE WARNING 'Failed to create profile for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$;

-- ============================================================
-- 2. UPDATE IS_USERNAME_AVAILABLE FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION public.is_username_available(username_to_check TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  username_exists BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE LOWER(username) = LOWER(username_to_check)
  ) INTO username_exists;

  RETURN NOT username_exists;
END;
$$;

-- ============================================================
-- 3. FIX EXISTING AUTH USERS WITHOUT PROFILES
-- ============================================================

DO $$
DECLARE
  auth_user RECORD;
  generated_username TEXT;
  username_suffix INTEGER := 1;
  final_username TEXT;
  fixed_count INTEGER := 0;
BEGIN
  FOR auth_user IN
    SELECT
      au.id,
      au.email,
      au.raw_user_meta_data
    FROM auth.users au
    LEFT JOIN public.profiles pu ON au.id = pu.id
    WHERE pu.id IS NULL
  LOOP
    generated_username := COALESCE(
      auth_user.raw_user_meta_data->>'username',
      'user_' || substring(auth_user.id::text, 1, 8)
    );

    final_username := generated_username;
    username_suffix := 1;
    WHILE EXISTS (SELECT 1 FROM public.profiles WHERE username = final_username) LOOP
      final_username := generated_username || '_' || username_suffix;
      username_suffix := username_suffix + 1;
    END LOOP;

    INSERT INTO public.profiles (
      id,
      username,
      display_name,
      created_at,
      updated_at,
      last_active_at
    ) VALUES (
      auth_user.id,
      final_username,
      COALESCE(
        auth_user.raw_user_meta_data->>'display_name',
        final_username
      ),
      NOW(),
      NOW(),
      NOW()
    );

    fixed_count := fixed_count + 1;
    RAISE NOTICE 'Created profile for user % with username %', auth_user.id, final_username;
  END LOOP;

  IF fixed_count > 0 THEN
    RAISE NOTICE '✅ Fixed % auth users without profiles', fixed_count;
  ELSE
    RAISE NOTICE '✅ All auth users already have profiles';
  END IF;
END $$;

-- ============================================================
-- 4. VERIFY
-- ============================================================

DO $$
DECLARE
  auth_count INTEGER;
  profile_count INTEGER;
  missing_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO auth_count FROM auth.users;
  SELECT COUNT(*) INTO profile_count FROM public.profiles;

  SELECT COUNT(*) INTO missing_count
  FROM auth.users au
  LEFT JOIN public.profiles p ON au.id = p.id
  WHERE p.id IS NULL;

  RAISE NOTICE '================================================';
  RAISE NOTICE '✅ Fix completed!';
  RAISE NOTICE '================================================';
  RAISE NOTICE 'Auth users: %', auth_count;
  RAISE NOTICE 'Profiles: %', profile_count;
  RAISE NOTICE 'Missing profiles: %', missing_count;
  RAISE NOTICE '================================================';

  IF missing_count = 0 THEN
    RAISE NOTICE '✨ Success! All auth users have profiles!';
    RAISE NOTICE '✨ New registrations should work now!';
  ELSE
    RAISE WARNING '⚠️ Still missing % profiles!', missing_count;
  END IF;
END $$;
