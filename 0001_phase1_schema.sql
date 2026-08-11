-- ============================================================
-- Phase 1: Schema & Auth foundation
-- Ethiopian Material Price Directory
-- ============================================================
-- This migration ONLY creates tables and turns RLS on with
-- ZERO policies attached. That means every table is default-deny
-- right now: no anon, no authenticated, not even the owner can
-- read/write until Phase 2 adds explicit policies.
-- Run this in the Supabase SQL editor, or via `supabase db push`.
-- ============================================================

-- ------------------------------------------------------------
-- profiles
-- One row per auth user. is_admin is set manually in the DB
-- for V1 (no self-serve admin signup, per spec).
-- ------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
-- No policies yet. Intentionally default-deny. Phase 2 adds them.

-- ------------------------------------------------------------
-- listings
-- ------------------------------------------------------------
create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  supplier_id uuid not null references auth.users (id) on delete cascade,
  material_name text not null,
  unit text not null,
  price numeric(12, 2) not null check (price >= 0),
  location text not null,
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.listings enable row level security;
-- No policies yet. Intentionally default-deny. Phase 2 adds them.

create index if not exists listings_status_idx on public.listings (status);
create index if not exists listings_supplier_id_idx on public.listings (supplier_id);
create index if not exists listings_material_name_idx on public.listings (material_name);
create index if not exists listings_location_idx on public.listings (location);

-- ------------------------------------------------------------
-- listing_price_history
-- Populated by a BEFORE UPDATE trigger in Phase 2, not by
-- direct client writes.
-- ------------------------------------------------------------
create table if not exists public.listing_price_history (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings (id) on delete cascade,
  old_price numeric(12, 2) not null,
  old_unit text not null,
  old_location text not null,
  changed_at timestamptz not null default now()
);

alter table public.listing_price_history enable row level security;
-- No policies yet. Intentionally default-deny. Phase 2 adds them.

create index if not exists listing_price_history_listing_id_idx
  on public.listing_price_history (listing_id);

-- ------------------------------------------------------------
-- Auto-create a profiles row whenever a new auth user signs up.
-- This belongs in Phase 1 because without it, a fresh signup has
-- no profiles row and every later is_admin check breaks.
-- ------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, is_admin)
  values (new.id, false);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
