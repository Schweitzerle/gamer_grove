-- Schema-Abzug der Produktionsdatenbank, erzeugt am 2026-08-06 nach
-- Migration 025 mit `supabase db dump --linked`.
--
-- Kein Skript zum Ausfuehren gegen die laufende Datenbank: es beschreibt
-- den Zustand, es stellt ihn nicht her. Siehe README.md daneben.




SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;




ALTER SCHEMA "public" OWNER TO "postgres";


CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."batch_get_follow_status"("p_current_user_id" "uuid", "p_target_user_ids" "uuid"[]) RETURNS TABLE("target_user_id" "uuid", "is_following" boolean)
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id as target_user_id,
    EXISTS (
      SELECT 1 FROM public.user_follows
      WHERE follower_id = p_current_user_id
      AND following_id = u.id
    ) as is_following
  FROM unnest(p_target_user_ids) AS u(id);
END;
$$;


ALTER FUNCTION "public"."batch_get_follow_status"("p_current_user_id" "uuid", "p_target_user_ids" "uuid"[]) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."batch_get_follow_status"("p_current_user_id" "uuid", "p_target_user_ids" "uuid"[]) IS 'Efficiently checks follow status for multiple users at once';



CREATE OR REPLACE FUNCTION "public"."block_user"("target_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  -- user_blocks already has a CHECK against this, but failing here gives the
  -- client a clear error instead of a constraint violation.
  if uid = target_id then
    raise exception 'Cannot block yourself' using errcode = '22023';
  end if;

  if not exists (select 1 from public.profiles where id = target_id) then
    raise exception 'No such user' using errcode = '23503';
  end if;

  -- Blocking twice is not an error; the second call should be a no-op so the
  -- UI never has to care whether a block already existed.
  insert into public.user_blocks (blocker_id, blocked_id)
  values (uid, target_id)
  on conflict (blocker_id, blocked_id) do nothing;

  delete from public.user_follows
  where (follower_id = uid       and following_id = target_id)
     or (follower_id = target_id and following_id = uid);
end;
$$;


ALTER FUNCTION "public"."block_user"("target_id" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "username" "text" NOT NULL,
    "display_name" "text",
    "bio" "text",
    "avatar_url" "text",
    "country" "text",
    "is_profile_public" boolean DEFAULT true NOT NULL,
    "show_wishlist" boolean DEFAULT true NOT NULL,
    "show_rated_games" boolean DEFAULT true NOT NULL,
    "show_recommended_games" boolean DEFAULT true NOT NULL,
    "show_top_three" boolean DEFAULT true NOT NULL,
    "total_games_rated" integer DEFAULT 0 NOT NULL,
    "total_games_wishlisted" integer DEFAULT 0 NOT NULL,
    "total_games_recommended" integer DEFAULT 0 NOT NULL,
    "average_rating" numeric(3,1),
    "followers_count" integer DEFAULT 0 NOT NULL,
    "following_count" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "last_active_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_pro" boolean DEFAULT false NOT NULL,
    "pro_expires_at" timestamp with time zone,
    "pro_event_at" timestamp with time zone DEFAULT '-infinity'::timestamp with time zone NOT NULL,
    CONSTRAINT "bio_length" CHECK ((("bio" IS NULL) OR ("char_length"("bio") <= 500))),
    CONSTRAINT "display_name_length" CHECK ((("display_name" IS NULL) OR (("char_length"("display_name") >= 1) AND ("char_length"("display_name") <= 50)))),
    CONSTRAINT "username_format" CHECK (("username" ~* '^[a-zA-Z0-9_]+$'::"text")),
    CONSTRAINT "username_length" CHECK ((("char_length"("username") >= 3) AND ("char_length"("username") <= 20)))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


COMMENT ON TABLE "public"."profiles" IS 'Extended user profiles with privacy settings and statistics';



COMMENT ON COLUMN "public"."profiles"."username" IS 'Unique username, 3-20 chars, alphanumeric + underscore';



COMMENT ON COLUMN "public"."profiles"."display_name" IS 'Display name shown in UI (can have spaces, capitals)';



COMMENT ON COLUMN "public"."profiles"."is_profile_public" IS 'Whether profile is visible to non-followers';



COMMENT ON COLUMN "public"."profiles"."average_rating" IS 'Average of all user ratings (auto-calculated)';



COMMENT ON COLUMN "public"."profiles"."is_pro" IS 'Mirrored from RevenueCat by the revenuecat-webhook function. Never written by clients.';



COMMENT ON COLUMN "public"."profiles"."pro_event_at" IS 'event_timestamp_ms des RevenueCat-Ereignisses, das is_pro zuletzt geschrieben hat. -infinity heißt: noch keines. Nur die revenuecat-webhook-Function schreibt hier; ältere Ereignisse werden verworfen.';



CREATE OR REPLACE FUNCTION "public"."blocked_profiles"() RETURNS SETOF "public"."profiles"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select p.*
  from public.user_blocks b
  join public.profiles p on p.id = b.blocked_id
  where b.blocker_id = auth.uid()
  order by p.username;
$$;


ALTER FUNCTION "public"."blocked_profiles"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_view_user_data"("target_user_id" "uuid", "data_type" "text") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
  is_owner BOOLEAN;
  user_public BOOLEAN;
  data_public BOOLEAN;
BEGIN
  is_owner := (auth.uid() = target_user_id);
  IF is_owner THEN
    RETURN true;
  END IF;

  -- Select from 'profiles'
  SELECT
    is_profile_public,
    CASE data_type
      WHEN 'wishlist' THEN show_wishlist
      WHEN 'rated' THEN show_rated_games
      WHEN 'recommended' THEN show_recommended_games
      WHEN 'top_three' THEN show_top_three
      ELSE false
    END
  INTO user_public, data_public
  FROM public.profiles
  WHERE id = target_user_id;

  RETURN (user_public AND data_public);
END;
$$;


ALTER FUNCTION "public"."can_view_user_data"("target_user_id" "uuid", "data_type" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."can_view_user_data"("target_user_id" "uuid", "data_type" "text") IS 'Checks if current user can view another user''s game data based on privacy settings';



CREATE OR REPLACE FUNCTION "public"."cleanup_old_activity"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Delete activity older than 6 months
  DELETE FROM public.user_activity
  WHERE created_at < NOW() - INTERVAL '6 months';

  -- Delete old search queries (older than 3 months)
  DELETE FROM public.user_search_queries
  WHERE created_at < NOW() - INTERVAL '3 months';

  RAISE NOTICE 'Cleaned up old activity and search queries';
END;
$$;


ALTER FUNCTION "public"."cleanup_old_activity"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."cleanup_old_activity"() IS 'Maintenance function to cleanup old activity data';



CREATE OR REPLACE FUNCTION "public"."delete_own_account"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'auth'
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


ALTER FUNCTION "public"."delete_own_account"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."enforce_collection_limit"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."enforce_collection_limit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_following_activity_feed"("p_user_id" "uuid", "p_limit" integer DEFAULT 20, "p_offset" integer DEFAULT 0) RETURNS TABLE("activity_id" "uuid", "user_id" "uuid", "username" "text", "avatar_url" "text", "activity_type" "text", "game_id" integer, "metadata" "jsonb", "created_at" timestamp with time zone)
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id as activity_id,
    a.user_id,
    u.username,
    u.avatar_url,
    a.activity_type,
    a.game_id,
    a.metadata,
    a.created_at
  FROM public.user_activity a
  -- FIX: Changed 'public.users' to 'public.profiles'
  INNER JOIN public.profiles u ON u.id = a.user_id
  WHERE a.user_id IN (
    SELECT following_id
    FROM public.user_follows
    WHERE follower_id = p_user_id
  )
  AND a.is_public = true
  ORDER BY a.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;


ALTER FUNCTION "public"."get_following_activity_feed"("p_user_id" "uuid", "p_limit" integer, "p_offset" integer) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_following_activity_feed"("p_user_id" "uuid", "p_limit" integer, "p_offset" integer) IS 'Returns activity feed from users that p_user_id follows';



CREATE OR REPLACE FUNCTION "public"."get_mutual_followers"("p_user1_id" "uuid", "p_user2_id" "uuid") RETURNS TABLE("id" "uuid", "username" "text", "display_name" "text", "avatar_url" "text")
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id,
    u.username,
    u.display_name,
    u.avatar_url
  -- FIX: Changed 'public.users' to 'public.profiles'
  FROM public.profiles u
  WHERE u.id IN (
    -- Users who follow both user1 and user2
    SELECT f1.follower_id
    FROM public.user_follows f1
    INNER JOIN public.user_follows f2
      ON f1.follower_id = f2.follower_id
    WHERE f1.following_id = p_user1_id
    AND f2.following_id = p_user2_id
  )
  AND u.is_profile_public = true
  ORDER BY u.followers_count DESC;
END;
$$;


ALTER FUNCTION "public"."get_mutual_followers"("p_user1_id" "uuid", "p_user2_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_mutual_followers"("p_user1_id" "uuid", "p_user2_id" "uuid") IS 'Returns users who follow both specified users';



CREATE OR REPLACE FUNCTION "public"."get_popular_users"("p_limit" integer DEFAULT 20, "p_offset" integer DEFAULT 0, "p_min_followers" integer DEFAULT 1) RETURNS TABLE("id" "uuid", "username" "text", "display_name" "text", "avatar_url" "text", "bio" "text", "followers_count" integer, "total_games_rated" integer, "average_rating" numeric)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id,
    u.username,
    u.display_name,
    u.avatar_url,
    u.bio,
    u.followers_count,
    u.total_games_rated,
    u.average_rating
  FROM public.profiles u
  WHERE u.is_profile_public = true
    AND u.followers_count >= p_min_followers
    AND NOT public.is_blocked_with(u.id)
  ORDER BY
    u.followers_count DESC,
    u.total_games_rated DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;


ALTER FUNCTION "public"."get_popular_users"("p_limit" integer, "p_offset" integer, "p_min_followers" integer) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_popular_users"("p_limit" integer, "p_offset" integer, "p_min_followers" integer) IS 'Returns popular users sorted by follower count';



CREATE OR REPLACE FUNCTION "public"."get_user_collection_stats"("p_user_id" "uuid") RETURNS TABLE("total_wishlisted" integer, "total_rated" integer, "total_recommended" integer, "average_rating" numeric, "highest_rating" numeric, "lowest_rating" numeric, "rating_distribution" "jsonb", "recent_activity_count" integer)
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    -- Counts
    COUNT(*) FILTER (WHERE is_wishlisted = true)::INTEGER as total_wishlisted,
    COUNT(*) FILTER (WHERE is_rated = true)::INTEGER as total_rated,
    COUNT(*) FILTER (WHERE is_recommended = true)::INTEGER as total_recommended,

    -- Rating stats
    AVG(rating) FILTER (WHERE is_rated = true)::DECIMAL(3,1) as average_rating,
    MAX(rating) FILTER (WHERE is_rated = true)::DECIMAL(3,1) as highest_rating,
    MIN(rating) FILTER (WHERE is_rated = true)::DECIMAL(3,1) as lowest_rating,

    -- Rating distribution (histogram)
    jsonb_object_agg(
      rating_bucket,
      bucket_count
    ) FILTER (WHERE rating_bucket IS NOT NULL) as rating_distribution,

    -- Recent activity (last 7 days)
    COUNT(*) FILTER (WHERE updated_at > NOW() - INTERVAL '7 days')::INTEGER as recent_activity_count

  FROM public.user_games ug
  LEFT JOIN LATERAL (
    SELECT
      FLOOR(ug.rating)::TEXT as rating_bucket,
      1 as bucket_count
    WHERE ug.is_rated = true
  ) rating_buckets ON true
  WHERE ug.user_id = p_user_id;
END;
$$;


ALTER FUNCTION "public"."get_user_collection_stats"("p_user_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_collection_stats"("p_user_id" "uuid") IS 'Returns comprehensive collection statistics for a user';



CREATE OR REPLACE FUNCTION "public"."get_user_game_enrichment_data"("p_user_id" "uuid", "p_game_ids" integer[]) RETURNS TABLE("game_id" integer, "is_wishlisted" boolean, "is_recommended" boolean, "is_rated" boolean, "rating" numeric, "rated_at" timestamp with time zone, "wishlisted_at" timestamp with time zone, "recommended_at" timestamp with time zone, "is_in_top_three" boolean, "top_three_position" integer)
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
BEGIN
  -- !!! SECURITY FIX !!!
  -- Verhindert, dass man Daten fremder User abfragt
  IF p_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Access denied: You can only enrich your own game data.';
  END IF;

  RETURN QUERY
  WITH top_three_data AS (
    SELECT t.game_1_id, t.game_2_id, t.game_3_id
    FROM public.user_top_three t
    WHERE t.user_id = p_user_id
  ),
  game_data AS (
    SELECT
      g.game_id,
      COALESCE(ug.is_wishlisted, false) as is_wishlisted,
      COALESCE(ug.is_recommended, false) as is_recommended,
      COALESCE(ug.is_rated, false) as is_rated,
      ug.rating,
      ug.rated_at,
      ug.wishlisted_at,
      ug.recommended_at,
      CASE
        WHEN t.game_1_id = g.game_id OR t.game_2_id = g.game_id OR t.game_3_id = g.game_id THEN true
        ELSE false
      END as is_in_top_three,
      CASE
        WHEN t.game_1_id = g.game_id THEN 1
        WHEN t.game_2_id = g.game_id THEN 2
        WHEN t.game_3_id = g.game_id THEN 3
        ELSE NULL
      END as top_three_position
    FROM unnest(p_game_ids) AS g(game_id)
    LEFT JOIN public.user_games ug
      ON ug.game_id = g.game_id
      AND ug.user_id = p_user_id
    CROSS JOIN top_three_data t
  )
  SELECT * FROM game_data;
END;
$$;


ALTER FUNCTION "public"."get_user_game_enrichment_data"("p_user_id" "uuid", "p_game_ids" integer[]) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_game_enrichment_data"("p_user_id" "uuid", "p_game_ids" integer[]) IS 'Efficiently enriches game list with user data in a single query (40x faster than N+1 queries)';



CREATE OR REPLACE FUNCTION "public"."get_user_relationship"("p_current_user_id" "uuid", "p_target_user_id" "uuid") RETURNS TABLE("is_following" boolean, "is_followed_by" boolean, "is_mutual" boolean, "can_view_profile" boolean)
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
  v_is_following BOOLEAN;
  v_is_followed_by BOOLEAN;
  v_target_is_public BOOLEAN;
BEGIN
  -- Check if current user follows target
  SELECT EXISTS (
    SELECT 1 FROM public.user_follows
    WHERE follower_id = p_current_user_id
    AND following_id = p_target_user_id
  ) INTO v_is_following;

  -- Check if target follows current user
  SELECT EXISTS (
    SELECT 1 FROM public.user_follows
    WHERE follower_id = p_target_user_id
    AND following_id = p_current_user_id
  ) INTO v_is_followed_by;

  -- Check if target profile is public
  -- FIX: Changed 'public.users' to 'public.profiles'
  SELECT is_profile_public INTO v_target_is_public
  FROM public.profiles
  WHERE id = p_target_user_id;

  RETURN QUERY SELECT
    v_is_following,
    v_is_followed_by,
    v_is_following AND v_is_followed_by as is_mutual,
    v_target_is_public OR p_current_user_id = p_target_user_id as can_view_profile;
END;
$$;


ALTER FUNCTION "public"."get_user_relationship"("p_current_user_id" "uuid", "p_target_user_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_relationship"("p_current_user_id" "uuid", "p_target_user_id" "uuid") IS 'Returns relationship status between two users';



CREATE OR REPLACE FUNCTION "public"."guard_pro_columns"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."guard_pro_columns"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."handle_new_user"() IS 'Automatically creates user profile when auth user is created';



CREATE OR REPLACE FUNCTION "public"."is_blocked_with"("other_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select exists (
    select 1 from public.user_blocks b
    where (b.blocker_id = auth.uid() and b.blocked_id = other_id)
       or (b.blocker_id = other_id    and b.blocked_id = auth.uid())
  );
$$;


ALTER FUNCTION "public"."is_blocked_with"("other_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_pro_user"("uid" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT COALESCE(
    (SELECT is_pro AND (pro_expires_at IS NULL OR pro_expires_at > now())
     FROM public.profiles WHERE id = uid),
    false
  );
$$;


ALTER FUNCTION "public"."is_pro_user"("uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_username_available"("username_to_check" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."is_username_available"("username_to_check" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_username_available"("username_to_check" "text") IS 'Checks if a username is available for registration (bypasses RLS)';



CREATE OR REPLACE FUNCTION "public"."log_follow_activity"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."log_follow_activity"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."log_follow_activity"() IS 'Logs when user follows another user';



CREATE OR REPLACE FUNCTION "public"."log_top_three_activity"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."log_top_three_activity"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."log_top_three_activity"() IS 'Logs when user updates their top 3 games';



CREATE OR REPLACE FUNCTION "public"."log_user_activity"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."log_user_activity"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."log_user_activity"() IS 'Automatically logs user activity to activity feed';



CREATE OR REPLACE FUNCTION "public"."my_follow_profiles"("p_direction" "text", "p_limit" integer DEFAULT 50, "p_offset" integer DEFAULT 0) RETURNS TABLE("id" "uuid", "username" "text", "display_name" "text", "avatar_url" "text", "is_profile_public" boolean, "created_at" timestamp with time zone, "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated' USING ERRCODE = '28000';
  END IF;

  IF p_direction NOT IN ('followers', 'following') THEN
    RAISE EXCEPTION 'direction must be followers or following'
      USING ERRCODE = '22023';
  END IF;

  RETURN QUERY
  SELECT p.id, p.username, p.display_name, p.avatar_url, p.is_profile_public,
         p.created_at, p.updated_at
  FROM public.user_follows f
  JOIN public.profiles p
    ON p.id = CASE WHEN p_direction = 'followers'
                   THEN f.follower_id ELSE f.following_id END
  WHERE CASE WHEN p_direction = 'followers'
             THEN f.following_id ELSE f.follower_id END = uid
    -- A blocked account is not on your lists at all: block_user dissolves the
    -- relationship, so this is belt and braces rather than a second rule.
    AND NOT public.is_blocked_with(p.id)
  ORDER BY p.username
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;


ALTER FUNCTION "public"."my_follow_profiles"("p_direction" "text", "p_limit" integer, "p_offset" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_users"("p_query" "text", "p_limit" integer DEFAULT 20, "p_offset" integer DEFAULT 0) RETURNS TABLE("id" "uuid", "username" "text", "display_name" "text", "avatar_url" "text", "bio" "text", "followers_count" integer, "is_profile_public" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id,
    u.username,
    u.display_name,
    u.avatar_url,
    u.bio,
    u.followers_count,
    u.is_profile_public
  FROM public.profiles u
  WHERE (
      u.username ILIKE '%' || p_query || '%' OR
      u.display_name ILIKE '%' || p_query || '%'
    )
    AND u.is_profile_public = true
    AND NOT public.is_blocked_with(u.id)
  ORDER BY
    CASE WHEN LOWER(u.username) = LOWER(p_query) THEN 0 ELSE 1 END,
    u.followers_count DESC,
    u.username ASC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;


ALTER FUNCTION "public"."search_users"("p_query" "text", "p_limit" integer, "p_offset" integer) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."search_users"("p_query" "text", "p_limit" integer, "p_offset" integer) IS 'Searches users by username or display name with relevance ranking';



CREATE OR REPLACE FUNCTION "public"."set_user_game_timestamps"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Set timestamps based on flags
  IF NEW.is_wishlisted AND NEW.wishlisted_at IS NULL THEN
    NEW.wishlisted_at := NOW();
  END IF;

  IF NEW.is_recommended AND NEW.recommended_at IS NULL THEN
    NEW.recommended_at := NOW();
  END IF;

  IF NEW.is_rated AND NEW.rated_at IS NULL THEN
    NEW.rated_at := NOW();
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_user_game_timestamps"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."set_user_game_timestamps"() IS 'Automatically sets collection timestamps';



CREATE OR REPLACE FUNCTION "public"."update_follow_counts"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."update_follow_counts"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_follow_counts"() IS 'Keeps follower/following counters in sync';



CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_updated_at_column"() IS 'Automatically updates updated_at timestamp on row modification';



CREATE OR REPLACE FUNCTION "public"."update_user_game_stats"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
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


ALTER FUNCTION "public"."update_user_game_stats"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_user_game_stats"() IS 'Keeps user collection counters in sync automatically';



CREATE TABLE IF NOT EXISTS "public"."user_activity" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "activity_type" "text" NOT NULL,
    "game_id" integer,
    "metadata" "jsonb",
    "is_public" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "valid_activity_type" CHECK (("activity_type" = ANY (ARRAY['rated'::"text", 'recommended'::"text", 'wishlisted'::"text", 'updated_top_three'::"text", 'followed_user'::"text", 'updated_profile'::"text"])))
);


ALTER TABLE "public"."user_activity" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_activity" IS 'User activity feed for social features';



COMMENT ON COLUMN "public"."user_activity"."activity_type" IS 'Type of activity performed';



COMMENT ON COLUMN "public"."user_activity"."metadata" IS 'Additional context in JSON format';



COMMENT ON COLUMN "public"."user_activity"."is_public" IS 'Whether activity is visible to followers';



CREATE TABLE IF NOT EXISTS "public"."user_blocks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "blocker_id" "uuid" NOT NULL,
    "blocked_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "no_self_block" CHECK (("blocker_id" <> "blocked_id"))
);


ALTER TABLE "public"."user_blocks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_collection_games" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "collection_id" "uuid" NOT NULL,
    "game_id" integer NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    "added_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_collection_games" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_collection_games" IS 'Membership + ordering of games within a user collection';



CREATE TABLE IF NOT EXISTS "public"."user_collections" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "cover_game_id" integer,
    "is_public" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "collection_description_length" CHECK ((("description" IS NULL) OR ("char_length"("description") <= 500))),
    CONSTRAINT "collection_name_length" CHECK ((("char_length"("name") >= 1) AND ("char_length"("name") <= 60)))
);


ALTER TABLE "public"."user_collections" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_collections" IS 'User-created custom collections of games (separate from system lists)';



CREATE TABLE IF NOT EXISTS "public"."user_follows" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "follower_id" "uuid" NOT NULL,
    "following_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "no_self_follow" CHECK (("follower_id" <> "following_id"))
);


ALTER TABLE "public"."user_follows" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_follows" IS 'User follow relationships (no approval required)';



COMMENT ON COLUMN "public"."user_follows"."follower_id" IS 'User who is following';



COMMENT ON COLUMN "public"."user_follows"."following_id" IS 'User being followed';



CREATE TABLE IF NOT EXISTS "public"."user_games" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "game_id" integer NOT NULL,
    "is_wishlisted" boolean DEFAULT false NOT NULL,
    "is_recommended" boolean DEFAULT false NOT NULL,
    "is_rated" boolean DEFAULT false NOT NULL,
    "rating" numeric(3,1),
    "review_text" "text",
    "wishlisted_at" timestamp with time zone,
    "recommended_at" timestamp with time zone,
    "rated_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "at_least_one_flag" CHECK ((("is_wishlisted" = true) OR ("is_recommended" = true) OR ("is_rated" = true))),
    CONSTRAINT "rated_at_consistency" CHECK (((("is_rated" = true) AND ("rated_at" IS NOT NULL)) OR ("is_rated" = false))),
    CONSTRAINT "rating_consistency" CHECK (((("is_rated" = true) AND ("rating" IS NOT NULL)) OR (("is_rated" = false) AND ("rating" IS NULL)))),
    CONSTRAINT "rating_range" CHECK ((("rating" IS NULL) OR (("rating" >= (0)::numeric) AND ("rating" <= (10)::numeric)))),
    CONSTRAINT "recommended_at_consistency" CHECK (((("is_recommended" = true) AND ("recommended_at" IS NOT NULL)) OR ("is_recommended" = false))),
    CONSTRAINT "review_text_length" CHECK ((("review_text" IS NULL) OR ("char_length"("review_text") <= 2000))),
    CONSTRAINT "wishlisted_at_consistency" CHECK (((("is_wishlisted" = true) AND ("wishlisted_at" IS NOT NULL)) OR ("is_wishlisted" = false)))
);


ALTER TABLE "public"."user_games" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_games" IS 'Single table for all user-game interactions (wishlist, ratings, recommendations)';



COMMENT ON COLUMN "public"."user_games"."rating" IS 'User rating from 0.0 to 10.0 in 0.5 increments';



COMMENT ON COLUMN "public"."user_games"."review_text" IS 'Optional user review/notes about the game';



CREATE TABLE IF NOT EXISTS "public"."user_relationships" (
    "follower_id" "uuid" NOT NULL,
    "following_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "no_self_follow" CHECK (("follower_id" <> "following_id"))
);


ALTER TABLE "public"."user_relationships" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_reports" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "reporter_id" "uuid" NOT NULL,
    "reported_id" "uuid" NOT NULL,
    "reason" character varying(50) NOT NULL,
    "description" "text",
    "status" character varying(20) DEFAULT 'pending'::character varying,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "resolved_at" timestamp with time zone,
    "resolved_by" "uuid",
    CONSTRAINT "no_self_report" CHECK (("reporter_id" <> "reported_id")),
    CONSTRAINT "valid_reason" CHECK ((("reason")::"text" = ANY (ARRAY[('spam'::character varying)::"text", ('harassment'::character varying)::"text", ('inappropriate_content'::character varying)::"text", ('fake_account'::character varying)::"text", ('other'::character varying)::"text"]))),
    CONSTRAINT "valid_status" CHECK ((("status")::"text" = ANY (ARRAY[('pending'::character varying)::"text", ('resolved'::character varying)::"text", ('dismissed'::character varying)::"text"])))
);


ALTER TABLE "public"."user_reports" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_search_queries" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "query" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "query_length" CHECK (("char_length"("query") <= 200))
);


ALTER TABLE "public"."user_search_queries" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_search_queries" IS 'User search history for recent searches feature';



CREATE TABLE IF NOT EXISTS "public"."user_top_three" (
    "user_id" "uuid" NOT NULL,
    "game_1_id" integer,
    "game_2_id" integer,
    "game_3_id" integer,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "different_games" CHECK (((("game_1_id" IS NULL) OR ("game_2_id" IS NULL) OR ("game_1_id" <> "game_2_id")) AND (("game_2_id" IS NULL) OR ("game_3_id" IS NULL) OR ("game_2_id" <> "game_3_id")) AND (("game_1_id" IS NULL) OR ("game_3_id" IS NULL) OR ("game_1_id" <> "game_3_id"))))
);


ALTER TABLE "public"."user_top_three" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_top_three" IS 'User''s top 3 favorite games';



COMMENT ON COLUMN "public"."user_top_three"."game_1_id" IS 'First place game';



COMMENT ON COLUMN "public"."user_top_three"."game_2_id" IS 'Second place game';



COMMENT ON COLUMN "public"."user_top_three"."game_3_id" IS 'Third place game';



ALTER TABLE ONLY "public"."user_activity"
    ADD CONSTRAINT "user_activity_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_blocks"
    ADD CONSTRAINT "user_blocks_blocker_id_blocked_id_key" UNIQUE ("blocker_id", "blocked_id");



ALTER TABLE ONLY "public"."user_blocks"
    ADD CONSTRAINT "user_blocks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_collection_games"
    ADD CONSTRAINT "user_collection_games_collection_id_game_id_key" UNIQUE ("collection_id", "game_id");



ALTER TABLE ONLY "public"."user_collection_games"
    ADD CONSTRAINT "user_collection_games_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_collections"
    ADD CONSTRAINT "user_collections_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_follows"
    ADD CONSTRAINT "user_follows_follower_id_following_id_key" UNIQUE ("follower_id", "following_id");



ALTER TABLE ONLY "public"."user_follows"
    ADD CONSTRAINT "user_follows_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_games"
    ADD CONSTRAINT "user_games_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_games"
    ADD CONSTRAINT "user_games_user_id_game_id_key" UNIQUE ("user_id", "game_id");



ALTER TABLE ONLY "public"."user_relationships"
    ADD CONSTRAINT "user_relationships_pkey" PRIMARY KEY ("follower_id", "following_id");



ALTER TABLE ONLY "public"."user_reports"
    ADD CONSTRAINT "user_reports_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_search_queries"
    ADD CONSTRAINT "user_search_queries_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_top_three"
    ADD CONSTRAINT "user_top_three_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "users_username_key" UNIQUE ("username");



CREATE INDEX "idx_activity_by_game" ON "public"."user_activity" USING "btree" ("game_id", "created_at" DESC) WHERE ("game_id" IS NOT NULL);



CREATE INDEX "idx_activity_by_type" ON "public"."user_activity" USING "btree" ("activity_type", "created_at" DESC);



CREATE INDEX "idx_activity_public_feed" ON "public"."user_activity" USING "btree" ("is_public", "created_at" DESC) WHERE ("is_public" = true);



COMMENT ON INDEX "public"."idx_activity_public_feed" IS 'Public activity feed for social features';



CREATE INDEX "idx_activity_user_public" ON "public"."user_activity" USING "btree" ("user_id", "is_public", "created_at" DESC) WHERE ("is_public" = true);



CREATE INDEX "idx_activity_user_timeline" ON "public"."user_activity" USING "btree" ("user_id", "created_at" DESC);



COMMENT ON INDEX "public"."idx_activity_user_timeline" IS 'User activity timeline';



CREATE INDEX "idx_follows_check" ON "public"."user_follows" USING "btree" ("follower_id", "following_id");



COMMENT ON INDEX "public"."idx_follows_check" IS 'Instant follow status check';



CREATE INDEX "idx_follows_follower" ON "public"."user_follows" USING "btree" ("follower_id", "created_at" DESC);



COMMENT ON INDEX "public"."idx_follows_follower" IS 'Fast following list queries';



CREATE INDEX "idx_follows_following" ON "public"."user_follows" USING "btree" ("following_id", "created_at" DESC);



COMMENT ON INDEX "public"."idx_follows_following" IS 'Fast follower list queries';



CREATE INDEX "idx_follows_recent" ON "public"."user_follows" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_relationships_follower" ON "public"."user_relationships" USING "btree" ("follower_id");



CREATE INDEX "idx_relationships_following" ON "public"."user_relationships" USING "btree" ("following_id");



CREATE INDEX "idx_search_queries_query" ON "public"."user_search_queries" USING "btree" ("query", "created_at" DESC);



CREATE INDEX "idx_search_queries_user_recent" ON "public"."user_search_queries" USING "btree" ("user_id", "created_at" DESC);



COMMENT ON INDEX "public"."idx_search_queries_user_recent" IS 'User search history';



CREATE INDEX "idx_user_blocks_blocked" ON "public"."user_blocks" USING "btree" ("blocked_id");



CREATE INDEX "idx_user_blocks_blocker" ON "public"."user_blocks" USING "btree" ("blocker_id");



CREATE INDEX "idx_user_collection_games_collection" ON "public"."user_collection_games" USING "btree" ("collection_id");



CREATE INDEX "idx_user_collections_public" ON "public"."user_collections" USING "btree" ("is_public") WHERE ("is_public" = true);



CREATE INDEX "idx_user_collections_user_id" ON "public"."user_collections" USING "btree" ("user_id");



CREATE INDEX "idx_user_games_game_id" ON "public"."user_games" USING "btree" ("game_id");



CREATE INDEX "idx_user_games_high_ratings" ON "public"."user_games" USING "btree" ("user_id", "game_id", "rating" DESC) WHERE (("is_rated" = true) AND ("rating" >= 8.0));



COMMENT ON INDEX "public"."idx_user_games_high_ratings" IS 'Quickly find highly rated games';



CREATE INDEX "idx_user_games_rated" ON "public"."user_games" USING "btree" ("user_id", "game_id", "rating" DESC, "rated_at" DESC) WHERE ("is_rated" = true);



COMMENT ON INDEX "public"."idx_user_games_rated" IS 'Fast rated games queries with rating ordering';



CREATE INDEX "idx_user_games_recent_rated" ON "public"."user_games" USING "btree" ("user_id", "rated_at" DESC) WHERE ("is_rated" = true);



CREATE INDEX "idx_user_games_recent_recommended" ON "public"."user_games" USING "btree" ("user_id", "recommended_at" DESC) WHERE ("is_recommended" = true);



CREATE INDEX "idx_user_games_recent_wishlisted" ON "public"."user_games" USING "btree" ("user_id", "wishlisted_at" DESC) WHERE ("is_wishlisted" = true);



CREATE INDEX "idx_user_games_recommended" ON "public"."user_games" USING "btree" ("user_id", "game_id", "recommended_at" DESC) WHERE ("is_recommended" = true);



COMMENT ON INDEX "public"."idx_user_games_recommended" IS 'Fast recommendation queries';



CREATE INDEX "idx_user_games_updated" ON "public"."user_games" USING "btree" ("user_id", "updated_at" DESC);



CREATE INDEX "idx_user_games_user_game" ON "public"."user_games" USING "btree" ("user_id", "game_id");



CREATE INDEX "idx_user_games_user_id" ON "public"."user_games" USING "btree" ("user_id");



CREATE INDEX "idx_user_games_wishlisted" ON "public"."user_games" USING "btree" ("user_id", "game_id", "wishlisted_at" DESC) WHERE ("is_wishlisted" = true);



COMMENT ON INDEX "public"."idx_user_games_wishlisted" IS 'Fast wishlist queries with timestamp ordering';



CREATE INDEX "idx_user_reports_created_at" ON "public"."user_reports" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_user_reports_reported_id" ON "public"."user_reports" USING "btree" ("reported_id");



CREATE INDEX "idx_user_reports_status" ON "public"."user_reports" USING "btree" ("status");



CREATE INDEX "idx_user_top_three_game_1" ON "public"."user_top_three" USING "btree" ("game_1_id") WHERE ("game_1_id" IS NOT NULL);



CREATE INDEX "idx_user_top_three_game_2" ON "public"."user_top_three" USING "btree" ("game_2_id") WHERE ("game_2_id" IS NOT NULL);



CREATE INDEX "idx_user_top_three_game_3" ON "public"."user_top_three" USING "btree" ("game_3_id") WHERE ("game_3_id" IS NOT NULL);



CREATE INDEX "idx_user_top_three_updated" ON "public"."user_top_three" USING "btree" ("updated_at" DESC);



CREATE INDEX "idx_users_country" ON "public"."profiles" USING "btree" ("country") WHERE ("country" IS NOT NULL);



CREATE INDEX "idx_users_popular" ON "public"."profiles" USING "btree" ("followers_count" DESC) WHERE ("followers_count" > 0);



COMMENT ON INDEX "public"."idx_users_popular" IS 'Find users by follower count';



CREATE INDEX "idx_users_privacy_settings" ON "public"."profiles" USING "btree" ("id", "is_profile_public", "show_wishlist", "show_rated_games", "show_recommended_games", "show_top_three");



CREATE INDEX "idx_users_public_profiles" ON "public"."profiles" USING "btree" ("is_profile_public", "created_at" DESC) WHERE ("is_profile_public" = true);



COMMENT ON INDEX "public"."idx_users_public_profiles" IS 'Find public profiles quickly';



CREATE INDEX "idx_users_username_lower" ON "public"."profiles" USING "btree" ("lower"("username"));



COMMENT ON INDEX "public"."idx_users_username_lower" IS 'Case-insensitive username search';



CREATE OR REPLACE TRIGGER "log_follow_activity" AFTER INSERT ON "public"."user_follows" FOR EACH ROW EXECUTE FUNCTION "public"."log_follow_activity"();



CREATE OR REPLACE TRIGGER "log_top_three_activity" AFTER INSERT OR UPDATE ON "public"."user_top_three" FOR EACH ROW EXECUTE FUNCTION "public"."log_top_three_activity"();



CREATE OR REPLACE TRIGGER "log_user_activity_insert" AFTER INSERT ON "public"."user_games" FOR EACH ROW EXECUTE FUNCTION "public"."log_user_activity"();



CREATE OR REPLACE TRIGGER "log_user_activity_update" AFTER UPDATE ON "public"."user_games" FOR EACH ROW WHEN ((("old"."is_rated" IS DISTINCT FROM "new"."is_rated") OR ("old"."is_recommended" IS DISTINCT FROM "new"."is_recommended") OR ("old"."is_wishlisted" IS DISTINCT FROM "new"."is_wishlisted") OR ("old"."rating" IS DISTINCT FROM "new"."rating"))) EXECUTE FUNCTION "public"."log_user_activity"();



CREATE OR REPLACE TRIGGER "profiles_guard_pro_columns" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."guard_pro_columns"();



CREATE OR REPLACE TRIGGER "set_user_game_timestamps" BEFORE INSERT OR UPDATE ON "public"."user_games" FOR EACH ROW EXECUTE FUNCTION "public"."set_user_game_timestamps"();



CREATE OR REPLACE TRIGGER "update_follow_counts_delete" AFTER DELETE ON "public"."user_follows" FOR EACH ROW EXECUTE FUNCTION "public"."update_follow_counts"();



CREATE OR REPLACE TRIGGER "update_follow_counts_insert" AFTER INSERT ON "public"."user_follows" FOR EACH ROW EXECUTE FUNCTION "public"."update_follow_counts"();



CREATE OR REPLACE TRIGGER "update_user_collections_updated_at" BEFORE UPDATE ON "public"."user_collections" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_user_game_stats_delete" AFTER DELETE ON "public"."user_games" FOR EACH ROW EXECUTE FUNCTION "public"."update_user_game_stats"();



CREATE OR REPLACE TRIGGER "update_user_game_stats_insert" AFTER INSERT ON "public"."user_games" FOR EACH ROW EXECUTE FUNCTION "public"."update_user_game_stats"();



CREATE OR REPLACE TRIGGER "update_user_game_stats_update" AFTER UPDATE ON "public"."user_games" FOR EACH ROW WHEN ((("old"."is_rated" IS DISTINCT FROM "new"."is_rated") OR ("old"."is_wishlisted" IS DISTINCT FROM "new"."is_wishlisted") OR ("old"."is_recommended" IS DISTINCT FROM "new"."is_recommended") OR ("old"."rating" IS DISTINCT FROM "new"."rating"))) EXECUTE FUNCTION "public"."update_user_game_stats"();



CREATE OR REPLACE TRIGGER "update_user_games_updated_at" BEFORE UPDATE ON "public"."user_games" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_user_top_three_updated_at" BEFORE UPDATE ON "public"."user_top_three" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_users_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "user_collections_enforce_limit" BEFORE INSERT ON "public"."user_collections" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_collection_limit"();



ALTER TABLE ONLY "public"."user_activity"
    ADD CONSTRAINT "user_activity_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_blocks"
    ADD CONSTRAINT "user_blocks_blocked_id_fkey" FOREIGN KEY ("blocked_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_blocks"
    ADD CONSTRAINT "user_blocks_blocker_id_fkey" FOREIGN KEY ("blocker_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_collection_games"
    ADD CONSTRAINT "user_collection_games_collection_id_fkey" FOREIGN KEY ("collection_id") REFERENCES "public"."user_collections"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_collections"
    ADD CONSTRAINT "user_collections_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_follows"
    ADD CONSTRAINT "user_follows_follower_id_fkey" FOREIGN KEY ("follower_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_follows"
    ADD CONSTRAINT "user_follows_following_id_fkey" FOREIGN KEY ("following_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_games"
    ADD CONSTRAINT "user_games_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_reports"
    ADD CONSTRAINT "user_reports_reported_id_fkey" FOREIGN KEY ("reported_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_reports"
    ADD CONSTRAINT "user_reports_reporter_id_fkey" FOREIGN KEY ("reporter_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_search_queries"
    ADD CONSTRAINT "user_search_queries_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_top_three"
    ADD CONSTRAINT "user_top_three_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Anyone can view follows" ON "public"."user_follows" FOR SELECT USING (true);



CREATE POLICY "Anyone can view public collections" ON "public"."user_collections" FOR SELECT USING (("is_public" = true));



CREATE POLICY "Owner can add games to own collections" ON "public"."user_collection_games" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_collections" "c"
  WHERE (("c"."id" = "user_collection_games"."collection_id") AND ("c"."user_id" = "auth"."uid"())))));



CREATE POLICY "Owner can delete own collections" ON "public"."user_collections" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Owner can insert own collections" ON "public"."user_collections" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Owner can remove games from own collections" ON "public"."user_collection_games" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."user_collections" "c"
  WHERE (("c"."id" = "user_collection_games"."collection_id") AND ("c"."user_id" = "auth"."uid"())))));



CREATE POLICY "Owner can update games in own collections" ON "public"."user_collection_games" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."user_collections" "c"
  WHERE (("c"."id" = "user_collection_games"."collection_id") AND ("c"."user_id" = "auth"."uid"()))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_collections" "c"
  WHERE (("c"."id" = "user_collection_games"."collection_id") AND ("c"."user_id" = "auth"."uid"())))));



CREATE POLICY "Owner can update own collections" ON "public"."user_collections" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Owner can view own collections" ON "public"."user_collections" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can block others" ON "public"."user_blocks" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "blocker_id"));



CREATE POLICY "Users can delete own games" ON "public"."user_games" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete own search history" ON "public"."user_search_queries" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete own top three" ON "public"."user_top_three" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can follow others" ON "public"."user_follows" FOR INSERT WITH CHECK ((("auth"."uid"() = "follower_id") AND ("follower_id" <> "following_id")));



CREATE POLICY "Users can follow others" ON "public"."user_relationships" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "follower_id"));



