-- 0002_master_catalog.sql
-- Mastercatalogus: gedeelde reference-data (geen eigenaar).
-- Canonieke onderdeel-identiteit met merk/regio-aliassen.

-- ---------------------------------------------------------------------------
-- part_categories: de onderdeel-categorieen (vaste taxonomie).
-- Slug als PK zodat seed en code leesbaar blijven.
-- ---------------------------------------------------------------------------
create table part_categories (
  id          text primary key,          -- bv. 'blade', 'ratchet', 'bit'
  name        text not null,             -- weergavenaam
  description text,
  sort_order  integer not null default 0
);

-- ---------------------------------------------------------------------------
-- parts: canonieke mastercatalogus. Een record per fysiek onderdeel.
-- Nooit twee records voor hetzelfde fysieke onderdeel (aliassen gaan apart).
-- ---------------------------------------------------------------------------
create table parts (
  id             uuid primary key default gen_random_uuid(),
  canonical_name text not null,                          -- canonieke (meestal TT) naam
  category       text not null references part_categories(id),
  line           product_line not null,
  type           part_type,                              -- null voor bv. lock chip/ratchet/bit zonder rol
  weight_grams   numeric(6,2),
  spin_direction spin_direction,
  ratchet_height text,                                   -- bv. '3-60' (ratchet), null indien nvt
  contact_points integer,                                -- bit/blade contactpunten, null indien nvt
  image_url      text,
  wiki_url       text,                                   -- bron (Beyblade Wiki, CC-BY-SA)
  notes          text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create index parts_category_idx on parts(category);
create index parts_line_idx on parts(line);
create index parts_type_idx on parts(type);

create trigger parts_set_updated_at
  before update on parts
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- part_aliases: naam-varianten per merk en regio.
-- BulletGriffon (Hasbro) = Rocket Griffon (TT), enz.
-- ---------------------------------------------------------------------------
create table part_aliases (
  id      uuid primary key default gen_random_uuid(),
  part_id uuid not null references parts(id) on delete cascade,
  brand   brand not null,
  name    text not null,
  region  text,                                          -- bv. 'EU', 'JP', 'US'
  unique (part_id, brand, name)
);

create index part_aliases_part_id_idx on part_aliases(part_id);
-- Snel zoeken op weergavenaam ongeacht merk
create index part_aliases_name_idx on part_aliases(lower(name));

-- ---------------------------------------------------------------------------
-- products: wat je koopt (Starter, Booster, Customize Set, Deck Set, ...).
-- ---------------------------------------------------------------------------
create table products (
  id              uuid primary key default gen_random_uuid(),
  canonical_name  text not null,
  product_code    text,                                  -- bv. 'UX-19', 'CX-13'
  brand           brand not null,
  kind            product_kind not null default 'other',
  line            product_line,                          -- null indien mixed
  release_date    date,
  eu_available    boolean not null default false,
  eu_release_date date,
  image_url       text,
  wiki_url        text,
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (brand, product_code)
);

create index products_line_idx on products(line);
create index products_eu_idx on products(eu_available);

create trigger products_set_updated_at
  before update on products
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- product_parts: koppelt product aan de onderdelen die erin zitten.
-- Dit maakt "add product" mogelijk: schrijf gekoppelde parts naar owned_parts.
-- ---------------------------------------------------------------------------
create table product_parts (
  id         uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  part_id    uuid not null references parts(id) on delete restrict,
  quantity   integer not null default 1 check (quantity > 0),
  unique (product_id, part_id)
);

create index product_parts_product_id_idx on product_parts(product_id);
create index product_parts_part_id_idx on product_parts(part_id);
