-- Gecombineerde migraties. Plak in Supabase SQL Editor en Run.
-- Volgorde: 0001 -> 0007.

-- ============ 0001_extensions_and_enums.sql ============
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


-- ============ 0002_master_catalog.sql ============
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


-- ============ 0003_build_templates.sql ============
-- 0003_build_templates.sql
-- Bouwsjablonen: data-driven, GEEN vaste slots.
-- Een build is een set part-assignments getoetst aan het sjabloon van zijn lijn/subtype.

-- ---------------------------------------------------------------------------
-- build_templates: een sjabloon per lijn + subtype.
-- allows_integrated_bit: indien true mag een Ratchet-Integrated Bit de losse
-- ratchet- en bit-slots samen vervullen (variant op het sjabloon).
-- ---------------------------------------------------------------------------
create table build_templates (
  id                    text primary key,        -- bv. 'bx_basic', 'cx_expand'
  name                  text not null,
  line                  product_line not null,
  subtype               text not null,           -- bv. 'Basic', 'Unique', 'Expand', 'Custom'
  allows_integrated_bit boolean not null default false,
  description           text,
  sort_order            integer not null default 0
);

-- ---------------------------------------------------------------------------
-- build_template_slots: welke categorieen een sjabloon vereist.
-- required = min_quantity > 0. Optionele slots hebben min_quantity 0.
-- ---------------------------------------------------------------------------
create table build_template_slots (
  id           uuid primary key default gen_random_uuid(),
  template_id  text not null references build_templates(id) on delete cascade,
  category     text not null references part_categories(id),
  min_quantity integer not null default 1 check (min_quantity >= 0),
  max_quantity integer not null default 1 check (max_quantity >= 1),
  sort_order   integer not null default 0,
  unique (template_id, category),
  check (max_quantity >= min_quantity)
);

create index build_template_slots_template_id_idx on build_template_slots(template_id);


-- ============ 0004_user_tables.sql ============
-- 0004_user_tables.sql
-- User-eigen data: collectie, builds en decks. Alles hangt aan user_id.
-- Competitieve combo's staan in builds met user_id = null (template zonder eigenaar).

-- ---------------------------------------------------------------------------
-- owned_parts: bron van waarheid voor de collectie.
-- Meerdere rijen per part toegestaan indien verschillende condition.
-- ---------------------------------------------------------------------------
create table owned_parts (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  part_id    uuid not null references parts(id) on delete cascade,
  quantity   integer not null default 1 check (quantity > 0),
  condition  part_condition not null default 'new',
  notes      text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, part_id, condition)
);

create index owned_parts_user_id_idx on owned_parts(user_id);
create index owned_parts_part_id_idx on owned_parts(part_id);

create trigger owned_parts_set_updated_at
  before update on owned_parts
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- builds: custom combo's, competitieve templates en deck-slots.
-- user_id null = gedeelde competitieve template.
-- ---------------------------------------------------------------------------
create table builds (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users(id) on delete cascade,   -- null = template zonder eigenaar
  name        text not null,
  template_id text not null references build_templates(id),
  kind        build_kind not null default 'custom',
  source      text,                                               -- bron voor competitieve combo (WBO, event, datum)
  notes       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  -- Een template zonder eigenaar moet competitief zijn; eigen builds niet.
  check (
    (user_id is null and kind = 'competitive')
    or (user_id is not null)
  )
);

create index builds_user_id_idx on builds(user_id);
create index builds_template_id_idx on builds(template_id);
create index builds_kind_idx on builds(kind);

create trigger builds_set_updated_at
  before update on builds
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- build_parts: de part-assignments van een build.
-- slot_category legt vast welke sjabloon-slot dit part vervult (handig bij
-- categorieen die meerdere parts toestaan of bij validatie-uitleg).
-- ---------------------------------------------------------------------------
create table build_parts (
  id            uuid primary key default gen_random_uuid(),
  build_id      uuid not null references builds(id) on delete cascade,
  part_id       uuid not null references parts(id) on delete restrict,
  slot_category text references part_categories(id),
  quantity      integer not null default 1 check (quantity > 0),
  notes         text,
  unique (build_id, part_id)
);

create index build_parts_build_id_idx on build_parts(build_id);
create index build_parts_part_id_idx on build_parts(part_id);

-- ---------------------------------------------------------------------------
-- decks: drie volledige beys (X Format / 3on3).
-- lock_chip_exception: toggle of lock chips uitgezonderd zijn van de
-- geen-herhaling-regel (verschilt per ruleset).
-- ---------------------------------------------------------------------------
create table decks (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references auth.users(id) on delete cascade,
  name                text not null,
  build_1_id          uuid references builds(id) on delete set null,
  build_2_id          uuid references builds(id) on delete set null,
  build_3_id          uuid references builds(id) on delete set null,
  ruleset             text not null default 'x_format',
  lock_chip_exception boolean not null default false,
  notes               text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  -- De drie slots moeten verschillende builds zijn (indien ingevuld).
  check (
    build_1_id is null or build_2_id is null or build_1_id <> build_2_id
  ),
  check (
    build_1_id is null or build_3_id is null or build_1_id <> build_3_id
  ),
  check (
    build_2_id is null or build_3_id is null or build_2_id <> build_3_id
  )
);