CREATE POLICY "Users can insert own games" ON "public"."user_games" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert own searches" ON "public"."user_search_queries" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert own top three" ON "public"."user_top_three" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can report others" ON "public"."user_reports" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "reporter_id"));



CREATE POLICY "Users can unblock others" ON "public"."user_blocks" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "blocker_id"));



CREATE POLICY "Users can unfollow" ON "public"."user_relationships" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "follower_id"));



CREATE POLICY "Users can unfollow others" ON "public"."user_follows" FOR DELETE USING (("auth"."uid"() = "follower_id"));



CREATE POLICY "Users can update own games" ON "public"."user_games" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update own top three" ON "public"."user_top_three" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own activity" ON "public"."user_activity" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own blocks" ON "public"."user_blocks" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "blocker_id"));



CREATE POLICY "Users can view own games" ON "public"."user_games" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own reports" ON "public"."user_reports" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "reporter_id"));



CREATE POLICY "Users can view own search history" ON "public"."user_search_queries" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own top three" ON "public"."user_top_three" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view public activity" ON "public"."user_activity" FOR SELECT USING (("is_public" = true));



CREATE POLICY "Users can view public rated games" ON "public"."user_games" FOR SELECT USING ((("is_rated" = true) AND (EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "user_games"."user_id") AND ("profiles"."show_rated_games" = true) AND ("profiles"."is_profile_public" = true))))));



