-- ============================================================
-- FITS — Supabase Schema Setup
-- Run this script in Supabase SQL Editor in this order:
-- 1. Extensions
-- 2. Enums
-- 3. Tables + Indexes
-- 4. RLS Policies
-- ============================================================

-- ============================================================
-- EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================================
-- ENUMS
-- ============================================================
CREATE TYPE public.item_category AS ENUM (
  'top', 'bottom', 'outerwear', 'shoes', 'accessory', 'full_body'
);

CREATE TYPE public.reaction_kind AS ENUM (
  'like', 'dislike', 'comment', 'steal'
);

CREATE TYPE public.target_kind AS ENUM (
  'outfit', 'item'
);

-- ============================================================
-- TABLES
-- ============================================================

-- Profiles: 1:1 with auth.users
CREATE TABLE public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  username text UNIQUE NOT NULL,
  handle text UNIQUE NOT NULL,
  avatar_url text,
  bio text,
  created_at timestamptz DEFAULT now()
);

-- Clothing items: Closet + wishlist + stolen items
CREATE TABLE public.clothing_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  image_url text NOT NULL,
  category public.item_category NOT NULL,
  occasion_tags text[] DEFAULT '{}',
  is_wishlist boolean DEFAULT false,
  source_item_id uuid REFERENCES public.clothing_items(id) ON DELETE SET NULL,
  source_shop text,
  source_url text,
  created_at timestamptz DEFAULT now()
);

-- Outfits: A curated set of items for an occasion
CREATE TABLE public.outfits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  occasion text NOT NULL,
  item_ids uuid[] NOT NULL,
  caption text,
  published boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Reactions: Likes, dislikes, comments, steals
CREATE TABLE public.reactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  target_type public.target_kind NOT NULL,
  target_id uuid NOT NULL,
  kind public.reaction_kind NOT NULL,
  comment text,
  created_at timestamptz DEFAULT now(),
  UNIQUE (user_id, target_type, target_id, kind)
);

-- Follows: Social graph
CREATE TABLE public.follows (
  follower_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  following_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id <> following_id)
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_clothing_items_owner_category
  ON public.clothing_items (owner_id, category);

CREATE INDEX idx_clothing_items_owner_wishlist
  ON public.clothing_items (owner_id, is_wishlist);

CREATE INDEX idx_clothing_items_source
  ON public.clothing_items (source_item_id);

CREATE INDEX idx_outfits_owner_published
  ON public.outfits (owner_id, published);

CREATE INDEX idx_outfits_published_recent
  ON public.outfits (created_at DESC) WHERE published = true;

CREATE INDEX idx_reactions_target
  ON public.reactions (target_type, target_id);

CREATE INDEX idx_follows_follower
  ON public.follows (follower_id);

CREATE INDEX idx_follows_following
  ON public.follows (following_id);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clothing_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outfits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;

-- Profiles: public read, self write
CREATE POLICY "profiles_read_all"
  ON public.profiles
  FOR SELECT
  USING (true);

CREATE POLICY "profiles_insert_self"
  ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_self"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id);

-- Items: public read, self write
CREATE POLICY "items_read_all"
  ON public.clothing_items
  FOR SELECT
  USING (true);

CREATE POLICY "items_write_self"
  ON public.clothing_items
  FOR ALL
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

-- Outfits: published readable by all; drafts only self
CREATE POLICY "outfits_read"
  ON public.outfits
  FOR SELECT
  USING (published = true OR auth.uid() = owner_id);

CREATE POLICY "outfits_write_self"
  ON public.outfits
  FOR ALL
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

-- Reactions: public read, self write
CREATE POLICY "reactions_read_all"
  ON public.reactions
  FOR SELECT
  USING (true);

CREATE POLICY "reactions_write_self"
  ON public.reactions
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Follows: public read, self write
CREATE POLICY "follows_read_all"
  ON public.follows
  FOR SELECT
  USING (true);

CREATE POLICY "follows_write_self"
  ON public.follows
  FOR ALL
  USING (auth.uid() = follower_id)
  WITH CHECK (auth.uid() = follower_id);

-- ============================================================
-- SETUP COMPLETE
-- ============================================================
-- Next steps:
-- 1. Create storage buckets in Supabase dashboard:
--    - Name: "clothing" (public)
--    - Name: "avatars" (public)
--    - Policy: authenticated users can INSERT, SELECT is public
-- 2. Copy your anon key from Settings → API → "anon [public]"
-- 3. Add to Secrets.swift in iOS app
