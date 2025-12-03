-- ============================================================
-- Fix RLS Issues for Database Triggers
-- Description: Allows triggers to insert into user_activity
-- ============================================================

-- ============================================================
-- PROBLEM:
-- Database triggers (like log_follow_activity) try to insert
-- into user_activity, but RLS policies block them because
-- triggers run with the current user's permissions.
--
-- SOLUTION:
-- Make trigger functions run with SECURITY DEFINER so they
-- bypass RLS and run with the function owner's (postgres) permissions
-- ============================================================

-- ============================================================
-- 1. UPDATE TRIGGER FUNCTIONS TO USE SECURITY DEFINER
-- ============================================================

-- Fix log_follow_activity function
CREATE OR REPLACE FUNCTION public.log_follow_activity()
RETURNS TRIGGER
SECURITY DEFINER  -- This is the key change!
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_is_public BOOLEAN;
BEGIN
  -- Check if follower's profile is public
  SELECT is_profile_public
  INTO v_is_public
  FROM public.profiles
  WHERE id = NEW.follower_id;

  -- Log the follow
  INSERT INTO public.user_activity (
    user_id,
    activity_type,
    metadata,
    is_public
  ) VALUES (
    NEW.follower_id,
    'followed_user',
    jsonb_build_object('followed_user_id', NEW.following_id),
    COALESCE(v_is_public, false)
  );

  RETURN NULL;
END;
$$;

-- Fix log_user_activity function
CREATE OR REPLACE FUNCTION public.log_user_activity()
RETURNS TRIGGER
SECURITY DEFINER  -- This is the key change!
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_activity_type TEXT;
  v_metadata JSONB;
  v_is_public BOOLEAN;
BEGIN
  -- Determine activity type and metadata based on what changed
  IF TG_OP = 'INSERT' THEN
    IF NEW.is_rated THEN
      v_activity_type := 'rated';
      v_metadata := jsonb_build_object('rating', NEW.rating);
    ELSIF NEW.is_recommended THEN
      v_activity_type := 'recommended';
      v_metadata := '{}';
    ELSIF NEW.is_wishlisted THEN
      v_activity_type := 'wishlisted';
      v_metadata := '{}';
    END IF;

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.rating IS DISTINCT FROM NEW.rating AND NEW.is_rated THEN
      v_activity_type := 'rated';
      v_metadata := jsonb_build_object(
        'rating', NEW.rating,
        'previous_rating', OLD.rating
      );
    ELSIF OLD.is_recommended != NEW.is_recommended AND NEW.is_recommended THEN
      v_activity_type := 'recommended';
      v_metadata := '{}';
    ELSIF OLD.is_wishlisted != NEW.is_wishlisted AND NEW.is_wishlisted THEN
      v_activity_type := 'wishlisted';
      v_metadata := '{}';
    END IF;
  END IF;

  -- Only log if we have an activity type
  IF v_activity_type IS NOT NULL THEN
    -- Check user's privacy settings from PROFILES table
    SELECT
      CASE v_activity_type
        WHEN 'rated' THEN show_rated_games
        WHEN 'recommended' THEN show_recommended_games
        WHEN 'wishlisted' THEN show_wishlist
        ELSE true
      END AND is_profile_public
    INTO v_is_public
    FROM public.profiles
    WHERE id = NEW.user_id;

    -- Insert activity
    INSERT INTO public.user_activity (
      user_id,
      activity_type,
      game_id,
      metadata,
      is_public
    ) VALUES (
      NEW.user_id,
      v_activity_type,
      NEW.game_id,
      v_metadata,
      COALESCE(v_is_public, false)
    );
  END IF;

  RETURN NULL;
END;
$$;

-- Fix log_top_three_activity function
CREATE OR REPLACE FUNCTION public.log_top_three_activity()
RETURNS TRIGGER
SECURITY DEFINER  -- This is the key change!
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_is_public BOOLEAN;
BEGIN
  -- Check if user wants to share top three publicly from PROFILES table
  SELECT show_top_three AND is_profile_public
  INTO v_is_public
  FROM public.profiles
  WHERE id = NEW.user_id;

  -- Log the update
  INSERT INTO public.user_activity (
    user_id,
    activity_type,
    metadata,
    is_public
  ) VALUES (
    NEW.user_id,
    'updated_top_three',
    jsonb_build_object(
      'game_1_id', NEW.game_1_id,
      'game_2_id', NEW.game_2_id,
      'game_3_id', NEW.game_3_id
    ),
    COALESCE(v_is_public, false)
  );

  RETURN NULL;