CREATE POLICY "Users can view public recommendations" ON "public"."user_games" FOR SELECT USING ((("is_recommended" = true) AND (EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "user_games"."user_id") AND ("profiles"."show_recommended_games" = true) AND ("profiles"."is_profile_public" = true))))));



CREATE POLICY "Users can view public top three" ON "public"."user_top_three" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "user_top_three"."user_id") AND ("profiles"."show_top_three" = true) AND ("profiles"."is_profile_public" = true)))));



CREATE POLICY "Users can view public wishlists" ON "public"."user_games" FOR SELECT USING ((("is_wishlisted" = true) AND (EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "user_games"."user_id") AND ("profiles"."show_wishlist" = true) AND ("profiles"."is_profile_public" = true))))));



CREATE POLICY "View games of accessible collections" ON "public"."user_collection_games" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_collections" "c"
  WHERE (("c"."id" = "user_collection_games"."collection_id") AND (("c"."user_id" = "auth"."uid"()) OR ("c"."is_public" = true))))));



CREATE POLICY "View relationships" ON "public"."user_relationships" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "delete_own_profile" ON "public"."profiles" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "id"));



CREATE POLICY "insert_own_profile" ON "public"."profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));



ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "select_own_profile" ON "public"."profiles" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "id"));



CREATE POLICY "select_public_profiles" ON "public"."profiles" FOR SELECT TO "authenticated" USING ((("is_profile_public" = true) AND (NOT "public"."is_blocked_with"("id"))));