create index decks_user_id_idx on decks(user_id);

create trigger decks_set_updated_at
  before update on decks
  for each row execute function set_updated_at();


-- ============ 0005_rls_policies.sql ============
-- 0005_rls_policies.sql
-- Row Level Security. Multi-tenant vanaf dag 1.
--
-- Model:
--  * Mastercatalogus = gedeelde read-only reference-data. Iedereen leest,
--    alleen service_role schrijft (seed). Read staat al open voor anon zodat
--    de latere publieke modus geen herbouw vereist.
--  * User-data (owned_parts, builds, build_parts, decks) is user-scoped op
--    auth.uid(). Competitieve builds (user_id null) zijn voor iedereen leesbaar.

-- ===========================================================================
-- Mastercatalogus: RLS aan, publieke SELECT, geen user-writes.
-- (service_role omzeilt RLS en doet de seed.)
-- ===========================================================================
alter table part_categories       enable row level security;
alter table parts                 enable row level security;
alter table part_aliases          enable row level security;
alter table products              enable row level security;
alter table product_parts         enable row level security;
alter table build_templates       enable row level security;
alter table build_template_slots  enable row level security;

create policy "catalog readable" on part_categories
  for select to anon, authenticated using (true);
create policy "catalog readable" on parts
  for select to anon, authenticated using (true);
create policy "catalog readable" on part_aliases
  for select to anon, authenticated using (true);
create policy "catalog readable" on products
  for select to anon, authenticated using (true);
create policy "catalog readable" on product_parts
  for select to anon, authenticated using (true);
create policy "catalog readable" on build_templates
  for select to anon, authenticated using (true);
create policy "catalog readable" on build_template_slots
  for select to anon, authenticated using (true);

-- ===========================================================================
-- owned_parts: volledig user-scoped.
-- ===========================================================================
alter table owned_parts enable row level security;

create policy "own rows readable" on owned_parts
  for select to authenticated using (user_id = auth.uid());
create policy "own rows insertable" on owned_parts
  for insert to authenticated with check (user_id = auth.uid());
create policy "own rows updatable" on owned_parts
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own rows deletable" on owned_parts
  for delete to authenticated using (user_id = auth.uid());

-- ===========================================================================
-- builds: eigen builds + gedeelde competitieve templates (user_id null).
-- Schrijven kan alleen op eigen rijen; null-owner templates komen via seed.
-- ===========================================================================
alter table builds enable row level security;

create policy "own or template readable" on builds
  for select to authenticated
  using (user_id = auth.uid() or user_id is null);
create policy "own builds insertable" on builds
  for insert to authenticated with check (user_id = auth.uid());
create policy "own builds updatable" on builds
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own builds deletable" on builds
  for delete to authenticated using (user_id = auth.uid());

-- ===========================================================================
-- build_parts: zichtbaarheid en schrijfrecht volgen de parent build.
-- ===========================================================================
alter table build_parts enable row level security;

create policy "parent visible readable" on build_parts
  for select to authenticated using (
    exists (
      select 1 from builds b
      where b.id = build_parts.build_id
        and (b.user_id = auth.uid() or b.user_id is null)
    )
  );
create policy "parent owned insertable" on build_parts
  for insert to authenticated with check (
    exists (
      select 1 from builds b
      where b.id = build_parts.build_id and b.user_id = auth.uid()
    )
  );
create policy "parent owned updatable" on build_parts
  for update to authenticated using (
    exists (
      select 1 from builds b
      where b.id = build_parts.build_id and b.user_id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from builds b
      where b.id = build_parts.build_id and b.user_id = auth.uid()
    )
  );
create policy "parent owned deletable" on build_parts
  for delete to authenticated using (
    exists (
      select 1 from builds b
      where b.id = build_parts.build_id and b.user_id = auth.uid()
    )
  );

-- ===========================================================================
-- decks: volledig user-scoped.
-- ===========================================================================
alter table decks enable row level security;

create policy "own rows readable" on decks
  for select to authenticated using (user_id = auth.uid());
create policy "own rows insertable" on decks
  for insert to authenticated with check (user_id = auth.uid());
create policy "own rows updatable" on decks
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own rows deletable" on decks
  for delete to authenticated using (user_id = auth.uid());


-- ============ 0006_seed_static.sql ============
-- 0006_seed_static.sql
-- Statische reference-data: categorieen en bouwsjablonen.
-- Dit is geen collectie- of productdata; het is de vaste taxonomie.
-- Idempotent zodat herhaald draaien veilig is.

