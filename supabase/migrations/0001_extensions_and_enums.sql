-- 0001_extensions_and_enums.sql
-- Fundering: extensions, helper-functie en enums.
-- Beyblade X collectie- en deckbuilder. Multi-tenant vanaf dag 1.

-- pgcrypto voor gen_random_uuid()
create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

-- Productlijnen. Naam product_line (niet 'line') want 'line' is een ingebouwd
-- Postgres geometrisch type dat de enum anders overschaduwt.
create type product_line as enum ('BX', 'UX', 'CX');

-- Type/rol van een onderdeel (combat type)
create type part_type as enum ('attack', 'defense', 'stamina', 'balance');

-- Draairichting
create type spin_direction as enum ('right', 'left');

-- Merk/bron. EU koopt uit beide.
create type brand as enum ('takara_tomy', 'hasbro');

-- Wat je koopt
create type product_kind as enum (
  'starter',
  'booster',
  'random_booster',
  'customize_set',
  'deck_set',
  'other'
);

-- Soort build
create type build_kind as enum ('custom', 'competitive', 'deck_slot');

-- Staat van bezit onderdeel
create type part_condition as enum ('new', 'like_new', 'used', 'worn');

-- ---------------------------------------------------------------------------
-- Helper: updated_at automatisch bijwerken
-- ---------------------------------------------------------------------------
create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