CREATE POLICY "update_own_profile" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



ALTER TABLE "public"."user_activity" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_blocks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_collection_games" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_collections" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_follows" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_games" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_relationships" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_reports" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_search_queries" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_top_three" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


REVOKE USAGE ON SCHEMA "public" FROM PUBLIC;
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";






















































































































































GRANT ALL ON FUNCTION "public"."batch_get_follow_status"("p_current_user_id" "uuid", "p_target_user_ids" "uuid"[]) TO "authenticated";



REVOKE ALL ON FUNCTION "public"."block_user"("target_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."block_user"("target_id" "uuid") TO "authenticated";



GRANT SELECT,INSERT,UPDATE ON TABLE "public"."profiles" TO "service_role";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."profiles" TO "authenticated";
GRANT INSERT ON TABLE "public"."profiles" TO "anon";



REVOKE ALL ON FUNCTION "public"."blocked_profiles"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."blocked_profiles"() TO "authenticated";



REVOKE ALL ON FUNCTION "public"."delete_own_account"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."delete_own_account"() TO "authenticated";



GRANT ALL ON FUNCTION "public"."get_following_activity_feed"("p_user_id" "uuid", "p_limit" integer, "p_offset" integer) TO "authenticated";



GRANT ALL ON FUNCTION "public"."get_mutual_followers"("p_user1_id" "uuid", "p_user2_id" "uuid") TO "authenticated";



GRANT ALL ON FUNCTION "public"."get_popular_users"("p_limit" integer, "p_offset" integer, "p_min_followers" integer) TO "authenticated";



GRANT ALL ON FUNCTION "public"."get_user_collection_stats"("p_user_id" "uuid") TO "authenticated";



GRANT ALL ON FUNCTION "public"."get_user_game_enrichment_data"("p_user_id" "uuid", "p_game_ids" integer[]) TO "authenticated";



GRANT ALL ON FUNCTION "public"."get_user_relationship"("p_current_user_id" "uuid", "p_target_user_id" "uuid") TO "authenticated";



REVOKE ALL ON FUNCTION "public"."is_blocked_with"("other_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."is_blocked_with"("other_id" "uuid") TO "authenticated";



REVOKE ALL ON FUNCTION "public"."is_pro_user"("uid" "uuid") FROM PUBLIC;



GRANT ALL ON FUNCTION "public"."is_username_available"("username_to_check" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_username_available"("username_to_check" "text") TO "authenticated";



REVOKE ALL ON FUNCTION "public"."my_follow_profiles"("p_direction" "text", "p_limit" integer, "p_offset" integer) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."my_follow_profiles"("p_direction" "text", "p_limit" integer, "p_offset" integer) TO "authenticated";



GRANT ALL ON FUNCTION "public"."search_users"("p_query" "text", "p_limit" integer, "p_offset" integer) TO "authenticated";


















GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."user_activity" TO "authenticated";



GRANT SELECT,INSERT,DELETE ON TABLE "public"."user_blocks" TO "authenticated";
GRANT SELECT,DELETE ON TABLE "public"."user_blocks" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."user_collection_games" TO "authenticated";
GRANT SELECT ON TABLE "public"."user_collection_games" TO "anon";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."user_collections" TO "authenticated";
GRANT SELECT ON TABLE "public"."user_collections" TO "anon";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."user_follows" TO "authenticated";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."user_games" TO "authenticated";



GRANT SELECT,INSERT ON TABLE "public"."user_reports" TO "authenticated";
GRANT SELECT,UPDATE ON TABLE "public"."user_reports" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."user_top_three" TO "authenticated";


































