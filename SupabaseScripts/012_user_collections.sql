-- ============================================================
-- Migration 012: User Custom Collections
-- Description: User-created, named collections of games
--              (e.g. "Cozy games", "Backlog 2026"). Separate from the fixed
--              system lists (wishlist / rated / recommended / top three).
-- Author: GamerGrove
-- Date: 2026-07-22
-- ============================================================
--
-- Free tier is capped (enforced client-side today; server-side enforcement is
-- a documented follow-up). `is_public` is stored now and read by RLS so that
-- sharing (fast-follow) needs no schema change.
--
-- Apply in the Supabase SQL editor (or via the DB connection). Idempotent:
-- safe to re-run. RLS-verify afterwards with the anon key — see the block at
-- the bottom of this file.
-- ============================================================

-- ============================================================
-- 1. TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS public.user_collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  cover_game_id INTEGER,
  is_public BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT collection_name_length CHECK (
    char_length(name) BETWEEN 1 AND 60
  ),
  CONSTRAINT collection_description_length CHECK (
    description IS NULL OR char_length(description) <= 500
  )
);

COMMENT ON TABLE public.user_collections IS
  'User-created custom collections of games (separate from system lists)';

CREATE INDEX IF NOT EXISTS idx_user_collections_user_id
  ON public.user_collections(user_id);
CREATE INDEX IF NOT EXISTS idx_user_collections_public
  ON public.user_collections(is_public) WHERE is_public = true;

CREATE TABLE IF NOT EXISTS public.user_collection_games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id UUID NOT NULL
    REFERENCES public.user_collections(id) ON DELETE CASCADE,
  game_id INTEGER NOT NULL,
  position INTEGER NOT NULL DEFAULT 0,
  added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(collection_id, game_id)
);

COMMENT ON TABLE public.user_collection_games IS
  'Membership + ordering of games within a user collection';

CREATE INDEX IF NOT EXISTS idx_user_collection_games_collection
  ON public.user_collection_games(collection_id);

-- ============================================================
-- 2. TRIGGERS (reuse the shared updated_at function from migration 005)
-- ============================================================

DROP TRIGGER IF EXISTS update_user_collections_updated_at
  ON public.user_collections;
CREATE TRIGGER update_user_collections_updated_at
  BEFORE UPDATE ON public.user_collections
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- 3. GRANTS
-- ============================================================
-- anon gets SELECT only (RLS still restricts it to public rows); authenticated
-- gets full DML (RLS restricts to owned rows).

GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_collections TO authenticated;
GRANT SELECT ON public.user_collections TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_collection_games
  TO authenticated;
GRANT SELECT ON public.user_collection_games TO anon;

-- ============================================================
-- 4. ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.user_collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_collection_games ENABLE ROW LEVEL SECURITY;

-- ---- user_collections ----

DROP POLICY IF EXISTS "Owner can view own collections"
  ON public.user_collections;
CREATE POLICY "Owner can view own collections"
ON public.user_collections
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Anyone can view public collections"
  ON public.user_collections;
CREATE POLICY "Anyone can view public collections"
ON public.user_collections
FOR SELECT
USING (is_public = true);

DROP POLICY IF EXISTS "Owner can insert own collections"
  ON public.user_collections;
CREATE POLICY "Owner can insert own collections"
ON public.user_collections
FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Owner can update own collections"
  ON public.user_collections;
CREATE POLICY "Owner can update own collections"
ON public.user_collections
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Owner can delete own collections"
  ON public.user_collections;
CREATE POLICY "Owner can delete own collections"
ON public.user_collections
FOR DELETE
USING (auth.uid() = user_id);

-- ---- user_collection_games ----
-- Access to membership rows follows the parent collection: readable if you own
-- the parent OR the parent is public; writable only by the parent's owner.

DROP POLICY IF EXISTS "View games of accessible collections"
  ON public.user_collection_games;
CREATE POLICY "View games of accessible collections"
ON public.user_collection_games
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.user_collections c
    WHERE c.id = user_collection_games.collection_id
    AND (c.user_id = auth.uid() OR c.is_public = true)
  )
);

DROP POLICY IF EXISTS "Owner can add games to own collections"
  ON public.user_collection_games;
CREATE POLICY "Owner can add games to own collections"
ON public.user_collection_games
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.user_collections c
    WHERE c.id = user_collection_games.collection_id
    AND c.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Owner can update games in own collections"
  ON public.user_collection_games;
CREATE POLICY "Owner can update games in own collections"
ON public.user_collection_games
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.user_collections c
    WHERE c.id = user_collection_games.collection_id
    AND c.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.user_collections c
    WHERE c.id = user_collection_games.collection_id
    AND c.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Owner can remove games from own collections"
  ON public.user_collection_games;
CREATE POLICY "Owner can remove games from own collections"
ON public.user_collection_games
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.user_collections c
    WHERE c.id = user_collection_games.collection_id
    AND c.user_id = auth.uid()
  )
);

-- ============================================================
-- 5. RLS VERIFICATION (run manually with the anon key after applying)
-- ============================================================
-- A private collection MUST NOT be visible to anon. With SUPABASE_URL and
-- SUPABASE_ANON_KEY exported, and after creating a private collection as an
-- authenticated user, this must return an empty array `[]`:
--
--   curl -s "$SUPABASE_URL/rest/v1/user_collections?select=id,name,is_public" \
--     -H "apikey: $SUPABASE_ANON_KEY" | jq
--
-- Expected: only rows with is_public = true appear (or [] if none are public).
-- A private row returned here is a CRITICAL RLS failure.
-- ============================================================