END;
$$;

-- Fix update_follow_counts function
CREATE OR REPLACE FUNCTION public.update_follow_counts()
RETURNS TRIGGER
SECURITY DEFINER  -- This is the key change!
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- Increment follower count for the followed user
    UPDATE public.profiles
    SET followers_count = followers_count + 1
    WHERE id = NEW.following_id;

    -- Increment following count for the follower
    UPDATE public.profiles
    SET following_count = following_count + 1
    WHERE id = NEW.follower_id;

  ELSIF TG_OP = 'DELETE' THEN
    -- Decrement follower count for the unfollowed user
    UPDATE public.profiles
    SET followers_count = GREATEST(0, followers_count - 1)
    WHERE id = OLD.following_id;

    -- Decrement following count for the unfollower
    UPDATE public.profiles
    SET following_count = GREATEST(0, following_count - 1)
    WHERE id = OLD.follower_id;
  END IF;

  RETURN NULL;
END;
$$;

-- Fix update_user_game_stats function
CREATE OR REPLACE FUNCTION public.update_user_game_stats()
RETURNS TRIGGER
SECURITY DEFINER  -- This is the key change!
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_user_id UUID;
  v_total_rated INTEGER;
  v_total_wishlisted INTEGER;
  v_total_recommended INTEGER;
  v_avg_rating DECIMAL;
BEGIN
  -- Determine which user to update
  IF TG_OP = 'DELETE' THEN
    v_user_id := OLD.user_id;
  ELSE
    v_user_id := NEW.user_id;
  END IF;

  -- Calculate new stats
  SELECT
    COUNT(*) FILTER (WHERE is_rated = true),
    COUNT(*) FILTER (WHERE is_wishlisted = true),
    COUNT(*) FILTER (WHERE is_recommended = true),
    AVG(rating) FILTER (WHERE is_rated = true)
  INTO v_total_rated, v_total_wishlisted, v_total_recommended, v_avg_rating
  FROM public.user_games
  WHERE user_id = v_user_id;

  -- Update PROFILES record (not users!)
  UPDATE public.profiles
  SET
    total_games_rated = v_total_rated,
    total_games_wishlisted = v_total_wishlisted,
    total_games_recommended = v_total_recommended,
    average_rating = ROUND(v_avg_rating, 1)
  WHERE id = v_user_id;

  RETURN NULL;
END;
$$;

-- ============================================================
-- 2. VERIFY FUNCTIONS HAVE SECURITY DEFINER
-- ============================================================

DO $$
DECLARE
  definer_count INTEGER;
  total_count INTEGER;
BEGIN
  -- Count trigger functions with SECURITY DEFINER
  SELECT COUNT(*) INTO definer_count
  FROM pg_proc p
  JOIN pg_namespace n ON p.pronamespace = n.oid
  WHERE n.nspname = 'public'
    AND p.proname IN (
      'log_follow_activity',
      'log_user_activity',
      'log_top_three_activity',
      'update_follow_counts',
      'update_user_game_stats'
    )
    AND p.prosecdef = true;

  SELECT COUNT(*) INTO total_count
  FROM pg_proc p
  JOIN pg_namespace n ON p.pronamespace = n.oid
  WHERE n.nspname = 'public'
    AND p.proname IN (
      'log_follow_activity',
      'log_user_activity',
      'log_top_three_activity',
      'update_follow_counts',
      'update_user_game_stats'
    );

  RAISE NOTICE '============================================================';
  RAISE NOTICE '✅ Trigger functions updated!';
  RAISE NOTICE '============================================================';
  RAISE NOTICE 'Functions with SECURITY DEFINER: %/%', definer_count, total_count;
  RAISE NOTICE '============================================================';

  IF definer_count = total_count THEN
    RAISE NOTICE '✨ All trigger functions now use SECURITY DEFINER!';
    RAISE NOTICE '✨ Follow/unfollow should work now!';
  ELSE
    RAISE WARNING '⚠️ Some functions missing SECURITY DEFINER';
  END IF;
END $$;