-- ---------------------------------------------------------------------------
-- part_categories
-- ---------------------------------------------------------------------------
insert into part_categories (id, name, description, sort_order) values
  ('lock_chip',                'Lock Chip',                'CX. Hasbro: Lock Chip.',                                        10),
  ('blade',                    'Blade',                    'BX en UX, een stuk.',                                           20),
  ('ratchet_integrated_blade', 'Ratchet-Integrated Blade', 'UX Expand: blade en ratchet gefuseerd.',                        30),
  ('main_blade',               'Main Blade',               'CX. Hasbro: Primary Blade.',                                    40),
  ('metal_blade',              'Metal Blade',              'CX Expand.',                                                    50),
  ('over_blade',               'Over Blade',               'CX Expand.',                                                    60),
  ('assist_blade',             'Assist Blade',             'CX. Hasbro: Auxiliary Blade.',                                  70),
  ('ratchet',                  'Ratchet',                  'Losse ratchet.',                                                80),
  ('bit',                      'Bit',                      'Losse bit.',                                                    90),
  ('ratchet_integrated_bit',   'Ratchet-Integrated Bit',   'Hasbro: Combo Ratchet-Bit. Vervangt losse Ratchet plus Bit.',  100)
on conflict (id) do update set
  name        = excluded.name,
  description = excluded.description,
  sort_order  = excluded.sort_order;

-- ---------------------------------------------------------------------------
-- build_templates
-- ---------------------------------------------------------------------------
insert into build_templates (id, name, line, subtype, allows_integrated_bit, description, sort_order) values
  ('bx_basic',  'BX Basic',   'BX', 'Basic',  true,  'Blade + Ratchet + Bit.',                                    10),
  ('ux_unique', 'UX Unique',  'UX', 'Unique', true,  'Blade + Ratchet + Bit (standaard UX).',                     20),
  ('ux_expand', 'UX Expand',  'UX', 'Expand', false, 'Ratchet-Integrated Blade + Bit. Ratchet zit in de blade.',  30),
  ('cx_custom', 'CX Custom',  'CX', 'Custom', true,  'Lock Chip + Main Blade + Assist Blade + Ratchet + Bit.',    40),
  ('cx_expand', 'CX Expand',  'CX', 'Expand', true,  'Lock Chip + Metal Blade + Over Blade + Assist Blade + Ratchet + Bit.', 50)
on conflict (id) do update set
  name                  = excluded.name,
  line                  = excluded.line,
  subtype               = excluded.subtype,
  allows_integrated_bit = excluded.allows_integrated_bit,
  description           = excluded.description,
  sort_order            = excluded.sort_order;

-- ---------------------------------------------------------------------------
-- build_template_slots
-- Herseed schoon: verwijder bestaande slots en zet opnieuw.
-- ---------------------------------------------------------------------------
delete from build_template_slots
  where template_id in ('bx_basic','ux_unique','ux_expand','cx_custom','cx_expand');

insert into build_template_slots (template_id, category, min_quantity, max_quantity, sort_order) values
  -- BX Basic
  ('bx_basic', 'blade',  1, 1, 10),
  ('bx_basic', 'ratchet',1, 1, 20),
  ('bx_basic', 'bit',    1, 1, 30),
  -- UX Unique
  ('ux_unique', 'blade',  1, 1, 10),
  ('ux_unique', 'ratchet',1, 1, 20),
  ('ux_unique', 'bit',    1, 1, 30),
  -- UX Expand
  ('ux_expand', 'ratchet_integrated_blade', 1, 1, 10),
  ('ux_expand', 'bit',                      1, 1, 20),
  -- CX Custom
  ('cx_custom', 'lock_chip',    1, 1, 10),
  ('cx_custom', 'main_blade',   1, 1, 20),
  ('cx_custom', 'assist_blade', 1, 1, 30),
  ('cx_custom', 'ratchet',      1, 1, 40),
  ('cx_custom', 'bit',          1, 1, 50),
  -- CX Expand
  ('cx_expand', 'lock_chip',    1, 1, 10),
  ('cx_expand', 'metal_blade',  1, 1, 20),
  ('cx_expand', 'over_blade',   1, 1, 30),
  ('cx_expand', 'assist_blade', 1, 1, 40),
  ('cx_expand', 'ratchet',      1, 1, 50),
  ('cx_expand', 'bit',          1, 1, 60);


-- ============ 0007_grants.sql ============
-- 0007_grants.sql
-- Expliciete table-privileges voor de Supabase API-rollen.
-- RLS werkt bovenop GRANTs: zonder grant geen toegang, ongeacht policy.
-- Expliciet houden zodat het schema niet leunt op verborgen defaults.

-- Mastercatalogus: alleen lezen voor anon en authenticated.
grant select on
  part_categories, parts, part_aliases, products, product_parts,
  build_templates, build_template_slots
to anon, authenticated;

-- User-data: authenticated mag CRUD (RLS beperkt tot eigen rijen).
grant select, insert, update, delete on
  owned_parts, builds, build_parts, decks
to authenticated;

-- service_role omzeilt RLS maar heeft nog steeds grants nodig (seed/admin).
grant all on all tables in schema public to service_role;

-- Toekomstige tabellen krijgen dezelfde defaults.
alter default privileges in schema public
  grant select on tables to anon, authenticated;
alter default privileges in schema public
  grant all on tables to service_role;


