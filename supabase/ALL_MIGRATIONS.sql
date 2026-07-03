-- Gecombineerde migraties. Volgorde: 0001 -> 0022.

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


-- ============ 0008_part_variants.sql ============
-- 0008_part_variants.sql
-- Colorways. Dezelfde canonieke part komt vaak in meerdere kleuren uit.
-- Competitief is een colorway hetzelfde onderdeel (zelfde mold/gewicht), dus
-- validatie en meta-matching blijven vergelijken op de canonieke part_id.
-- Voor collectie en producten leggen we de specifieke kleur wel vast.

-- ---------------------------------------------------------------------------
-- part_variants: een colorway van een canonieke part.
-- ---------------------------------------------------------------------------
create table part_variants (
  id         uuid primary key default gen_random_uuid(),
  part_id    uuid not null references parts(id) on delete cascade,
  colorway   text not null,                 -- bv. 'Standaard', 'Zwart', 'Clear Blue', 'Prize ver.'
  is_default boolean not null default false, -- de eerste/standaard uitgave
  image_url  text,
  wiki_url   text,
  notes      text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (part_id, colorway)
);

create index part_variants_part_id_idx on part_variants(part_id);

create trigger part_variants_set_updated_at
  before update on part_variants
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- owned_parts: optionele colorway. part_id blijft het anker voor telling en
-- buildbaarheid. Zonder variant = kleur niet geregistreerd.
-- ---------------------------------------------------------------------------
alter table owned_parts
  add column variant_id uuid references part_variants(id) on delete set null;

-- Oude unieke sleutel vervangen zodat dezelfde part in meerdere kleuren kan.
-- nulls not distinct: twee rijen zonder variant tellen als hetzelfde (geen dubbels).
alter table owned_parts drop constraint owned_parts_user_id_part_id_condition_key;
alter table owned_parts
  add constraint owned_parts_uniq
  unique nulls not distinct (user_id, part_id, variant_id, condition);

create index owned_parts_variant_id_idx on owned_parts(variant_id);

-- ---------------------------------------------------------------------------
-- product_parts: een product bevat een specifieke colorway.
-- ---------------------------------------------------------------------------
alter table product_parts
  add column variant_id uuid references part_variants(id) on delete restrict;

alter table product_parts drop constraint product_parts_product_id_part_id_key;
alter table product_parts
  add constraint product_parts_uniq
  unique nulls not distinct (product_id, part_id, variant_id);

create index product_parts_variant_id_idx on product_parts(variant_id);

-- ---------------------------------------------------------------------------
-- RLS + grants voor part_variants (gedeelde catalogus, publiek leesbaar).
-- ---------------------------------------------------------------------------
alter table part_variants enable row level security;

create policy "catalog readable" on part_variants
  for select to anon, authenticated using (true);

grant select on part_variants to anon, authenticated;
grant all on part_variants to service_role;


-- ============ 0009_seed_bx.sql ============
-- 0009_seed_bx.sql
-- Seed batch 1: Beyblade X BX-lijn, eerste golf.
-- Bron: Beyblade Wiki (Fandom), CC-BY-SA. https://beyblade.fandom.com
-- Toon in de UI zichtbare bronvermelding.
--
-- Bewuste keuzes:
--  * weight_grams blijft leeg: de wiki-infobox geeft combo/dubbelzinnige
--    gewichten, geen betrouwbaar per-part gewicht. Later per part verifieren.
--  * image_url leeg: wiki-afbeeldings-URLs zijn niet stabiel te construeren.
--    Komt in de afbeeldingen-pipeline. wiki_url dient nu als bron/attributie.
--  * Ratchets en bits krijgen line = 'BX' (debuutlijn); ze zijn fysiek
--    lijn-overschrijdend maar het schema vereist een line. Eén canoniek record.
--  * EU: Hasbro bracht deze westers uit rond juni 2024. eu_release_date laten
--    we leeg tot cross-check met EU-retailers; eu_available = true.
-- Idempotent via vaste UUID's en ON CONFLICT.

-- ===========================================================================
-- PARTS: Blades
-- ===========================================================================
insert into parts (id, canonical_name, category, line, type, spin_direction, contact_points, wiki_url) values
  ('11111111-0000-4000-8000-000000000001','DranSword','blade','BX','attack','right',3,'https://beyblade.fandom.com/wiki/DranSword_3-60F'),
  ('11111111-0000-4000-8000-000000000002','HellsScythe','blade','BX','balance','right',4,'https://beyblade.fandom.com/wiki/HellsScythe_4-60T'),
  ('11111111-0000-4000-8000-000000000003','WizardArrow','blade','BX','stamina','right',2,'https://beyblade.fandom.com/wiki/WizardArrow_4-80B'),
  ('11111111-0000-4000-8000-000000000004','KnightShield','blade','BX','defense','right',null,'https://beyblade.fandom.com/wiki/KnightShield_3-80N'),
  ('11111111-0000-4000-8000-000000000005','SharkEdge','blade','BX','attack','right',null,'https://beyblade.fandom.com/wiki/SharkEdge_3-60LF')
on conflict (id) do update set
  type=excluded.type, spin_direction=excluded.spin_direction,
  contact_points=excluded.contact_points, wiki_url=excluded.wiki_url;

-- ===========================================================================
-- PARTS: Ratchets (canonical_name = code, ratchet_height = hoogtedeel)
-- ===========================================================================
insert into parts (id, canonical_name, category, line, ratchet_height, wiki_url) values
  ('22222222-0000-4000-8000-000000000360','3-60','ratchet','BX','60','https://beyblade.fandom.com/wiki/Ratchet_-_3-60'),
  ('22222222-0000-4000-8000-000000000460','4-60','ratchet','BX','60','https://beyblade.fandom.com/wiki/Ratchet_-_4-60'),
  ('22222222-0000-4000-8000-000000000480','4-80','ratchet','BX','80','https://beyblade.fandom.com/wiki/Ratchet_-_4-80'),
  ('22222222-0000-4000-8000-000000000380','3-80','ratchet','BX','80','https://beyblade.fandom.com/wiki/Ratchet_-_3-80')
on conflict (id) do update set ratchet_height=excluded.ratchet_height, wiki_url=excluded.wiki_url;

-- ===========================================================================
-- PARTS: Bits (canonical_name = volledige naam)
-- ===========================================================================
insert into parts (id, canonical_name, category, line, wiki_url) values
  ('33333333-0000-4000-8000-000000000001','Flat','bit','BX','https://beyblade.fandom.com/wiki/Bit_-_Flat'),
  ('33333333-0000-4000-8000-000000000002','Taper','bit','BX','https://beyblade.fandom.com/wiki/Bit_-_Taper'),
  ('33333333-0000-4000-8000-000000000003','Ball','bit','BX','https://beyblade.fandom.com/wiki/Bit_-_Ball'),
  ('33333333-0000-4000-8000-000000000004','Needle','bit','BX','https://beyblade.fandom.com/wiki/Bit_-_Needle'),
  ('33333333-0000-4000-8000-000000000005','Low Flat','bit','BX','https://beyblade.fandom.com/wiki/Bit_-_Low_Flat')
on conflict (id) do update set wiki_url=excluded.wiki_url;

-- ===========================================================================
-- PART ALIASES: Hasbro-namen voor de blades (TT is canoniek)
-- ===========================================================================
insert into part_aliases (part_id, brand, name, region) values
  ('11111111-0000-4000-8000-000000000001','hasbro','Sword Dran','US'),
  ('11111111-0000-4000-8000-000000000002','hasbro','Scythe Incendio','US'),
  ('11111111-0000-4000-8000-000000000003','hasbro','Arrow Wizard','US'),
  ('11111111-0000-4000-8000-000000000004','hasbro','Helm Knight','US'),
  ('11111111-0000-4000-8000-000000000005','hasbro','Keel Shark','US')
on conflict (part_id, brand, name) do nothing;

-- ===========================================================================
-- PART VARIANTS: colorways (blades). is_default = standaard basisuitgave.
-- ===========================================================================
insert into part_variants (id, part_id, colorway, is_default, wiki_url) values
  -- DranSword
  ('55555555-0000-4000-8000-000000000101','11111111-0000-4000-8000-000000000001','Blauw (standaard)',true,'https://beyblade.fandom.com/wiki/DranSword_3-60F'),
  ('55555555-0000-4000-8000-000000000102','11111111-0000-4000-8000-000000000001','Rood (Red Ver.)',false,'https://beyblade.fandom.com/wiki/DranSword_3-60F'),
  ('55555555-0000-4000-8000-000000000103','11111111-0000-4000-8000-000000000001','Opaque blue (Special Ver.)',false,'https://beyblade.fandom.com/wiki/DranSword_3-60F'),
  ('55555555-0000-4000-8000-000000000104','11111111-0000-4000-8000-000000000001','Metal Coat: Gold',false,'https://beyblade.fandom.com/wiki/DranSword_3-60F'),
  -- HellsScythe
  ('55555555-0000-4000-8000-000000000201','11111111-0000-4000-8000-000000000002','Rood (standaard)',true,'https://beyblade.fandom.com/wiki/HellsScythe_4-60T'),
  ('55555555-0000-4000-8000-000000000202','11111111-0000-4000-8000-000000000002','Metal Coat: Gold',false,'https://beyblade.fandom.com/wiki/HellsScythe_4-60T'),
  -- WizardArrow
  ('55555555-0000-4000-8000-000000000301','11111111-0000-4000-8000-000000000003','Geel (standaard)',true,'https://beyblade.fandom.com/wiki/WizardArrow_4-80B'),
  ('55555555-0000-4000-8000-000000000302','11111111-0000-4000-8000-000000000003','Rood (BX-05 Booster)',false,'https://beyblade.fandom.com/wiki/WizardArrow_4-80B'),
  ('55555555-0000-4000-8000-000000000303','11111111-0000-4000-8000-000000000003','Blauw (BX-17)',false,'https://beyblade.fandom.com/wiki/WizardArrow_4-80B'),
  -- KnightShield
  ('55555555-0000-4000-8000-000000000401','11111111-0000-4000-8000-000000000004','Groen (standaard)',true,'https://beyblade.fandom.com/wiki/KnightShield_3-80N'),
  ('55555555-0000-4000-8000-000000000402','11111111-0000-4000-8000-000000000004','Blauw (BX-06 Booster)',false,'https://beyblade.fandom.com/wiki/KnightShield_3-80N'),
  -- SharkEdge
  ('55555555-0000-4000-8000-000000000501','11111111-0000-4000-8000-000000000005','Paars (standaard)',true,'https://beyblade.fandom.com/wiki/SharkEdge_3-60LF')
on conflict (id) do update set colorway=excluded.colorway, is_default=excluded.is_default;

-- ===========================================================================
-- PRODUCTS (Takara Tomy). Hasbro-code in notes.
-- ===========================================================================
insert into products (id, canonical_name, product_code, brand, kind, line, release_date, eu_available, notes) values
  ('44444444-0000-4000-8000-000000000001','Starter DranSword 3-60F','BX-01','takara_tomy','starter','BX','2023-07-15',true,'Hasbro: Sword Dran 3-60F Starter Pack (F9580). Westerse release ~juni 2024.'),
  ('44444444-0000-4000-8000-000000000002','Starter HellsScythe 4-60T','BX-02','takara_tomy','starter','BX','2023-06-10',true,'Hasbro: Scythe Incendio 4-60T Starter Pack (F9583). Westerse release ~juni 2024.'),
  ('44444444-0000-4000-8000-000000000003','Starter WizardArrow 4-80B','BX-03','takara_tomy','starter','BX','2023-07-15',true,'Hasbro: Arrow Wizard 4-80B Starter Pack (F9582). Westerse release ~juni 2024.'),
  ('44444444-0000-4000-8000-000000000004','Starter KnightShield 3-80N','BX-04','takara_tomy','starter','BX','2023-07-15',true,'Hasbro: Helm Knight 3-80N Starter Pack (F9581). Westerse release ~juni 2024.'),
  ('44444444-0000-4000-8000-000000000014','Random Booster Vol. 1','BX-14','takara_tomy','random_booster','BX','2023-09-09',true,'Prijs-bey: SharkEdge 3-60LF. Hasbro: Keel Shark 3-60LF Booster Pack (G0194).')
on conflict (id) do update set
  canonical_name=excluded.canonical_name, product_code=excluded.product_code,
  release_date=excluded.release_date, eu_available=excluded.eu_available, notes=excluded.notes;

-- ===========================================================================
-- PRODUCT_PARTS: inhoud per product. Blade met colorway-variant; ratchet/bit
-- zonder specifieke variant (null).
-- ===========================================================================
delete from product_parts where product_id in (
  '44444444-0000-4000-8000-000000000001','44444444-0000-4000-8000-000000000002',
  '44444444-0000-4000-8000-000000000003','44444444-0000-4000-8000-000000000004',
  '44444444-0000-4000-8000-000000000014');

insert into product_parts (product_id, part_id, variant_id, quantity) values
  -- BX-01: DranSword(blauw) + 3-60 + Flat
  ('44444444-0000-4000-8000-000000000001','11111111-0000-4000-8000-000000000001','55555555-0000-4000-8000-000000000101',1),
  ('44444444-0000-4000-8000-000000000001','22222222-0000-4000-8000-000000000360',null,1),
  ('44444444-0000-4000-8000-000000000001','33333333-0000-4000-8000-000000000001',null,1),
  -- BX-02: HellsScythe(rood) + 4-60 + Taper
  ('44444444-0000-4000-8000-000000000002','11111111-0000-4000-8000-000000000002','55555555-0000-4000-8000-000000000201',1),
  ('44444444-0000-4000-8000-000000000002','22222222-0000-4000-8000-000000000460',null,1),
  ('44444444-0000-4000-8000-000000000002','33333333-0000-4000-8000-000000000002',null,1),
  -- BX-03: WizardArrow(geel) + 4-80 + Ball
  ('44444444-0000-4000-8000-000000000003','11111111-0000-4000-8000-000000000003','55555555-0000-4000-8000-000000000301',1),
  ('44444444-0000-4000-8000-000000000003','22222222-0000-4000-8000-000000000480',null,1),
  ('44444444-0000-4000-8000-000000000003','33333333-0000-4000-8000-000000000003',null,1),
  -- BX-04: KnightShield(groen) + 3-80 + Needle
  ('44444444-0000-4000-8000-000000000004','11111111-0000-4000-8000-000000000004','55555555-0000-4000-8000-000000000401',1),
  ('44444444-0000-4000-8000-000000000004','22222222-0000-4000-8000-000000000380',null,1),
  ('44444444-0000-4000-8000-000000000004','33333333-0000-4000-8000-000000000004',null,1),
  -- BX-14 (prijs-combo): SharkEdge(paars) + 3-60 + Low Flat
  ('44444444-0000-4000-8000-000000000014','11111111-0000-4000-8000-000000000005','55555555-0000-4000-8000-000000000501',1),
  ('44444444-0000-4000-8000-000000000014','22222222-0000-4000-8000-000000000360',null,1),
  ('44444444-0000-4000-8000-000000000014','33333333-0000-4000-8000-000000000005',null,1);


-- ============ 0010_collection_functions.sql ============
-- 0010_collection_functions.sql
-- Helper-functies om aan de collectie toe te voegen, met atomair ophogen.
-- SECURITY INVOKER: draaien onder RLS als de ingelogde user (auth.uid()).

-- Voeg een los onderdeel toe (of hoog de hoeveelheid op).
create or replace function add_owned_part(
  p_part_id   uuid,
  p_variant_id uuid default null,
  p_condition part_condition default 'new',
  p_qty       integer default 1
)
returns void
language sql
security invoker
as $$
  insert into owned_parts (user_id, part_id, variant_id, condition, quantity)
  values (auth.uid(), p_part_id, p_variant_id, p_condition, greatest(p_qty, 1))
  on conflict on constraint owned_parts_uniq
  do update set quantity = owned_parts.quantity + greatest(p_qty, 1),
                updated_at = now();
$$;

-- Voeg alle onderdelen van een product toe aan de collectie.
create or replace function add_product_to_collection(
  p_product_id uuid,
  p_condition  part_condition default 'new'
)
returns void
language sql
security invoker
as $$
  insert into owned_parts (user_id, part_id, variant_id, condition, quantity)
  select auth.uid(), pp.part_id, pp.variant_id, p_condition, pp.quantity
  from product_parts pp
  where pp.product_id = p_product_id
  on conflict on constraint owned_parts_uniq
  do update set quantity = owned_parts.quantity + excluded.quantity,
                updated_at = now();
$$;

grant execute on function add_owned_part(uuid, uuid, part_condition, integer) to authenticated;
grant execute on function add_product_to_collection(uuid, part_condition) to authenticated;


-- ============ 0011_seed_images.sql ============
-- 0011_seed_images.sql
-- Afbeeldings-URLs (Beyblade Wiki / Fandom, CC-BY-SA), 320px thumbnails.
-- Bron-attributie staat al in de UI. Losse colorways delen voorlopig de
-- basis-afbeelding van hun part.

-- Blades
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/5/5f/BladeDranSword.png/revision/latest/scale-to-width-down/320?cb=20250814202546' where id = '11111111-0000-4000-8000-000000000001';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/e/e4/BladeHellsScythe.png/revision/latest/scale-to-width-down/320?cb=20250817035337' where id = '11111111-0000-4000-8000-000000000002';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/4/44/BladeWizardArrow.png/revision/latest/scale-to-width-down/320?cb=20250626062049' where id = '11111111-0000-4000-8000-000000000003';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/9/9c/BladeKnightShield.png/revision/latest/scale-to-width-down/320?cb=20250609060142' where id = '11111111-0000-4000-8000-000000000004';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/2/2e/BladeSharkEdge.png/revision/latest/scale-to-width-down/320?cb=20230812203549' where id = '11111111-0000-4000-8000-000000000005';

-- Ratchets
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/1/1b/Ratchet3-60.png/revision/latest/scale-to-width-down/320?cb=20240913063429' where id = '22222222-0000-4000-8000-000000000360';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/4/46/Ratchet4-60.png/revision/latest/scale-to-width-down/320?cb=20250317055414' where id = '22222222-0000-4000-8000-000000000460';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/a/ae/Ratchet4-80.png/revision/latest/scale-to-width-down/320?cb=20250608045210' where id = '22222222-0000-4000-8000-000000000480';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/6/69/Ratchet3-80.png/revision/latest/scale-to-width-down/320?cb=20250609060206' where id = '22222222-0000-4000-8000-000000000380';

-- Bits
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/b/b0/BitFlat.png/revision/latest/scale-to-width-down/320?cb=20240913063436' where id = '33333333-0000-4000-8000-000000000001';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/a/ad/BitTaper.png/revision/latest/scale-to-width-down/320?cb=20250317055452' where id = '33333333-0000-4000-8000-000000000002';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/8/8c/BitBall.png/revision/latest/scale-to-width-down/320?cb=20250608045235' where id = '33333333-0000-4000-8000-000000000003';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/2/26/BitNeedle.png/revision/latest/scale-to-width-down/320?cb=20250609060238' where id = '33333333-0000-4000-8000-000000000004';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/0/0e/BitLowFlat.png/revision/latest?cb=20230812203610' where id = '33333333-0000-4000-8000-000000000005';

-- Producten
update products set image_url = 'https://static.wikia.nocookie.net/beyblade/images/0/09/DranSword_3-60F.png/revision/latest/scale-to-width-down/320?cb=20230516042157' where id = '44444444-0000-4000-8000-000000000001';
update products set image_url = 'https://static.wikia.nocookie.net/beyblade/images/1/1a/HellsScythe_4-60T.jpeg/revision/latest/scale-to-width-down/320?cb=20230517044323' where id = '44444444-0000-4000-8000-000000000002';
update products set image_url = 'https://static.wikia.nocookie.net/beyblade/images/6/6d/WizardArrow_4-80B.jpeg/revision/latest/scale-to-width-down/320?cb=20230517044837' where id = '44444444-0000-4000-8000-000000000003';
update products set image_url = 'https://static.wikia.nocookie.net/beyblade/images/a/ac/KnightShield_3-80N.jpeg/revision/latest/scale-to-width-down/320?cb=20230517045417' where id = '44444444-0000-4000-8000-000000000004';
update products set image_url = 'https://static.wikia.nocookie.net/beyblade/images/7/7c/SharkEdge_3-60LF.png/revision/latest/scale-to-width-down/320?cb=20230812090317' where id = '44444444-0000-4000-8000-000000000014';


-- ============ 0012_seed_bx_batch2.sql ============
-- 0012_seed_bx_batch2.sql
-- Seed batch 2: volgende golf Beyblade X BX-beys.
-- Bron: Beyblade Wiki (Fandom), CC-BY-SA. Afbeeldingen = 320px thumbnails.
-- weight_grams blijft leeg (combo/dubbelzinnige gewichten op de wiki).
-- Idempotent via vaste UUID's en ON CONFLICT.

-- ===========================================================================
-- PARTS: nieuwe Blades
-- ===========================================================================
insert into parts (id, canonical_name, category, line, type, spin_direction, image_url, wiki_url) values
  ('11111111-0000-4000-8000-000000000006','LeonClaw','blade','BX','balance','right','https://static.wikia.nocookie.net/beyblade/images/9/93/BladeLeonClaw.png/revision/latest/scale-to-width-down/320?cb=20230918165658','https://beyblade.fandom.com/wiki/LeonClaw_5-60P'),
  ('11111111-0000-4000-8000-000000000007','RhinoHorn','blade','BX','defense','right','https://static.wikia.nocookie.net/beyblade/images/4/41/BladeRhinoHorn.png/revision/latest/scale-to-width-down/320?cb=20250528201123','https://beyblade.fandom.com/wiki/RhinoHorn_3-80S'),
  ('11111111-0000-4000-8000-000000000008','PhoenixWing','blade','BX','attack','right','https://static.wikia.nocookie.net/beyblade/images/2/2d/BladePhoenixWing.png/revision/latest?cb=20231115091927','https://beyblade.fandom.com/wiki/PhoenixWing_9-60GF'),
  ('11111111-0000-4000-8000-000000000009','ViperTail','blade','BX','stamina','right','https://static.wikia.nocookie.net/beyblade/images/9/9d/BladeViperTail.png/revision/latest/scale-to-width-down/320?cb=20250818205656','https://beyblade.fandom.com/wiki/ViperTail_5-80O'),
  ('11111111-0000-4000-8000-000000000010','HellsChain','blade','BX','balance','right','https://static.wikia.nocookie.net/beyblade/images/8/83/BladeHellsChain.png/revision/latest/scale-to-width-down/320?cb=20250528203625','https://beyblade.fandom.com/wiki/HellsChain_5-60HT'),
  ('11111111-0000-4000-8000-000000000011','TyrannoBeat','blade','BX','attack','right','https://static.wikia.nocookie.net/beyblade/images/f/ff/BladeTyrannoBeat.png/revision/latest?cb=20240415173927','https://beyblade.fandom.com/wiki/TyrannoBeat_4-70Q')
on conflict (id) do update set
  type=excluded.type, spin_direction=excluded.spin_direction,
  image_url=excluded.image_url, wiki_url=excluded.wiki_url;

-- ===========================================================================
-- PARTS: nieuwe Ratchets (3-80 bestond al)
-- ===========================================================================
insert into parts (id, canonical_name, category, line, ratchet_height, image_url, wiki_url) values
  ('22222222-0000-4000-8000-000000000560','5-60','ratchet','BX','60','https://static.wikia.nocookie.net/beyblade/images/f/f7/Ratchet5-60.png/revision/latest/scale-to-width-down/320?cb=20230918165846','https://beyblade.fandom.com/wiki/Ratchet_-_5-60'),
  ('22222222-0000-4000-8000-000000000960','9-60','ratchet','BX','60','https://static.wikia.nocookie.net/beyblade/images/a/af/Ratchet9-60.png/revision/latest/scale-to-width-down/320?cb=20250530201949','https://beyblade.fandom.com/wiki/Ratchet_-_9-60'),
  ('22222222-0000-4000-8000-000000000580','5-80','ratchet','BX','80','https://static.wikia.nocookie.net/beyblade/images/4/42/Ratchet5-80.png/revision/latest/scale-to-width-down/320?cb=20230918165909','https://beyblade.fandom.com/wiki/Ratchet_-_5-80'),
  ('22222222-0000-4000-8000-000000000470','4-70','ratchet','BX','70','https://static.wikia.nocookie.net/beyblade/images/1/16/Ratchet4-70.png/revision/latest?cb=20240524163324','https://beyblade.fandom.com/wiki/Ratchet_-_4-70')
on conflict (id) do update set ratchet_height=excluded.ratchet_height, image_url=excluded.image_url, wiki_url=excluded.wiki_url;

-- ===========================================================================
-- PARTS: nieuwe Bits
-- ===========================================================================
insert into parts (id, canonical_name, category, line, image_url, wiki_url) values
  ('33333333-0000-4000-8000-000000000006','Point','bit','BX','https://static.wikia.nocookie.net/beyblade/images/b/bf/BitPoint.png/revision/latest?cb=20230918165854','https://beyblade.fandom.com/wiki/Bit_-_Point'),
  ('33333333-0000-4000-8000-000000000007','Spike','bit','BX','https://static.wikia.nocookie.net/beyblade/images/7/7d/BitSpike.png/revision/latest?cb=20231014012757','https://beyblade.fandom.com/wiki/Bit_-_Spike'),
  ('33333333-0000-4000-8000-000000000008','Gear Flat','bit','BX','https://static.wikia.nocookie.net/beyblade/images/b/bd/BitGearFlat.png/revision/latest?cb=20231115091943','https://beyblade.fandom.com/wiki/Bit_-_Gear_Flat'),
  ('33333333-0000-4000-8000-000000000009','Orb','bit','BX','https://static.wikia.nocookie.net/beyblade/images/1/17/BitOrb.png/revision/latest?cb=20230918165916','https://beyblade.fandom.com/wiki/Bit_-_Orb'),
  ('33333333-0000-4000-8000-000000000010','High Taper','bit','BX','https://static.wikia.nocookie.net/beyblade/images/b/b5/BitHighTaper.png/revision/latest?cb=20231014024512','https://beyblade.fandom.com/wiki/Bit_-_High_Taper'),
  ('33333333-0000-4000-8000-000000000011','Quake','bit','BX','https://static.wikia.nocookie.net/beyblade/images/e/ed/BitQuake.png/revision/latest?cb=20240503184404','https://beyblade.fandom.com/wiki/Bit_-_Quake')
on conflict (id) do update set image_url=excluded.image_url, wiki_url=excluded.wiki_url;

-- ===========================================================================
-- PART ALIASES: Hasbro-namen
-- ===========================================================================
insert into part_aliases (part_id, brand, name, region) values
  ('11111111-0000-4000-8000-000000000006','hasbro','Claw Leon','US'),
  ('11111111-0000-4000-8000-000000000007','hasbro','Horn Rhino','US'),
  ('11111111-0000-4000-8000-000000000008','hasbro','Soar Phoenix','US'),
  ('11111111-0000-4000-8000-000000000009','hasbro','Tail Viper','US'),
  ('11111111-0000-4000-8000-000000000010','hasbro','Chain Incendio','US'),
  ('11111111-0000-4000-8000-000000000011','hasbro','Beat Tyranno','US')
on conflict (part_id, brand, name) do nothing;

-- ===========================================================================
-- PART VARIANTS: colorways
-- ===========================================================================
insert into part_variants (id, part_id, colorway, is_default, wiki_url) values
  ('55555555-0000-4000-8000-000000000601','11111111-0000-4000-8000-000000000006','Zwart (standaard)',true,'https://beyblade.fandom.com/wiki/LeonClaw_5-60P'),
  ('55555555-0000-4000-8000-000000000602','11111111-0000-4000-8000-000000000006','Metal Coat: Gold',false,'https://beyblade.fandom.com/wiki/LeonClaw_5-60P'),
  ('55555555-0000-4000-8000-000000000701','11111111-0000-4000-8000-000000000007','Wit (standaard)',true,'https://beyblade.fandom.com/wiki/RhinoHorn_3-80S'),
  ('55555555-0000-4000-8000-000000000801','11111111-0000-4000-8000-000000000008','Paars/goud (standaard)',true,'https://beyblade.fandom.com/wiki/PhoenixWing_9-60GF'),
  ('55555555-0000-4000-8000-000000000901','11111111-0000-4000-8000-000000000009','Standaard',true,'https://beyblade.fandom.com/wiki/ViperTail_5-80O'),
  ('55555555-0000-4000-8000-000000001001','11111111-0000-4000-8000-000000000010','Rood (standaard)',true,'https://beyblade.fandom.com/wiki/HellsChain_5-60HT'),
  ('55555555-0000-4000-8000-000000001002','11111111-0000-4000-8000-000000000010','Metal Coat: Black',false,'https://beyblade.fandom.com/wiki/HellsChain_5-60HT'),
  ('55555555-0000-4000-8000-000000001101','11111111-0000-4000-8000-000000000011','Rood (standaard)',true,'https://beyblade.fandom.com/wiki/TyrannoBeat_4-70Q')
on conflict (id) do update set colorway=excluded.colorway, is_default=excluded.is_default;

-- ===========================================================================
-- PRODUCTS
-- ===========================================================================
insert into products (id, canonical_name, product_code, brand, kind, line, release_date, eu_available, image_url, notes) values
  ('44444444-0000-4000-8000-000000000015','Starter LeonClaw 5-60P','BX-15','takara_tomy','starter','BX','2023-10-07',true,'https://static.wikia.nocookie.net/beyblade/images/f/f4/LeonClaw_5-60P.jpeg/revision/latest/scale-to-width-down/320?cb=20230914033817','Hasbro: Claw Leon 5-60P Starter Pack (G0193).'),
  ('44444444-0000-4000-8000-000000000019','Booster RhinoHorn 3-80S','BX-19','takara_tomy','booster','BX','2023-11-02',true,'https://static.wikia.nocookie.net/beyblade/images/0/02/RhinoHorn_3-80S.jpeg/revision/latest/scale-to-width-down/320?cb=20231013160027','Hasbro: Horn Rhino 3-80S Booster Pack (G0192).'),
  ('44444444-0000-4000-8000-000000000023','Starter PhoenixWing 9-60GF','BX-23','takara_tomy','starter','BX','2023-12-27',true,'https://static.wikia.nocookie.net/beyblade/images/0/02/PhoenixWing_9-60GF.jpeg/revision/latest/scale-to-width-down/320?cb=20231114155235','Hasbro: Soar Phoenix (F9324).'),
  ('44444444-0000-4000-8000-000000000016','Random Booster ViperTail Select','BX-16','takara_tomy','random_booster','BX','2023-10-07',true,'https://static.wikia.nocookie.net/beyblade/images/0/09/ViperTail_5-80O.jpeg/revision/latest/scale-to-width-down/320?cb=20230914153122','Prijs-bey: ViperTail 5-80O. Hasbro: Tail Viper.'),
  ('44444444-0000-4000-8000-000000000021','HellsChain Deck Set','BX-21','takara_tomy','deck_set','BX','2023-11-02',true,'https://static.wikia.nocookie.net/beyblade/images/d/d1/HellsChain_5-60HT.jpeg/revision/latest/scale-to-width-down/320?cb=20250815161204','Hasbro: Chain Incendio (G0196).'),
  ('44444444-0000-4000-8000-000000000031','Random Booster Vol. 3','BX-31','takara_tomy','random_booster','BX','2024-04-27',true,'https://static.wikia.nocookie.net/beyblade/images/1/14/TyrannoBeat_4-70Q.jpeg/revision/latest/scale-to-width-down/320?cb=20241117065057','Prijs-bey: TyrannoBeat 4-70Q. Hasbro: Beat Tyranno.')
on conflict (id) do update set
  canonical_name=excluded.canonical_name, product_code=excluded.product_code,
  kind=excluded.kind, release_date=excluded.release_date,
  eu_available=excluded.eu_available, image_url=excluded.image_url, notes=excluded.notes;

-- ===========================================================================
-- PRODUCT_PARTS
-- ===========================================================================
delete from product_parts where product_id in (
  '44444444-0000-4000-8000-000000000015','44444444-0000-4000-8000-000000000019',
  '44444444-0000-4000-8000-000000000023','44444444-0000-4000-8000-000000000016',
  '44444444-0000-4000-8000-000000000021','44444444-0000-4000-8000-000000000031');

insert into product_parts (product_id, part_id, variant_id, quantity) values
  -- BX-15 LeonClaw(zwart) + 5-60 + Point
  ('44444444-0000-4000-8000-000000000015','11111111-0000-4000-8000-000000000006','55555555-0000-4000-8000-000000000601',1),
  ('44444444-0000-4000-8000-000000000015','22222222-0000-4000-8000-000000000560',null,1),
  ('44444444-0000-4000-8000-000000000015','33333333-0000-4000-8000-000000000006',null,1),
  -- BX-19 RhinoHorn(wit) + 3-80 + Spike
  ('44444444-0000-4000-8000-000000000019','11111111-0000-4000-8000-000000000007','55555555-0000-4000-8000-000000000701',1),
  ('44444444-0000-4000-8000-000000000019','22222222-0000-4000-8000-000000000380',null,1),
  ('44444444-0000-4000-8000-000000000019','33333333-0000-4000-8000-000000000007',null,1),
  -- BX-23 PhoenixWing(paars/goud) + 9-60 + Gear Flat
  ('44444444-0000-4000-8000-000000000023','11111111-0000-4000-8000-000000000008','55555555-0000-4000-8000-000000000801',1),
  ('44444444-0000-4000-8000-000000000023','22222222-0000-4000-8000-000000000960',null,1),
  ('44444444-0000-4000-8000-000000000023','33333333-0000-4000-8000-000000000008',null,1),
  -- BX-16 ViperTail(standaard) + 5-80 + Orb
  ('44444444-0000-4000-8000-000000000016','11111111-0000-4000-8000-000000000009','55555555-0000-4000-8000-000000000901',1),
  ('44444444-0000-4000-8000-000000000016','22222222-0000-4000-8000-000000000580',null,1),
  ('44444444-0000-4000-8000-000000000016','33333333-0000-4000-8000-000000000009',null,1),
  -- BX-21 HellsChain(rood) + 5-60 + High Taper
  ('44444444-0000-4000-8000-000000000021','11111111-0000-4000-8000-000000000010','55555555-0000-4000-8000-000000001001',1),
  ('44444444-0000-4000-8000-000000000021','22222222-0000-4000-8000-000000000560',null,1),
  ('44444444-0000-4000-8000-000000000021','33333333-0000-4000-8000-000000000010',null,1),
  -- BX-31 TyrannoBeat(rood) + 4-70 + Quake
  ('44444444-0000-4000-8000-000000000031','11111111-0000-4000-8000-000000000011','55555555-0000-4000-8000-000000001101',1),
  ('44444444-0000-4000-8000-000000000031','22222222-0000-4000-8000-000000000470',null,1),
  ('44444444-0000-4000-8000-000000000031','33333333-0000-4000-8000-000000000011',null,1);


-- ============ 0013_seed_bx_parts.sql ============
-- 0013_seed_bx_parts.sql
-- Seed batch 3: alle resterende canonieke BX-onderdelen (19 blades, 13 ratchets,
-- 14 bits). Hiermee is de BX-parts-catalogus compleet.
-- Bron: Beyblade Wiki (Fandom), CC-BY-SA. Afbeeldingen = wiki thumbnails.
-- Losse bey-producten/combo's volgen in een aparte batch.
-- weight_grams blijft leeg. Idempotent via vaste UUID's.

-- ===========================================================================
-- BLADES
-- ===========================================================================
insert into parts (id, canonical_name, category, line, type, spin_direction, image_url, wiki_url) values
  ('11111111-0000-4000-8000-000000000012','KnightLance','blade','BX','defense','right','https://static.wikia.nocookie.net/beyblade/images/c/cb/BladeKnightLance.png/revision/latest/scale-to-width-down/320?cb=20230808063816','https://beyblade.fandom.com/wiki/KnightLance_4-80HN'),
  ('11111111-0000-4000-8000-000000000013','DranDagger','blade','BX','attack','right','https://static.wikia.nocookie.net/beyblade/images/c/c8/BladeDranDagger.png/revision/latest/scale-to-width-down/320?cb=20250528202141','https://beyblade.fandom.com/wiki/DranDagger_4-60R'),
  ('11111111-0000-4000-8000-000000000014','WyvernGale','blade','BX','balance','right','https://static.wikia.nocookie.net/beyblade/images/3/3d/BladeWyvernGale.png/revision/latest/scale-to-width-down/320?cb=20231115091914','https://beyblade.fandom.com/wiki/WyvernGale_3-60T'),
  ('11111111-0000-4000-8000-000000000015','UnicornSting','blade','BX','balance','right','https://static.wikia.nocookie.net/beyblade/images/1/15/BladeUnicornSting.png/revision/latest/scale-to-width-down/320?cb=20240115194629','https://beyblade.fandom.com/wiki/UnicornSting_5-60GP'),
  ('11111111-0000-4000-8000-000000000016','SphinxCowl','blade','BX','balance','right','https://static.wikia.nocookie.net/beyblade/images/3/31/BladeSphinxCowl.png/revision/latest/scale-to-width-down/320?cb=20250528201304','https://beyblade.fandom.com/wiki/SphinxCowl_4-80HT'),
  ('11111111-0000-4000-8000-000000000017','WeissTiger','blade','BX','balance','right','https://static.wikia.nocookie.net/beyblade/images/3/37/BladeWeissTiger.png/revision/latest/scale-to-width-down/320?cb=20240515052303','https://beyblade.fandom.com/wiki/WeissTiger_3-60U'),
  ('11111111-0000-4000-8000-000000000018','CobaltDragoon','blade','BX','attack','left','https://static.wikia.nocookie.net/beyblade/images/c/c2/BladeCobaltDragoon.png/revision/latest/scale-to-width-down/320?cb=20250528202711','https://beyblade.fandom.com/wiki/CobaltDragoon_2-60C'),
  ('11111111-0000-4000-8000-000000000019','BlackShell','blade','BX','defense','right','https://static.wikia.nocookie.net/beyblade/images/3/3c/BladeBlackShell.png/revision/latest/scale-to-width-down/320?cb=20250528201216','https://beyblade.fandom.com/wiki/BlackShell_4-60D'),
  ('11111111-0000-4000-8000-000000000020','WizardRod','blade','BX','attack','right','https://static.wikia.nocookie.net/beyblade/images/a/a3/BladeWizardRod.png/revision/latest/scale-to-width-down/320?cb=20240222003334','https://beyblade.fandom.com/wiki/WizardRod_1-60R'),
  ('11111111-0000-4000-8000-000000000021','WhaleWave','blade','BX','balance','right','https://static.wikia.nocookie.net/beyblade/images/8/89/BladeWhaleWave.png/revision/latest/scale-to-width-down/320?cb=20240812022438','https://beyblade.fandom.com/wiki/WhaleWave_5-80E'),
  ('11111111-0000-4000-8000-000000000022','CrimsonGaruda','blade','BX','balance','right','https://static.wikia.nocookie.net/beyblade/images/6/60/BladeCrimsonGaruda.png/revision/latest/scale-to-width-down/320?cb=20241015052049','https://beyblade.fandom.com/wiki/CrimsonGaruda_4-70TP'),
  ('11111111-0000-4000-8000-000000000023','ShelterDrake','blade','BX','defense','right','https://static.wikia.nocookie.net/beyblade/images/8/89/BladeShelterDrake.png/revision/latest/scale-to-width-down/320?cb=20250530222732','https://beyblade.fandom.com/wiki/ShelterDrake_3-60D'),
  ('11111111-0000-4000-8000-000000000024','TriceraPress','blade','BX','defense','right','https://static.wikia.nocookie.net/beyblade/images/4/48/BladeTriceraPress.png/revision/latest/scale-to-width-down/320?cb=20250515033251','https://beyblade.fandom.com/wiki/TriceraPress_M-85BS'),
  ('11111111-0000-4000-8000-000000000025','SamuraiCalibur','blade','BX','balance','right','https://static.wikia.nocookie.net/beyblade/images/a/ab/BladeSamuraiCalibur.png/revision/latest/scale-to-width-down/320?cb=20250715051328','https://beyblade.fandom.com/wiki/SamuraiCalibur_6-70M'),
  ('11111111-0000-4000-8000-000000000026','CobaltDrake','blade','BX','attack','right','https://static.wikia.nocookie.net/beyblade/images/2/2f/BladeCobaltDrake.png/revision/latest/scale-to-width-down/320?cb=20250528202030','https://beyblade.fandom.com/wiki/CobaltDrake_9-60R'),
  ('11111111-0000-4000-8000-000000000027','GoatTackle','blade','BX','balance','right','https://static.wikia.nocookie.net/beyblade/images/1/1f/BladeGoatTackle.png/revision/latest/scale-to-width-down/320?cb=20250828045656','https://beyblade.fandom.com/wiki/GoatTackle_7-70T'),
  ('11111111-0000-4000-8000-000000000028','DranBuster','blade','BX','attack','right','https://static.wikia.nocookie.net/beyblade/images/d/db/BladeDranBuster.png/revision/latest/scale-to-width-down/320?cb=20250528202327','https://beyblade.fandom.com/wiki/DranBuster_2-80Q'),
  ('11111111-0000-4000-8000-000000000029','MammothTusk','blade','BX','defense','right',null,'https://beyblade.fandom.com/wiki/MammothTusk_7-60S'),
  ('11111111-0000-4000-8000-000000000030','DranStrike','blade','BX','attack','right','https://static.wikia.nocookie.net/beyblade/images/6/67/BladeDranStrike.png/revision/latest/scale-to-width-down/320?cb=20260313031347','https://beyblade.fandom.com/wiki/DranStrike_4-50FF')
on conflict (id) do update set type=excluded.type, spin_direction=excluded.spin_direction, image_url=excluded.image_url, wiki_url=excluded.wiki_url;

-- ===========================================================================
-- RATCHETS
-- ===========================================================================
insert into parts (id, canonical_name, category, line, ratchet_height, image_url) values
  ('22222222-0000-4000-8000-000000000160','1-60','ratchet','BX','60','https://static.wikia.nocookie.net/beyblade/images/3/3a/Ratchet1-60.png/revision/latest/scale-to-width-down/320?cb=20240215060550'),
  ('22222222-0000-4000-8000-000000000260','2-60','ratchet','BX','60','https://static.wikia.nocookie.net/beyblade/images/a/a6/Ratchet2-60.png/revision/latest/scale-to-width-down/320?cb=20240614034142'),
  ('22222222-0000-4000-8000-000000000280','2-80','ratchet','BX','80','https://static.wikia.nocookie.net/beyblade/images/d/dc/Ratchet2-80.png/revision/latest/scale-to-width-down/320?cb=20240527053613'),
  ('22222222-0000-4000-8000-000000000370','3-70','ratchet','BX','70','https://static.wikia.nocookie.net/beyblade/images/d/da/Ratchet3-70.png/revision/latest/scale-to-width-down/320?cb=20240215060619'),
  ('22222222-0000-4000-8000-000000000385','3-85','ratchet','BX','85','https://static.wikia.nocookie.net/beyblade/images/b/b8/Ratchet3-85.png/revision/latest/scale-to-width-down/320?cb=20260202220915'),
  ('22222222-0000-4000-8000-000000000450','4-50','ratchet','BX','50','https://static.wikia.nocookie.net/beyblade/images/2/2a/Ratchet4-50.png/revision/latest/scale-to-width-down/320?cb=20250715051521'),
  ('22222222-0000-4000-8000-000000000570','5-70','ratchet','BX','70','https://static.wikia.nocookie.net/beyblade/images/c/cc/Ratchet5-70.png/revision/latest/scale-to-width-down/320?cb=20240215060642'),
  ('22222222-0000-4000-8000-000000000670','6-70','ratchet','BX','70','https://static.wikia.nocookie.net/beyblade/images/1/14/Ratchet6-70.png/revision/latest/scale-to-width-down/320?cb=20250715051344'),
  ('22222222-0000-4000-8000-000000000760','7-60','ratchet','BX','60','https://static.wikia.nocookie.net/beyblade/images/3/39/Ratchet7-60.png/revision/latest/scale-to-width-down/320?cb=20240712055419'),
  ('22222222-0000-4000-8000-000000000770','7-70','ratchet','BX','70','https://static.wikia.nocookie.net/beyblade/images/3/38/Ratchet7-70.png/revision/latest/scale-to-width-down/320?cb=20241015043216'),
  ('22222222-0000-4000-8000-000000000780','7-80','ratchet','BX','80','https://static.wikia.nocookie.net/beyblade/images/d/d7/Ratchet7-80.png/revision/latest/scale-to-width-down/320?cb=20250115050921'),
  ('22222222-0000-4000-8000-000000000980','9-80','ratchet','BX','80','https://static.wikia.nocookie.net/beyblade/images/6/61/Ratchet9-80.png/revision/latest/scale-to-width-down/320?cb=20240115193705'),
  ('22222222-0000-4000-8000-000000000a85','M-85','ratchet','BX','85','https://static.wikia.nocookie.net/beyblade/images/7/79/RatchetM-85.png/revision/latest/scale-to-width-down/320?cb=20250515033258')
on conflict (id) do update set ratchet_height=excluded.ratchet_height, image_url=excluded.image_url;

-- ===========================================================================
-- BITS  (afkorting -> volledige naam, geverifieerd op de wiki)
-- ===========================================================================
insert into parts (id, canonical_name, category, line, image_url) values
  ('33333333-0000-4000-8000-000000000012','Cyclone','bit','BX','https://static.wikia.nocookie.net/beyblade/images/f/fb/BitCyclone.png/revision/latest?cb=20240614034151'),
  ('33333333-0000-4000-8000-000000000013','Dot','bit','BX','https://static.wikia.nocookie.net/beyblade/images/b/b2/BitDot.png/revision/latest?cb=20240614034756'),
  ('33333333-0000-4000-8000-000000000014','Elevate','bit','BX','https://static.wikia.nocookie.net/beyblade/images/3/38/BitElevate.png/revision/latest?cb=20240812022551'),
  ('33333333-0000-4000-8000-000000000015','Free Flat','bit','BX','https://static.wikia.nocookie.net/beyblade/images/b/b4/BitFreeFlat.png/revision/latest?cb=20260313031408'),
  ('33333333-0000-4000-8000-000000000016','Gear Ball','bit','BX','https://static.wikia.nocookie.net/beyblade/images/9/97/BitGearBall.png/revision/latest?cb=20231115091947'),
  ('33333333-0000-4000-8000-000000000017','Gear Needle','bit','BX','https://static.wikia.nocookie.net/beyblade/images/9/9d/BitGearNeedle.png/revision/latest?cb=20240116063659'),
  ('33333333-0000-4000-8000-000000000018','Gear Point','bit','BX','https://static.wikia.nocookie.net/beyblade/images/3/36/BitGearPoint.png/revision/latest?cb=20240115194709'),
  ('33333333-0000-4000-8000-000000000019','Hexa','bit','BX','https://static.wikia.nocookie.net/beyblade/images/8/8c/BitHexa.png/revision/latest?cb=20240215060626'),
  ('33333333-0000-4000-8000-000000000020','High Needle','bit','BX','https://static.wikia.nocookie.net/beyblade/images/2/2f/BitHighNeedle.png/revision/latest?cb=20230808063846'),
  ('33333333-0000-4000-8000-000000000021','Merge','bit','BX','https://static.wikia.nocookie.net/beyblade/images/5/5e/BitMerge.png/revision/latest?cb=20250715051358'),
  ('33333333-0000-4000-8000-000000000022','Rush','bit','BX','https://static.wikia.nocookie.net/beyblade/images/e/e1/BitRush.png/revision/latest?cb=20231014022216'),
  ('33333333-0000-4000-8000-000000000023','Trans Point','bit','BX','https://static.wikia.nocookie.net/beyblade/images/d/d0/BitTransPoint.png/revision/latest?cb=20241015052109'),
  ('33333333-0000-4000-8000-000000000024','Unite','bit','BX','https://static.wikia.nocookie.net/beyblade/images/a/a0/BitUnite.png/revision/latest?cb=20240515052315'),
  ('33333333-0000-4000-8000-000000000025','Bound Spike','bit','BX','https://static.wikia.nocookie.net/beyblade/images/8/88/BitBoundSpike.png/revision/latest?cb=20241015034935')
on conflict (id) do update set canonical_name=excluded.canonical_name, image_url=excluded.image_url;

-- ===========================================================================
-- PART ALIASES: Hasbro-namen (blades zonder alias overgeslagen)
-- ===========================================================================
insert into part_aliases (part_id, brand, name, region) values
  ('11111111-0000-4000-8000-000000000012','hasbro','Lance Knight','US'),
  ('11111111-0000-4000-8000-000000000013','hasbro','Dagger Dran','US'),
  ('11111111-0000-4000-8000-000000000014','hasbro','Gale Wyvern','US'),
  ('11111111-0000-4000-8000-000000000015','hasbro','Sting Unicorn','US'),
  ('11111111-0000-4000-8000-000000000017','hasbro','Pearl Tiger','US'),
  ('11111111-0000-4000-8000-000000000018','hasbro','Cobalt Dragoon','US'),
  ('11111111-0000-4000-8000-000000000019','hasbro','Obsidian Shell','US'),
  ('11111111-0000-4000-8000-000000000020','hasbro','Wand Wizard','US'),
  ('11111111-0000-4000-8000-000000000021','hasbro','Tide Whale','US'),
  ('11111111-0000-4000-8000-000000000022','hasbro','Scarlet Garuda','US'),
  ('11111111-0000-4000-8000-000000000024','hasbro','Brace Triceratops','US'),
  ('11111111-0000-4000-8000-000000000025','hasbro','Calibur Samurai','US'),
  ('11111111-0000-4000-8000-000000000029','hasbro','Tusk Mammoth','US'),
  ('11111111-0000-4000-8000-000000000030','hasbro','Strike Dran','US')
on conflict (part_id, brand, name) do nothing;


-- ============ 0014_product_hasbro_names.sql ============
-- 0014_product_hasbro_names.sql
-- Hasbro EU-productnamen (zoals op de Europese verpakking). De app toont deze
-- als weergavenaam; de TT-naam (canonical_name) blijft als referentie bestaan.
-- Geverifieerd tegen de Hasbro-productlijst op de Beyblade Wiki.

alter table products add column if not exists hasbro_name text;

update products set hasbro_name = 'Sword Dran 3-60F'     where id = '44444444-0000-4000-8000-000000000001';
update products set hasbro_name = 'Scythe Incendio 4-60T' where id = '44444444-0000-4000-8000-000000000002';
update products set hasbro_name = 'Arrow Wizard 4-80B'    where id = '44444444-0000-4000-8000-000000000003';
update products set hasbro_name = 'Helm Knight 3-80N'     where id = '44444444-0000-4000-8000-000000000004';
update products set hasbro_name = 'Keel Shark 3-60LF'     where id = '44444444-0000-4000-8000-000000000014';
update products set hasbro_name = 'Claw Leon 5-60P'       where id = '44444444-0000-4000-8000-000000000015';
update products set hasbro_name = 'Horn Rhino 3-80S'      where id = '44444444-0000-4000-8000-000000000019';
update products set hasbro_name = 'Soar Phoenix 9-60GF'   where id = '44444444-0000-4000-8000-000000000023';
update products set hasbro_name = 'Tail Viper 5-80O'      where id = '44444444-0000-4000-8000-000000000016';
update products set hasbro_name = 'Chain Incendio 5-60HT' where id = '44444444-0000-4000-8000-000000000021';
update products set hasbro_name = 'Beat Tyranno 4-70Q'    where id = '44444444-0000-4000-8000-000000000031';


-- ============ 0015_seed_ux_parts.sql ============
-- 0015_seed_ux_parts.sql
-- Seed: alle canonieke UX-onderdelen (Unique Line).
-- 15 blades + 1 ratchet-integrated blade (BulletGriffon), 7 ratchets, 12 bits.
-- Hasbro-namen als alias (weergavenaam). Bron: Beyblade Wiki (Fandom), CC-BY-SA.
-- Ook: DranBuster en WizardRod stonden per abuis op lijn BX maar zijn Unique.

-- ===========================================================================
-- Lijn-correctie: DranBuster en WizardRod zijn UX (Unique Line)
-- ===========================================================================
update parts set line = 'UX' where id in (
  '11111111-0000-4000-8000-000000000028',  -- DranBuster
  '11111111-0000-4000-8000-000000000020'   -- WizardRod
);

-- ===========================================================================
-- UX BLADES (Unique)
-- ===========================================================================
insert into parts (id, canonical_name, category, line, type, spin_direction, image_url, wiki_url) values
  ('11111111-0000-4000-8000-000000000031','HellsHammer','blade','UX','balance','right','https://static.wikia.nocookie.net/beyblade/images/6/67/BladeHellsHammer.png/revision/latest/scale-to-width-down/320?cb=20240215060611','https://beyblade.fandom.com/wiki/HellsHammer_3-70H'),
  ('11111111-0000-4000-8000-000000000032','ShinobiShadow','blade','UX','defense','right','https://static.wikia.nocookie.net/beyblade/images/4/48/BladeShinobiShadow.png/revision/latest/scale-to-width-down/320?cb=20250528201917','https://beyblade.fandom.com/wiki/ShinobiShadow_1-80MN'),
  ('11111111-0000-4000-8000-000000000033','LeonCrest','blade','UX','defense','right','https://static.wikia.nocookie.net/beyblade/images/c/c7/BladeLeonCrest.png/revision/latest/scale-to-width-down/320?cb=20240712055426','https://beyblade.fandom.com/wiki/LeonCrest_7-60GN'),
  ('11111111-0000-4000-8000-000000000034','PhoenixRudder','blade','UX','stamina','right','https://static.wikia.nocookie.net/beyblade/images/0/0f/BladePhoenixRudder.png/revision/latest/scale-to-width-down/320?cb=20250528203411','https://beyblade.fandom.com/wiki/PhoenixRudder_9-70G'),
  ('11111111-0000-4000-8000-000000000035','SilverWolf','blade','UX','stamina','right','https://static.wikia.nocookie.net/beyblade/images/f/f1/BladeSilverWolf.png/revision/latest/scale-to-width-down/320?cb=20240913034202','https://beyblade.fandom.com/wiki/SilverWolf_3-80FB'),
  ('11111111-0000-4000-8000-000000000036','SamuraiSaber','blade','UX','attack','right','https://static.wikia.nocookie.net/beyblade/images/d/de/BladeSamuraiSaber.png/revision/latest/scale-to-width-down/320?cb=20241015033005','https://beyblade.fandom.com/wiki/SamuraiSaber_2-70L'),
  ('11111111-0000-4000-8000-000000000037','KnightMail','blade','UX','defense','right','https://static.wikia.nocookie.net/beyblade/images/f/fc/BladeKnightMail.png/revision/latest/scale-to-width-down/320?cb=20241015034144','https://beyblade.fandom.com/wiki/KnightMail_3-85BS'),
  ('11111111-0000-4000-8000-000000000038','ImpactDrake','blade','UX','attack','right','https://static.wikia.nocookie.net/beyblade/images/b/b1/BladeImpactDrake.png/revision/latest/scale-to-width-down/320?cb=20241115024018','https://beyblade.fandom.com/wiki/ImpactDrake_9-60LR'),
  ('11111111-0000-4000-8000-000000000039','GhostCircle','blade','UX','stamina','right','https://static.wikia.nocookie.net/beyblade/images/7/7a/BladeGhostCircle.png/revision/latest/scale-to-width-down/320?cb=20241115025132','https://beyblade.fandom.com/wiki/GhostCircle_0-80GB'),
  ('11111111-0000-4000-8000-000000000040','GolemRock','blade','UX','defense','right','https://static.wikia.nocookie.net/beyblade/images/2/27/BladeGolemRock.png/revision/latest/scale-to-width-down/320?cb=20250115052241','https://beyblade.fandom.com/wiki/GolemRock_1-60UN'),
  ('11111111-0000-4000-8000-000000000041','ScorpioSpear','blade','UX','balance','right','https://static.wikia.nocookie.net/beyblade/images/8/89/BladeScorpioSpear.png/revision/latest/scale-to-width-down/320?cb=20250614081207','https://beyblade.fandom.com/wiki/ScorpioSpear_0-70Z'),
  ('11111111-0000-4000-8000-000000000042','SharkScale','blade','UX','attack','right','https://static.wikia.nocookie.net/beyblade/images/e/e0/BladeSharkScale.png/revision/latest/scale-to-width-down/320?cb=20250715051433','https://beyblade.fandom.com/wiki/SharkScale_4-50UF'),
  ('11111111-0000-4000-8000-000000000043','ClockMirage','blade','UX','stamina','right','https://static.wikia.nocookie.net/beyblade/images/7/7c/BladeClockMirage.png/revision/latest/scale-to-width-down/320?cb=20250912034434','https://beyblade.fandom.com/wiki/ClockMirage_9-65B'),
  ('11111111-0000-4000-8000-000000000044','MeteorDragoon','blade','UX','attack','left','https://static.wikia.nocookie.net/beyblade/images/b/b7/BladeMeteorDragoon.png/revision/latest?cb=20251114032400','https://beyblade.fandom.com/wiki/MeteorDragoon_3-70J'),
  ('11111111-0000-4000-8000-000000000045','MummyCurse','blade','UX','defense','right','https://static.wikia.nocookie.net/beyblade/images/a/ab/BladeMummyCurse.png/revision/latest/scale-to-width-down/320?cb=20251114034130','https://beyblade.fandom.com/wiki/MummyCurse_7-55W')
on conflict (id) do update set type=excluded.type, spin_direction=excluded.spin_direction, image_url=excluded.image_url, wiki_url=excluded.wiki_url;

-- Ratchet-Integrated Blade (UX Expand)
insert into parts (id, canonical_name, category, line, type, spin_direction, image_url, wiki_url) values
  ('11111111-0000-4000-8000-000000000046','BulletGriffon','ratchet_integrated_blade','UX','balance','right','https://static.wikia.nocookie.net/beyblade/images/d/d2/RatchetBladeBulletGriffon.png/revision/latest/scale-to-width-down/320?cb=20260313031310','https://beyblade.fandom.com/wiki/BulletGriffon_H')
on conflict (id) do update set type=excluded.type, image_url=excluded.image_url, wiki_url=excluded.wiki_url;

-- ===========================================================================
-- UX RATCHETS
-- ===========================================================================
insert into parts (id, canonical_name, category, line, ratchet_height, image_url) values
  ('22222222-0000-4000-8000-000000000180','1-80','ratchet','UX','80','https://static.wikia.nocookie.net/beyblade/images/4/46/Ratchet1-80.png/revision/latest?cb=20240513065345'),
  ('22222222-0000-4000-8000-000000000270','2-70','ratchet','UX','70','https://static.wikia.nocookie.net/beyblade/images/c/cb/Ratchet2-70.png/revision/latest/scale-to-width-down/320?cb=20241015033717'),
  ('22222222-0000-4000-8000-000000000070','0-70','ratchet','UX','70','https://static.wikia.nocookie.net/beyblade/images/0/08/Ratchet0-70.png/revision/latest/scale-to-width-down/320?cb=20250415034357'),
  ('22222222-0000-4000-8000-000000000080','0-80','ratchet','UX','80','https://static.wikia.nocookie.net/beyblade/images/a/ac/Ratchet0-80.png/revision/latest/scale-to-width-down/320?cb=20241115025146'),
  ('22222222-0000-4000-8000-000000000965','9-65','ratchet','UX','65','https://static.wikia.nocookie.net/beyblade/images/2/25/Ratchet9-65.png/revision/latest/scale-to-width-down/320?cb=20250912034512'),
  ('22222222-0000-4000-8000-000000000970','9-70','ratchet','UX','70','https://static.wikia.nocookie.net/beyblade/images/8/86/Ratchet9-70.png/revision/latest/scale-to-width-down/320?cb=20240712055351'),
  ('22222222-0000-4000-8000-000000000755','7-55','ratchet','UX','55','https://static.wikia.nocookie.net/beyblade/images/a/af/Ratchet7-55.png/revision/latest?cb=20251114034152')
on conflict (id) do update set ratchet_height=excluded.ratchet_height, image_url=excluded.image_url;

-- ===========================================================================
-- UX BITS
-- ===========================================================================
insert into parts (id, canonical_name, category, line, image_url) values
  ('33333333-0000-4000-8000-000000000026','Accel','bit','UX','https://static.wikia.nocookie.net/beyblade/images/8/8e/BitAccel.png/revision/latest?cb=20240215060559'),
  ('33333333-0000-4000-8000-000000000027','Disk Ball','bit','UX','https://static.wikia.nocookie.net/beyblade/images/1/10/BitDiskBall.png/revision/latest?cb=20240215060650'),
  ('33333333-0000-4000-8000-000000000028','Metal Needle','bit','UX','https://static.wikia.nocookie.net/beyblade/images/4/47/BitMetalNeedle.png/revision/latest?cb=20240416003755'),
  ('33333333-0000-4000-8000-000000000029','Glide','bit','UX','https://static.wikia.nocookie.net/beyblade/images/d/d5/BitGlide.png/revision/latest?cb=20240712055345'),
  ('33333333-0000-4000-8000-000000000030','Free Ball','bit','UX','https://static.wikia.nocookie.net/beyblade/images/7/78/BitFreeBall.png/revision/latest?cb=20240913034835'),
  ('33333333-0000-4000-8000-000000000031','Level','bit','UX','https://static.wikia.nocookie.net/beyblade/images/5/56/BitLevel.png/revision/latest?cb=20241015033722'),
  ('33333333-0000-4000-8000-000000000032','Low Rush','bit','UX','https://static.wikia.nocookie.net/beyblade/images/3/36/BitLowRush.png/revision/latest?cb=20241115024042'),
  ('33333333-0000-4000-8000-000000000033','Under Needle','bit','UX','https://static.wikia.nocookie.net/beyblade/images/1/16/BitUnderNeedle.png/revision/latest?cb=20250115052342'),
  ('33333333-0000-4000-8000-000000000034','Zap','bit','UX','https://static.wikia.nocookie.net/beyblade/images/6/61/BitZap.png/revision/latest?cb=20250415034411'),
  ('33333333-0000-4000-8000-000000000035','Under Flat','bit','UX','https://static.wikia.nocookie.net/beyblade/images/5/55/BitUnderFlat.png/revision/latest?cb=20250715051536'),
  ('33333333-0000-4000-8000-000000000036','Jolt','bit','UX','https://static.wikia.nocookie.net/beyblade/images/1/10/BitJolt.png/revision/latest?cb=20251114032437'),
  ('33333333-0000-4000-8000-000000000037','Wedge','bit','UX','https://static.wikia.nocookie.net/beyblade/images/2/29/BitWedge.png/revision/latest?cb=20250215050716')
on conflict (id) do update set canonical_name=excluded.canonical_name, image_url=excluded.image_url;

-- ===========================================================================
-- PART ALIASES: Hasbro-namen (ClockMirage overgeslagen: nog niet bevestigd)
-- ===========================================================================
insert into part_aliases (part_id, brand, name, region) values
  ('11111111-0000-4000-8000-000000000031','hasbro','Hammer Incendio','US'),
  ('11111111-0000-4000-8000-000000000032','hasbro','Shadow Shinobi','US'),
  ('11111111-0000-4000-8000-000000000033','hasbro','Crest Leon','US'),
  ('11111111-0000-4000-8000-000000000034','hasbro','Rudder Phoenix','US'),
  ('11111111-0000-4000-8000-000000000035','hasbro','Sterling Wolf','US'),
  ('11111111-0000-4000-8000-000000000036','hasbro','Saber Samurai','US'),
  ('11111111-0000-4000-8000-000000000037','hasbro','Mail Knight','US'),
  ('11111111-0000-4000-8000-000000000038','hasbro','Impact Drake','US'),
  ('11111111-0000-4000-8000-000000000039','hasbro','Circle Ghost','US'),
  ('11111111-0000-4000-8000-000000000040','hasbro','Rock Golem','US'),
  ('11111111-0000-4000-8000-000000000041','hasbro','Spear Scorpio','US'),
  ('11111111-0000-4000-8000-000000000042','hasbro','Scale Shark','US'),
  ('11111111-0000-4000-8000-000000000044','hasbro','Meteoroid Dragoon','US'),
  ('11111111-0000-4000-8000-000000000045','hasbro','Curse Mummy','US'),
  ('11111111-0000-4000-8000-000000000046','hasbro','Rocket Griffon','US')
on conflict (part_id, brand, name) do nothing;


-- ============ 0016_seed_cx_parts.sql ============
-- 0016_seed_cx_parts.sql
-- Seed: alle canonieke CX-onderdelen (Custom Line).
-- Lock Chips, Main Blades, Assist Blades, Metal Blades, Over Blades, nieuwe
-- Ratchets, nieuwe Bits, en Ratchet-Integrated Bits (Turbo, Operate).
-- type/spin blijven leeg: bij CX bepaalt de combinatie het type, niet 1 blade.
-- Bron: Beyblade Wiki (Fandom), CC-BY-SA. Idempotent via vaste UUID's.

-- ===========================================================================
-- LOCK CHIPS (prefix 66666666)
-- ===========================================================================
insert into parts (id, canonical_name, category, line, image_url) values
  ('66666666-0000-4000-8000-000000000001','Dran','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/6/6c/LockChipDran.png/revision/latest?cb=20250215050437'),
  ('66666666-0000-4000-8000-000000000002','Wizard','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/4/43/LockChipWizard.png/revision/latest?cb=20250215050531'),
  ('66666666-0000-4000-8000-000000000003','Perseus','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/6/6a/LockChipPerseus.png/revision/latest?cb=20250215050629'),
  ('66666666-0000-4000-8000-000000000004','Pegasus','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/8/86/LockChipPegasus.png/revision/latest?cb=20250613042010'),
  ('66666666-0000-4000-8000-000000000005','Sol','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/6/6e/LockChipSol.png/revision/latest?cb=20250812023449'),
  ('66666666-0000-4000-8000-000000000006','Wolf','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/6/6a/LockChipWolf.png/revision/latest?cb=20251015204952'),
  ('66666666-0000-4000-8000-000000000007','Phoenix','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/7/7a/LockChipPhoenix.png/revision/latest?cb=20260115042959'),
  ('66666666-0000-4000-8000-000000000008','Bahamut','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/e/e4/LockChipBahamut.png/revision/latest?cb=20260214040353'),
  ('66666666-0000-4000-8000-000000000009','Knight','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/c/c2/LockChipKnight.png/revision/latest?cb=20260214040509'),
  ('66666666-0000-4000-8000-000000000010','Ragna','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/9/9b/LockChipRagna.png/revision/latest?cb=20260214043116'),
  ('66666666-0000-4000-8000-000000000011','Emperor','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/2/2b/LockChipEmperor.png/revision/latest?cb=20251015205115'),
  ('66666666-0000-4000-8000-000000000012','Hells','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/7/7a/LockChipHells.png/revision/latest?cb=20250314041513'),
  ('66666666-0000-4000-8000-000000000013','Rhino','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/d/d7/LockChipRhino.png/revision/latest/scale-to-width-down/320?cb=20250404235409'),
  ('66666666-0000-4000-8000-000000000014','Fox','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/6/65/LockChipFox.png/revision/latest?cb=20250415032832'),
  ('66666666-0000-4000-8000-000000000015','Whale','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/7/75/LockChipWhale.png/revision/latest?cb=20250613042706'),
  ('66666666-0000-4000-8000-000000000016','Cerberus','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/b/bd/LockChipCerberus.png/revision/latest?cb=20250613042044'),
  ('66666666-0000-4000-8000-000000000017','Unicorn','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/4/4e/LockChipUnicorn.png/revision/latest?cb=20260415025415'),
  ('66666666-0000-4000-8000-000000000018','Brachio','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/6/6d/LockChipBrachio.png/revision/latest?cb=20260517042128'),
  ('66666666-0000-4000-8000-000000000019','Valkyrie','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/b/b4/LockChipValkyrie.png/revision/latest/scale-to-width-down/320?cb=20250715032014'),
  ('66666666-0000-4000-8000-000000000020','Leon','lock_chip','CX','https://static.wikia.nocookie.net/beyblade/images/1/1a/LockChipLeon.png/revision/latest?cb=20250515031153')
on conflict (id) do update set image_url=excluded.image_url;

-- ===========================================================================
-- MAIN BLADES (prefix 77777777)
-- ===========================================================================
insert into parts (id, canonical_name, category, line, image_url) values
  ('77777777-0000-4000-8000-000000000001','Brave','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/d/df/MainBladeBrave.png/revision/latest/scale-to-width-down/320?cb=20250727212836'),
  ('77777777-0000-4000-8000-000000000002','Arc','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/f/f5/MainBladeArc.png/revision/latest/scale-to-width-down/320?cb=20250801190723'),
  ('77777777-0000-4000-8000-000000000003','Dark','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/e/e0/MainBladeDark.png/revision/latest/scale-to-width-down/320?cb=20250215050646'),
  ('77777777-0000-4000-8000-000000000004','Blast','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/5/5f/MainBladeBlast.png/revision/latest/scale-to-width-down/320?cb=20250613042021'),
  ('77777777-0000-4000-8000-000000000005','Eclipse','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/5/53/MainBladeEclipse_%28Smash_Mode%29.png/revision/latest/scale-to-width-down/320?cb=20250812023508'),
  ('77777777-0000-4000-8000-000000000006','Hunt','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/4/4d/MainBladeHunt.png/revision/latest/scale-to-width-down/320?cb=20251015205016'),
  ('77777777-0000-4000-8000-000000000007','Flare','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/d/d3/MainBladeFlare.png/revision/latest/scale-to-width-down/320?cb=20260115043015'),
  ('77777777-0000-4000-8000-000000000008','Might','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/0/07/MainBladeMight.png/revision/latest/scale-to-width-down/320?cb=20251015205128'),
  ('77777777-0000-4000-8000-000000000009','Reaper','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/a/a4/MainBladeReaper.png/revision/latest/scale-to-width-down/320?cb=20250314041624'),
  ('77777777-0000-4000-8000-000000000010','Brush','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/e/e7/MainBladeBrush.png/revision/latest/scale-to-width-down/320?cb=20250415032849'),
  ('77777777-0000-4000-8000-000000000011','Flame','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/9/99/MainBladeFlame.png/revision/latest/scale-to-width-down/320?cb=20250613042102'),
  ('77777777-0000-4000-8000-000000000012','Volt','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/0/04/MainBladeVolt.png/revision/latest/scale-to-width-down/320?cb=20260218211332')
on conflict (id) do update set image_url=excluded.image_url;

-- ===========================================================================
-- ASSIST BLADES (prefix 88888888)
-- ===========================================================================
insert into parts (id, canonical_name, category, line, image_url) values
  ('88888888-0000-4000-8000-000000000001','Slash','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/c/cb/AssistBladeSlash.png/revision/latest/scale-to-width-down/320?cb=20250215050454'),
  ('88888888-0000-4000-8000-000000000002','Round','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/3/3c/AssistBladeRound.png/revision/latest/scale-to-width-down/320?cb=20250215050554'),
  ('88888888-0000-4000-8000-000000000003','Bumper','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/a/aa/AssistBladeBumper.png/revision/latest/scale-to-width-down/320?cb=20250215050654'),
  ('88888888-0000-4000-8000-000000000004','Assault','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/2/24/AssistBladeAssault.png/revision/latest/scale-to-width-down/320?cb=20250613042027'),
  ('88888888-0000-4000-8000-000000000005','Dual','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/2/22/AssistBladeDual_%28Smash_Mode%29.png/revision/latest/scale-to-width-down/320?cb=20250918112418'),
  ('88888888-0000-4000-8000-000000000006','Free','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/b/be/AssistBladeFree.png/revision/latest/scale-to-width-down/320?cb=20251015205027'),
  ('88888888-0000-4000-8000-000000000007','Zillion','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/3/37/AssistBladeZillion.png/revision/latest/scale-to-width-down/320?cb=20260115043035'),
  ('88888888-0000-4000-8000-000000000008','Heavy','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/0/0b/AssistBladeHeavy.png/revision/latest/scale-to-width-down/320?cb=20251015205145'),
  ('88888888-0000-4000-8000-000000000009','Turn','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/2/2c/AssistBladeTurn.png/revision/latest/scale-to-width-down/320?cb=20250314041629'),
  ('88888888-0000-4000-8000-000000000010','Charge','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/8/89/AssistBladeCharge.png/revision/latest/scale-to-width-down/320?cb=20250314041928'),
  ('88888888-0000-4000-8000-000000000011','Jaggy','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/1/14/AssistBladeJaggy.png/revision/latest/scale-to-width-down/320?cb=20250415032856'),
  ('88888888-0000-4000-8000-000000000012','Massive','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/2/23/AssistBladeMassive.png/revision/latest/scale-to-width-down/320?cb=20250613042947'),
  ('88888888-0000-4000-8000-000000000013','Wheel','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/3/3d/AssistBladeWheel.png/revision/latest/scale-to-width-down/320?cb=20250613042109')
on conflict (id) do update set image_url=excluded.image_url;

-- ===========================================================================
-- METAL BLADES (prefix 99999999) en OVER BLADES (prefix aaaaaaaa) — CX Expand
-- ===========================================================================
insert into parts (id, canonical_name, category, line, image_url) values
  ('99999999-0000-4000-8000-000000000001','Blitz','metal_blade','CX','https://static.wikia.nocookie.net/beyblade/images/2/28/MetalBladeBlitz.png/revision/latest/scale-to-width-down/320?cb=20260214040423'),
  ('99999999-0000-4000-8000-000000000002','Fortress','metal_blade','CX','https://static.wikia.nocookie.net/beyblade/images/8/81/MetalBladeFortress.png/revision/latest/scale-to-width-down/320?cb=20260214040527'),
  ('99999999-0000-4000-8000-000000000003','Rage','metal_blade','CX','https://static.wikia.nocookie.net/beyblade/images/d/d0/MetalBladeRage.png/revision/latest/scale-to-width-down/320?cb=20260214043148'),
  ('99999999-0000-4000-8000-000000000004','Delta','metal_blade','CX','https://static.wikia.nocookie.net/beyblade/images/1/19/MetalBladeDelta.png/revision/latest/scale-to-width-down/320?cb=20260415025431'),
  ('99999999-0000-4000-8000-000000000005','Whip','metal_blade','CX','https://static.wikia.nocookie.net/beyblade/images/5/59/MetalBladeWhip.png/revision/latest/scale-to-width-down/320?cb=20260517042545'),
  ('aaaaaaaa-0000-4000-8000-000000000001','Break','over_blade','CX','https://static.wikia.nocookie.net/beyblade/images/3/38/OverBladeBreak.png/revision/latest?cb=20260214040407'),
  ('aaaaaaaa-0000-4000-8000-000000000002','Guard','over_blade','CX','https://static.wikia.nocookie.net/beyblade/images/8/8b/OverBladeGuard.png/revision/latest?cb=20260214040517'),
  ('aaaaaaaa-0000-4000-8000-000000000003','Flow','over_blade','CX','https://static.wikia.nocookie.net/beyblade/images/0/00/OverBladeFlow.png/revision/latest?cb=20260214043129'),
  ('aaaaaaaa-0000-4000-8000-000000000004','Peak','over_blade','CX','https://static.wikia.nocookie.net/beyblade/images/0/01/OverBladePeak.png/revision/latest/scale-to-width-down/320?cb=20260415025424'),
  ('aaaaaaaa-0000-4000-8000-000000000005','Outer','over_blade','CX','https://static.wikia.nocookie.net/beyblade/images/f/f2/OverBladeOuter.png/revision/latest/scale-to-width-down/320?cb=20260517042333')
on conflict (id) do update set image_url=excluded.image_url;

-- ===========================================================================
-- CX RATCHETS (nieuw)
-- ===========================================================================
insert into parts (id, canonical_name, category, line, ratchet_height, image_url) values
  ('22222222-0000-4000-8000-000000000660','6-60','ratchet','CX','60','https://static.wikia.nocookie.net/beyblade/images/5/53/Ratchet6-60.png/revision/latest/scale-to-width-down/320?cb=20250215050512'),
  ('22222222-0000-4000-8000-000000000060','0-60','ratchet','CX','60','https://static.wikia.nocookie.net/beyblade/images/2/20/Ratchet0-60.png/revision/latest/scale-to-width-down/320?cb=20251015205044'),
  ('22222222-0000-4000-8000-000000000150','1-50','ratchet','CX','50','https://static.wikia.nocookie.net/beyblade/images/c/c2/Ratchet1-50.png/revision/latest/scale-to-width-down/320?cb=20260214040444'),
  ('22222222-0000-4000-8000-000000000870','8-70','ratchet','CX','70','https://static.wikia.nocookie.net/beyblade/images/c/ca/Ratchet8-70.png/revision/latest/scale-to-width-down/320?cb=20260214040608')
on conflict (id) do update set ratchet_height=excluded.ratchet_height, image_url=excluded.image_url;

-- ===========================================================================
-- CX BITS (nieuw; Wedge en Under Needle bestonden al via UX -> overgeslagen)
-- ===========================================================================
insert into parts (id, canonical_name, category, line, image_url) values
  ('33333333-0000-4000-8000-000000000038','Vortex','bit','CX','https://static.wikia.nocookie.net/beyblade/images/f/f9/BitVortex.png/revision/latest?cb=20250215050522'),
  ('33333333-0000-4000-8000-000000000039','Low Orb','bit','CX','https://static.wikia.nocookie.net/beyblade/images/f/f4/BitLowOrb.png/revision/latest?cb=20250215050618'),
  ('33333333-0000-4000-8000-000000000040','Trans Kick','bit','CX','https://static.wikia.nocookie.net/beyblade/images/5/5d/BitTransKick.png/revision/latest?cb=20250812023538'),
  ('33333333-0000-4000-8000-000000000041','Wall Wedge','bit','CX','https://static.wikia.nocookie.net/beyblade/images/9/9a/BitWallWedge.png/revision/latest?cb=20260115043200'),
  ('33333333-0000-4000-8000-000000000042','Ignition','bit','CX','https://static.wikia.nocookie.net/beyblade/images/3/37/BitIgnition.png/revision/latest?cb=20260214040456'),
  ('33333333-0000-4000-8000-000000000043','Yielding','bit','CX','https://static.wikia.nocookie.net/beyblade/images/f/f1/BitYielding.png/revision/latest?cb=20260214043217'),
  ('33333333-0000-4000-8000-000000000044','Gear Rush','bit','CX','https://static.wikia.nocookie.net/beyblade/images/5/58/BitGearRush.png/revision/latest?cb=20250415032926'),
  ('33333333-0000-4000-8000-000000000045','Gear Unite','bit','CX','https://static.wikia.nocookie.net/beyblade/images/3/33/BitGearUnite.png/revision/latest?cb=20260415025452'),
  ('33333333-0000-4000-8000-000000000046','Narrow','bit','CX','https://static.wikia.nocookie.net/beyblade/images/d/d6/BitNarrow.png/revision/latest?cb=20260517043012'),
  ('33333333-0000-4000-8000-000000000047','Kick','bit','CX','https://static.wikia.nocookie.net/beyblade/images/4/47/BitKick.png/revision/latest?cb=20250314041641'),
  ('33333333-0000-4000-8000-000000000048','Wall Ball','bit','CX','https://static.wikia.nocookie.net/beyblade/images/3/38/BitWallBall.png/revision/latest?cb=20250613042119')
on conflict (id) do update set image_url=excluded.image_url;

-- ===========================================================================
-- RATCHET-INTEGRATED BITS (prefix bbbbbbbb) — vervangt losse Ratchet + Bit
-- ===========================================================================
insert into parts (id, canonical_name, category, line, image_url) values
  ('bbbbbbbb-0000-4000-8000-000000000001','Turbo','ratchet_integrated_bit','CX','https://static.wikia.nocookie.net/beyblade/images/c/cf/RatchetBitTurbo.png/revision/latest/scale-to-width-down/320?cb=20250613042038'),
  ('bbbbbbbb-0000-4000-8000-000000000002','Operate','ratchet_integrated_bit','CX','https://static.wikia.nocookie.net/beyblade/images/8/89/RatchetBitOperate_%28Attack_Mode%29.png/revision/latest/scale-to-width-down/320?cb=20260127222235')
on conflict (id) do update set image_url=excluded.image_url;


-- ============ 0017_cx_parts_gaps.sql ============
-- 0017_cx_parts_gaps.sql
-- Ontbrekende CX-onderdelen die na de steekproef-seed nog misten.
-- 1 main blade (Fang), 4 assist blades (Knuckle, Vertical, Erase, Odd),
-- 2 ratchets (4-55, 6-80). 6-80 zonder afbeelding (backfill later).

insert into parts (id, canonical_name, category, line, image_url) values
  ('77777777-0000-4000-8000-000000000013','Fang','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/a/ae/MainBladeFang.png/revision/latest/scale-to-width-down/320?cb=20250515031203')
on conflict (id) do update set image_url=excluded.image_url;

insert into parts (id, canonical_name, category, line, image_url) values
  ('88888888-0000-4000-8000-000000000014','Knuckle','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/1/11/AssistBladeKnuckle.png/revision/latest/scale-to-width-down/320?cb=20260214040432'),
  ('88888888-0000-4000-8000-000000000015','Vertical','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/6/65/AssistBladeVertical.png/revision/latest/scale-to-width-down/320?cb=20260214040558'),
  ('88888888-0000-4000-8000-000000000016','Erase','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/0/0c/AssistBladeErase.png/revision/latest/scale-to-width-down/320?cb=20260214043159'),
  ('88888888-0000-4000-8000-000000000017','Odd','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/8/85/AssistBladeOdd.png/revision/latest/scale-to-width-down/320?cb=20260415025441')
on conflict (id) do update set image_url=excluded.image_url;

insert into parts (id, canonical_name, category, line, ratchet_height, image_url) values
  ('22222222-0000-4000-8000-000000000455','4-55','ratchet','CX','55','https://static.wikia.nocookie.net/beyblade/images/7/7a/Ratchet4-55.png/revision/latest/scale-to-width-down/320?cb=20250605000210'),
  ('22222222-0000-4000-8000-000000000680','6-80','ratchet','CX','80',null)
on conflict (id) do update set ratchet_height=excluded.ratchet_height, image_url=excluded.image_url;


-- ============ 0018_seed_products_ux_cx_bx.sql ============
-- 0018_seed_products_ux_cx_bx.sql
-- Losse Starters/Boosters (1 bey per product) voor resterende BX, UX en CX.
-- EU (Hasbro) naam waar bevestigd; anders TT-naam. eu_available=true (in EU
-- verkrijgbaar via Hasbro of TT-import; exacte EU-datums nog te verifieren).
-- Inhoud gekoppeld via (canonical_name, category) -> uniek in de catalogus.
-- Random Boosters en Deck Sets (meerdere beys) volgen apart.

-- ===========================================================================
-- PRODUCTS
-- ===========================================================================
insert into products (id, canonical_name, hasbro_name, product_code, brand, kind, line, eu_available) values
  -- BX
  ('44444444-0000-4000-8000-000000000013','KnightLance 4-80HN','Lance Knight 4-80HN','BX-13','takara_tomy','booster','BX',true),
  ('44444444-0000-4000-8000-000000000026','UnicornSting 5-60GP','Sting Unicorn 5-60GP','BX-26','takara_tomy','booster','BX',true),
  ('44444444-0000-4000-8000-000000000033','WeissTiger 3-60U','Pearl Tiger 3-60U','BX-33','takara_tomy','booster','BX',true),
  ('44444444-0000-4000-8000-000000000034','CobaltDragoon 2-60C','Cobalt Dragoon 2-60C','BX-34','takara_tomy','starter','BX',true),
  ('44444444-0000-4000-8000-000000000038','CrimsonGaruda 4-70TP','Scarlet Garuda 4-70TP','BX-38','takara_tomy','booster','BX',true),
  ('44444444-0000-4000-8000-000000000044','TriceraPress M-85BS','Brace Triceratops M-85BS','BX-44','takara_tomy','booster','BX',true),
  ('44444444-0000-4000-8000-000000000045','SamuraiCalibur 6-70M','Calibur Samurai 6-70M','BX-45','takara_tomy','booster','BX',true),
  ('44444444-0000-4000-8000-000000000049','DranStrike 4-50FF','Strike Dran 4-50FF','BX-49','takara_tomy','starter','BX',true),
  -- UX
  ('44444444-0000-4000-8000-000000000101','DranBuster 1-60A',null,'UX-01','takara_tomy','starter','UX',true),
  ('44444444-0000-4000-8000-000000000102','HellsHammer 3-70H','Hammer Incendio 3-70H','UX-02','takara_tomy','starter','UX',true),
  ('44444444-0000-4000-8000-000000000103','WizardRod 5-70DB','Wand Wizard 5-70DB','UX-03','takara_tomy','booster','UX',true),
  ('44444444-0000-4000-8000-000000000106','LeonCrest 7-60GN','Crest Leon 7-60GN','UX-06','takara_tomy','booster','UX',true),
  ('44444444-0000-4000-8000-000000000108','SilverWolf 3-80FB','Sterling Wolf 3-80FB','UX-08','takara_tomy','starter','UX',true),
  ('44444444-0000-4000-8000-000000000109','SamuraiSaber 2-70L','Saber Samurai 2-70L','UX-09','takara_tomy','starter','UX',true),
  ('44444444-0000-4000-8000-000000000111','ImpactDrake 9-60LR','Impact Drake 9-60LR','UX-11','takara_tomy','starter','UX',true),
  ('44444444-0000-4000-8000-000000000113','GolemRock 1-60UN','Rock Golem 1-60UN','UX-13','takara_tomy','booster','UX',true),
  ('44444444-0000-4000-8000-000000000114','ScorpioSpear 0-70Z','Spear Scorpio 0-70Z','UX-14','takara_tomy','starter','UX',true),
  ('44444444-0000-4000-8000-000000000117','MeteorDragoon 3-70J','Meteoroid Dragoon 3-70J','UX-17','takara_tomy','starter','UX',true),
  ('44444444-0000-4000-8000-000000000119','BulletGriffon H','Rocket Griffon H','UX-19','takara_tomy','starter','UX',true),
  -- CX (EU-naam nog niet bevestigd -> TT-naam)
  ('44444444-0000-4000-8000-000000000201','DranBrave S6-60V',null,'CX-01','takara_tomy','starter','CX',true),
  ('44444444-0000-4000-8000-000000000202','WizardArc R4-55LO',null,'CX-02','takara_tomy','starter','CX',true),
  ('44444444-0000-4000-8000-000000000203','PerseusDark B6-80W',null,'CX-03','takara_tomy','booster','CX',true),
  ('44444444-0000-4000-8000-000000000207','PegasusBlast ATr',null,'CX-07','takara_tomy','starter','CX',true),
  ('44444444-0000-4000-8000-000000000209','SolEclipse D5-70TK',null,'CX-09','takara_tomy','starter','CX',true),
  ('44444444-0000-4000-8000-000000000210','WolfHunt F0-60DB',null,'CX-10','takara_tomy','booster','CX',true),
  ('44444444-0000-4000-8000-000000000212','PhoenixFlare Z9-80WW',null,'CX-12','takara_tomy','booster','CX',true),
  ('44444444-0000-4000-8000-000000000213','BahamutBlitz BK1-50I',null,'CX-13','takara_tomy','starter','CX',true),
  ('44444444-0000-4000-8000-000000000214','KnightFortress GV8-70UN',null,'CX-14','takara_tomy','starter','CX',true),
  ('44444444-0000-4000-8000-000000000215','RagnaRage FE4-55Y',null,'CX-15','takara_tomy','booster','CX',true)
on conflict (id) do update set
  canonical_name=excluded.canonical_name, hasbro_name=excluded.hasbro_name,
  product_code=excluded.product_code, kind=excluded.kind, line=excluded.line,
  eu_available=excluded.eu_available;

-- ===========================================================================
-- PRODUCT_PARTS  (gekoppeld via canonical_name + category)
-- ===========================================================================
insert into product_parts (product_id, part_id, quantity)
select p.pid::uuid, parts.id, 1 from parts join (values
  -- BX
  ('44444444-0000-4000-8000-000000000013','KnightLance','blade'),
  ('44444444-0000-4000-8000-000000000013','4-80','ratchet'),
  ('44444444-0000-4000-8000-000000000013','High Needle','bit'),
  ('44444444-0000-4000-8000-000000000026','UnicornSting','blade'),
  ('44444444-0000-4000-8000-000000000026','5-60','ratchet'),
  ('44444444-0000-4000-8000-000000000026','Gear Point','bit'),
  ('44444444-0000-4000-8000-000000000033','WeissTiger','blade'),
  ('44444444-0000-4000-8000-000000000033','3-60','ratchet'),
  ('44444444-0000-4000-8000-000000000033','Unite','bit'),
  ('44444444-0000-4000-8000-000000000034','CobaltDragoon','blade'),
  ('44444444-0000-4000-8000-000000000034','2-60','ratchet'),
  ('44444444-0000-4000-8000-000000000034','Cyclone','bit'),
  ('44444444-0000-4000-8000-000000000038','CrimsonGaruda','blade'),
  ('44444444-0000-4000-8000-000000000038','4-70','ratchet'),
  ('44444444-0000-4000-8000-000000000038','Trans Point','bit'),
  ('44444444-0000-4000-8000-000000000044','TriceraPress','blade'),
  ('44444444-0000-4000-8000-000000000044','M-85','ratchet'),
  ('44444444-0000-4000-8000-000000000044','Bound Spike','bit'),
  ('44444444-0000-4000-8000-000000000045','SamuraiCalibur','blade'),
  ('44444444-0000-4000-8000-000000000045','6-70','ratchet'),
  ('44444444-0000-4000-8000-000000000045','Merge','bit'),
  ('44444444-0000-4000-8000-000000000049','DranStrike','blade'),
  ('44444444-0000-4000-8000-000000000049','4-50','ratchet'),
  ('44444444-0000-4000-8000-000000000049','Free Flat','bit'),
  -- UX
  ('44444444-0000-4000-8000-000000000101','DranBuster','blade'),
  ('44444444-0000-4000-8000-000000000101','1-60','ratchet'),
  ('44444444-0000-4000-8000-000000000101','Accel','bit'),
  ('44444444-0000-4000-8000-000000000102','HellsHammer','blade'),
  ('44444444-0000-4000-8000-000000000102','3-70','ratchet'),
  ('44444444-0000-4000-8000-000000000102','Hexa','bit'),
  ('44444444-0000-4000-8000-000000000103','WizardRod','blade'),
  ('44444444-0000-4000-8000-000000000103','5-70','ratchet'),
  ('44444444-0000-4000-8000-000000000103','Disk Ball','bit'),
  ('44444444-0000-4000-8000-000000000106','LeonCrest','blade'),
  ('44444444-0000-4000-8000-000000000106','7-60','ratchet'),
  ('44444444-0000-4000-8000-000000000106','Gear Needle','bit'),
  ('44444444-0000-4000-8000-000000000108','SilverWolf','blade'),
  ('44444444-0000-4000-8000-000000000108','3-80','ratchet'),
  ('44444444-0000-4000-8000-000000000108','Free Ball','bit'),
  ('44444444-0000-4000-8000-000000000109','SamuraiSaber','blade'),
  ('44444444-0000-4000-8000-000000000109','2-70','ratchet'),
  ('44444444-0000-4000-8000-000000000109','Level','bit'),
  ('44444444-0000-4000-8000-000000000111','ImpactDrake','blade'),
  ('44444444-0000-4000-8000-000000000111','9-60','ratchet'),
  ('44444444-0000-4000-8000-000000000111','Low Rush','bit'),
  ('44444444-0000-4000-8000-000000000113','GolemRock','blade'),
  ('44444444-0000-4000-8000-000000000113','1-60','ratchet'),
  ('44444444-0000-4000-8000-000000000113','Under Needle','bit'),
  ('44444444-0000-4000-8000-000000000114','ScorpioSpear','blade'),
  ('44444444-0000-4000-8000-000000000114','0-70','ratchet'),
  ('44444444-0000-4000-8000-000000000114','Zap','bit'),
  ('44444444-0000-4000-8000-000000000117','MeteorDragoon','blade'),
  ('44444444-0000-4000-8000-000000000117','3-70','ratchet'),
  ('44444444-0000-4000-8000-000000000117','Jolt','bit'),
  ('44444444-0000-4000-8000-000000000119','BulletGriffon','ratchet_integrated_blade'),
  ('44444444-0000-4000-8000-000000000119','Hexa','bit'),
  -- CX Custom
  ('44444444-0000-4000-8000-000000000201','Dran','lock_chip'),
  ('44444444-0000-4000-8000-000000000201','Brave','main_blade'),
  ('44444444-0000-4000-8000-000000000201','Slash','assist_blade'),
  ('44444444-0000-4000-8000-000000000201','6-60','ratchet'),
  ('44444444-0000-4000-8000-000000000201','Vortex','bit'),
  ('44444444-0000-4000-8000-000000000202','Wizard','lock_chip'),
  ('44444444-0000-4000-8000-000000000202','Arc','main_blade'),
  ('44444444-0000-4000-8000-000000000202','Round','assist_blade'),
  ('44444444-0000-4000-8000-000000000202','4-55','ratchet'),
  ('44444444-0000-4000-8000-000000000202','Low Orb','bit'),
  ('44444444-0000-4000-8000-000000000203','Perseus','lock_chip'),
  ('44444444-0000-4000-8000-000000000203','Dark','main_blade'),
  ('44444444-0000-4000-8000-000000000203','Bumper','assist_blade'),
  ('44444444-0000-4000-8000-000000000203','6-80','ratchet'),
  ('44444444-0000-4000-8000-000000000203','Wedge','bit'),
  ('44444444-0000-4000-8000-000000000207','Pegasus','lock_chip'),
  ('44444444-0000-4000-8000-000000000207','Blast','main_blade'),
  ('44444444-0000-4000-8000-000000000207','Assault','assist_blade'),
  ('44444444-0000-4000-8000-000000000207','Turbo','ratchet_integrated_bit'),
  ('44444444-0000-4000-8000-000000000209','Sol','lock_chip'),
  ('44444444-0000-4000-8000-000000000209','Eclipse','main_blade'),
  ('44444444-0000-4000-8000-000000000209','Dual','assist_blade'),
  ('44444444-0000-4000-8000-000000000209','5-70','ratchet'),
  ('44444444-0000-4000-8000-000000000209','Trans Kick','bit'),
  ('44444444-0000-4000-8000-000000000210','Wolf','lock_chip'),
  ('44444444-0000-4000-8000-000000000210','Hunt','main_blade'),
  ('44444444-0000-4000-8000-000000000210','Free','assist_blade'),
  ('44444444-0000-4000-8000-000000000210','0-60','ratchet'),
  ('44444444-0000-4000-8000-000000000210','Disk Ball','bit'),
  ('44444444-0000-4000-8000-000000000212','Phoenix','lock_chip'),
  ('44444444-0000-4000-8000-000000000212','Flare','main_blade'),
  ('44444444-0000-4000-8000-000000000212','Zillion','assist_blade'),
  ('44444444-0000-4000-8000-000000000212','9-80','ratchet'),
  ('44444444-0000-4000-8000-000000000212','Wall Wedge','bit'),
  -- CX Expand
  ('44444444-0000-4000-8000-000000000213','Bahamut','lock_chip'),
  ('44444444-0000-4000-8000-000000000213','Blitz','metal_blade'),
  ('44444444-0000-4000-8000-000000000213','Break','over_blade'),
  ('44444444-0000-4000-8000-000000000213','Knuckle','assist_blade'),
  ('44444444-0000-4000-8000-000000000213','1-50','ratchet'),
  ('44444444-0000-4000-8000-000000000213','Ignition','bit'),
  ('44444444-0000-4000-8000-000000000214','Knight','lock_chip'),
  ('44444444-0000-4000-8000-000000000214','Fortress','metal_blade'),
  ('44444444-0000-4000-8000-000000000214','Guard','over_blade'),
  ('44444444-0000-4000-8000-000000000214','Vertical','assist_blade'),
  ('44444444-0000-4000-8000-000000000214','8-70','ratchet'),
  ('44444444-0000-4000-8000-000000000214','Under Needle','bit'),
  ('44444444-0000-4000-8000-000000000215','Ragna','lock_chip'),
  ('44444444-0000-4000-8000-000000000215','Rage','metal_blade'),
  ('44444444-0000-4000-8000-000000000215','Flow','over_blade'),
  ('44444444-0000-4000-8000-000000000215','Erase','assist_blade'),
  ('44444444-0000-4000-8000-000000000215','4-55','ratchet'),
  ('44444444-0000-4000-8000-000000000215','Yielding','bit')
) as p(pid, cname, cat)
  on parts.canonical_name = p.cname and parts.category = p.cat
on conflict on constraint product_parts_uniq do nothing;


-- ============ 0019_meta_date.sql ============
-- 0019_meta_date.sql
-- Recency-datum voor competitieve meta-combo's. Deze combo's staan in builds
-- met user_id = null en kind = 'competitive' (eigenaarloze templates).
-- source houdt de bron vast (bv. WBO-event), notes de type-rol.

alter table builds add column if not exists meta_date date;

create index if not exists builds_meta_idx
  on builds (kind, meta_date desc)
  where user_id is null;


-- ============ 0020_seed_meta_combos.sql ============
-- 0020_seed_meta_combos.sql
-- Competitieve meta-combo's (medio 2026) als eigenaarloze builds (user_id null,
-- kind 'competitive'). Bron: WBO Winning Combinations + BeyBase (mei-juni 2026).
-- Matching vergelijkt build_parts met owned_parts op canonieke part_id.
-- Periodiek handmatig bij te werken (data, geen hardcode).

-- Ontbrekende ratchet die in de top-combo voorkomt.
insert into parts (id, canonical_name, category, line, ratchet_height, image_url) values
  ('22222222-0000-4000-8000-000000000170','1-70','ratchet','UX','70',null)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Meta-combo's (builds)
-- ---------------------------------------------------------------------------
insert into builds (id, user_id, name, template_id, kind, source, notes, meta_date) values
  ('cccccccc-0000-4000-8000-000000000001',null,'Shark Scale 1-70 Low Rush','ux_unique','competitive','WBO winning combos (mei-juni 2026)','attack','2026-06-06'),
  ('cccccccc-0000-4000-8000-000000000002',null,'Shark Scale 1-60 Kick','ux_unique','competitive','WBO winning combos (mei 2026)','attack','2026-05-22'),
  ('cccccccc-0000-4000-8000-000000000003',null,'Shark Scale 9-60 Free Ball','ux_unique','competitive','WBO winning combos (mei 2026)','defense','2026-05-22'),
  ('cccccccc-0000-4000-8000-000000000004',null,'Wizard Rod 1-60 Hexa','ux_unique','competitive','WBO / BBX Weekly (mei 2026)','stamina','2026-05-22'),
  ('cccccccc-0000-4000-8000-000000000005',null,'Wizard Rod 1-60 Free Ball','ux_unique','competitive','WBO winning combos (juni 2026)','stamina','2026-06-06'),
  ('cccccccc-0000-4000-8000-000000000006',null,'Cobalt Dragoon 5-60 Elevate','bx_basic','competitive','WBO winning combos (juni 2026)','balance','2026-06-06'),
  ('cccccccc-0000-4000-8000-000000000007',null,'Dran Strike 3-60 Low Rush','bx_basic','competitive','WBO winning combos (juni 2026)','attack','2026-06-06'),
  ('cccccccc-0000-4000-8000-000000000008',null,'Bullet Griffon Hexa','ux_expand','competitive','WBO winning combos (mei 2026)','stamina','2026-05-22'),
  ('cccccccc-0000-4000-8000-000000000009',null,'Phoenix Wing 3-60 Rush','bx_basic','competitive','WBO winning combos (mei 2026)','attack','2026-05-22'),
  ('cccccccc-0000-4000-8000-000000000010',null,'Silver Wolf 9-60 Free Ball','ux_unique','competitive','WBO winning combos (juni 2026)','stamina','2026-06-06'),
  ('cccccccc-0000-4000-8000-000000000011',null,'Emperor Blast Heavy 7-60 Rush','cx_custom','competitive','BeyBase CX-gids (2026)','balance','2026-06-01'),
  ('cccccccc-0000-4000-8000-000000000012',null,'Unicorn Delta Flow Heavy 3-60 Kick','cx_expand','competitive','WBO ranked events (mei 2026)','balance','2026-05-22'),
  ('cccccccc-0000-4000-8000-000000000013',null,'Clock Mirage 4-55 Low Orb','ux_unique','competitive','WBO winning combos (mei 2026)','stamina','2026-05-22')
on conflict (id) do update set
  name=excluded.name, template_id=excluded.template_id, source=excluded.source,
  notes=excluded.notes, meta_date=excluded.meta_date;

-- ---------------------------------------------------------------------------
-- Onderdelen per combo (gekoppeld via canonical_name + category)
-- ---------------------------------------------------------------------------
delete from build_parts where build_id in (
  select id from builds where user_id is null and kind='competitive');

insert into build_parts (build_id, part_id, slot_category)
select b.bid::uuid, parts.id, parts.category
from parts join (values
  ('cccccccc-0000-4000-8000-000000000001','SharkScale','blade'),
  ('cccccccc-0000-4000-8000-000000000001','1-70','ratchet'),
  ('cccccccc-0000-4000-8000-000000000001','Low Rush','bit'),
  ('cccccccc-0000-4000-8000-000000000002','SharkScale','blade'),
  ('cccccccc-0000-4000-8000-000000000002','1-60','ratchet'),
  ('cccccccc-0000-4000-8000-000000000002','Kick','bit'),
  ('cccccccc-0000-4000-8000-000000000003','SharkScale','blade'),
  ('cccccccc-0000-4000-8000-000000000003','9-60','ratchet'),
  ('cccccccc-0000-4000-8000-000000000003','Free Ball','bit'),
  ('cccccccc-0000-4000-8000-000000000004','WizardRod','blade'),
  ('cccccccc-0000-4000-8000-000000000004','1-60','ratchet'),
  ('cccccccc-0000-4000-8000-000000000004','Hexa','bit'),
  ('cccccccc-0000-4000-8000-000000000005','WizardRod','blade'),
  ('cccccccc-0000-4000-8000-000000000005','1-60','ratchet'),
  ('cccccccc-0000-4000-8000-000000000005','Free Ball','bit'),
  ('cccccccc-0000-4000-8000-000000000006','CobaltDragoon','blade'),
  ('cccccccc-0000-4000-8000-000000000006','5-60','ratchet'),
  ('cccccccc-0000-4000-8000-000000000006','Elevate','bit'),
  ('cccccccc-0000-4000-8000-000000000007','DranStrike','blade'),
  ('cccccccc-0000-4000-8000-000000000007','3-60','ratchet'),
  ('cccccccc-0000-4000-8000-000000000007','Low Rush','bit'),
  ('cccccccc-0000-4000-8000-000000000008','BulletGriffon','ratchet_integrated_blade'),
  ('cccccccc-0000-4000-8000-000000000008','Hexa','bit'),
  ('cccccccc-0000-4000-8000-000000000009','PhoenixWing','blade'),
  ('cccccccc-0000-4000-8000-000000000009','3-60','ratchet'),
  ('cccccccc-0000-4000-8000-000000000009','Rush','bit'),
  ('cccccccc-0000-4000-8000-000000000010','SilverWolf','blade'),
  ('cccccccc-0000-4000-8000-000000000010','9-60','ratchet'),
  ('cccccccc-0000-4000-8000-000000000010','Free Ball','bit'),
  ('cccccccc-0000-4000-8000-000000000011','Emperor','lock_chip'),
  ('cccccccc-0000-4000-8000-000000000011','Blast','main_blade'),
  ('cccccccc-0000-4000-8000-000000000011','Heavy','assist_blade'),
  ('cccccccc-0000-4000-8000-000000000011','7-60','ratchet'),
  ('cccccccc-0000-4000-8000-000000000011','Rush','bit'),
  ('cccccccc-0000-4000-8000-000000000012','Unicorn','lock_chip'),
  ('cccccccc-0000-4000-8000-000000000012','Delta','metal_blade'),
  ('cccccccc-0000-4000-8000-000000000012','Flow','over_blade'),
  ('cccccccc-0000-4000-8000-000000000012','Heavy','assist_blade'),
  ('cccccccc-0000-4000-8000-000000000012','3-60','ratchet'),
  ('cccccccc-0000-4000-8000-000000000012','Kick','bit'),
  ('cccccccc-0000-4000-8000-000000000013','ClockMirage','blade'),
  ('cccccccc-0000-4000-8000-000000000013','4-55','ratchet'),
  ('cccccccc-0000-4000-8000-000000000013','Low Orb','bit')
) as b(bid, cname, cat) on parts.canonical_name = b.cname and parts.category = b.cat
on conflict (build_id, part_id) do nothing;


-- ============ 0021_seed_missing_blades.sql ============
-- 0021_seed_missing_blades.sql
-- Ontbrekende blades over alle lijnen (kwamen voor in Deck Sets/Random Boosters).
-- Bron: Beyblade Wiki (Fandom), CC-BY-SA. Hasbro-namen als alias.
-- Enkele hele recente releases (juni 2026) hebben nog geen gedocumenteerd type -> leeg.
-- BearScratch en Antlers: geen losse render op de wiki -> geen afbeelding.

-- ===========================================================================
-- Gewone blades (BX)
-- ===========================================================================
insert into parts (id, canonical_name, category, line, type, spin_direction, image_url, wiki_url) values
  ('11111111-0000-4000-8000-000000000047','PhoenixFeather','blade','BX','attack','right','https://static.wikia.nocookie.net/beyblade/images/9/96/BladePhoenixFeather.png/revision/latest/scale-to-width-down/320?cb=20231207074705','https://beyblade.fandom.com/wiki/List_of_Beyblade_X_products_(Takara_Tomy)'),
  ('11111111-0000-4000-8000-000000000048','CrocCrunch','blade','BX','attack','right','https://static.wikia.nocookie.net/beyblade/images/8/86/BladeCrocCrunch.png/revision/latest/scale-to-width-down/320?cb=20260315124201',null),
  ('11111111-0000-4000-8000-000000000049','SharkGill','blade','BX','stamina','right','https://static.wikia.nocookie.net/beyblade/images/7/7c/BladeSharkGill.png/revision/latest/scale-to-width-down/320?cb=20251015212355',null),
  ('11111111-0000-4000-8000-000000000050','BatGust','blade','BX','balance','right','https://static.wikia.nocookie.net/beyblade/images/c/cc/BladeBatGust.png/revision/latest/scale-to-width-down/320?cb=20260619080541',null),
  ('11111111-0000-4000-8000-000000000051','ShinobiKnife','blade','BX','defense','right','https://static.wikia.nocookie.net/beyblade/images/2/25/BladeKnifeShinobi.png/revision/latest/scale-to-width-down/320?cb=20250815182407',null),
  ('11111111-0000-4000-8000-000000000052','TriceraSpiky','blade','BX','defense','right','https://static.wikia.nocookie.net/beyblade/images/7/78/BladeTriceraSpiky.png/revision/latest/scale-to-width-down/320?cb=20260207193346',null),
  ('11111111-0000-4000-8000-000000000053','TyrannoRoar','blade','BX','attack','right','https://static.wikia.nocookie.net/beyblade/images/6/6d/BladeTyrannoRoar.png/revision/latest/scale-to-width-down/320?cb=20250727003819',null),
  ('11111111-0000-4000-8000-000000000054','BearScratch','blade','BX','defense','right',null,null),
  ('11111111-0000-4000-8000-000000000055','SamuraiSteel','blade','BX','balance','right','https://static.wikia.nocookie.net/beyblade/images/2/2c/BladeSteelSamurai.png/revision/latest/scale-to-width-down/320?cb=20250503034245',null),
  ('11111111-0000-4000-8000-000000000056','PteraSwing','blade','BX','stamina','right','https://static.wikia.nocookie.net/beyblade/images/3/3a/BladePteraSwing.png/revision/latest/scale-to-width-down/320?cb=20241227163416',null),
  ('11111111-0000-4000-8000-000000000057','CyclopsEye','blade','BX',null,'right','https://static.wikia.nocookie.net/beyblade/images/8/86/BladeCyclopsEye.png/revision/latest/scale-to-width-down/320?cb=20260630203059',null),
  ('11111111-0000-4000-8000-000000000058','HeavensRing','blade','BX','defense','right','https://static.wikia.nocookie.net/beyblade/images/4/41/BladeHeavensRing.png/revision/latest/scale-to-width-down/320?cb=20260615070349',null),
  ('11111111-0000-4000-8000-000000000059','SiegSuperion','blade','BX',null,'right','https://static.wikia.nocookie.net/beyblade/images/f/ff/BladeSiegSuperion.png/revision/latest?cb=20260630202422',null)
on conflict (id) do update set type=excluded.type, image_url=excluded.image_url;

-- ===========================================================================
-- Gewone blades (UX)
-- ===========================================================================
insert into parts (id, canonical_name, category, line, type, spin_direction, image_url) values
  ('11111111-0000-4000-8000-000000000060','AeroPegasus','blade','UX','attack','right','https://static.wikia.nocookie.net/beyblade/images/5/58/BladeAeroPegasus.png/revision/latest/scale-to-width-down/320?cb=20250528202546'),
  ('11111111-0000-4000-8000-000000000061','OrochiCluster','blade','UX','attack','right','https://static.wikia.nocookie.net/beyblade/images/d/d0/BladeOrochiCluster.png/revision/latest/scale-to-width-down/320?cb=20260121134642'),
  ('11111111-0000-4000-8000-000000000062','WyvernHover','blade','UX','defense','right','https://static.wikia.nocookie.net/beyblade/images/b/b2/BladeWyvernHover.png/revision/latest/scale-to-width-down/320?cb=20260327054801')
on conflict (id) do update set type=excluded.type, image_url=excluded.image_url;

-- ===========================================================================
-- Ratchet-Integrated Blades (UX Expand)
-- ===========================================================================
insert into parts (id, canonical_name, category, line, type, spin_direction, image_url) values
  ('11111111-0000-4000-8000-000000000063','GloryValkyrie','ratchet_integrated_blade','UX','attack','right','https://static.wikia.nocookie.net/beyblade/images/b/b6/RatchetBladeGloryValkyrie.png/revision/latest/scale-to-width-down/320?cb=20260616045056'),
  ('11111111-0000-4000-8000-000000000064','HellsNether','ratchet_integrated_blade','UX',null,'right','https://static.wikia.nocookie.net/beyblade/images/0/05/RatchetBladeHellsNether.png/revision/latest/scale-to-width-down/320?cb=20260630202438')
on conflict (id) do update set type=excluded.type, image_url=excluded.image_url;

-- ===========================================================================
-- CX Main Blades
-- ===========================================================================
insert into parts (id, canonical_name, category, line, image_url) values
  ('77777777-0000-4000-8000-000000000014','Antlers','main_blade','CX',null),
  ('77777777-0000-4000-8000-000000000015','Fort','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/3/3b/MainBladeFort.png/revision/latest/scale-to-width-down/320?cb=20250814033238'),
  ('77777777-0000-4000-8000-000000000016','Wriggle','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/1/12/MainBladeWriggle.png/revision/latest/scale-to-width-down/320?cb=20250814033242')
on conflict (id) do update set image_url=excluded.image_url;

-- ===========================================================================
-- Hasbro-aliassen (waar bekend)
-- ===========================================================================
insert into part_aliases (part_id, brand, name, region) values
  ('11111111-0000-4000-8000-000000000047','hasbro','Feather Phoenix','US'),
  ('11111111-0000-4000-8000-000000000048','hasbro','Bite Croc','US'),
  ('11111111-0000-4000-8000-000000000049','hasbro','Gill Shark','US'),
  ('11111111-0000-4000-8000-000000000050','hasbro','Gust Bat','US'),
  ('11111111-0000-4000-8000-000000000051','hasbro','Knife Shinobi','US'),
  ('11111111-0000-4000-8000-000000000052','hasbro','Ridge Triceratops','US'),
  ('11111111-0000-4000-8000-000000000053','hasbro','Roar Tyranno','US'),
  ('11111111-0000-4000-8000-000000000054','hasbro','Savage Bear','US'),
  ('11111111-0000-4000-8000-000000000055','hasbro','Steel Samurai','US'),
  ('11111111-0000-4000-8000-000000000056','hasbro','Talon Ptera','US'),
  ('11111111-0000-4000-8000-000000000057','hasbro','Glare Cyclops','US'),
  ('11111111-0000-4000-8000-000000000058','hasbro','Ring Aether','US'),
  ('11111111-0000-4000-8000-000000000059','hasbro','Suppress Superion','US'),
  ('11111111-0000-4000-8000-000000000060','hasbro','Aero Pegasus','US'),
  ('11111111-0000-4000-8000-000000000062','hasbro','Hover Wyvern','US'),
  ('11111111-0000-4000-8000-000000000063','hasbro','Glory Valkerion','US'),
  ('11111111-0000-4000-8000-000000000064','hasbro','Nether Incendio','US')
on conflict (part_id, brand, name) do nothing;


-- ============ 0022_seed_deck_sets.sql ============
-- 0022_seed_deck_sets.sql
-- Deck Sets: producten met 3 vaste beys. "Voeg toe" zet alle onderdelen in de
-- collectie (past in het bestaande model). BX-21 was half-gemodelleerd als
-- enkele bey; hier bijgewerkt naar de volledige set.
-- Random Boosters (een-van-meerdere) volgen later, met een ander model.

-- ---------------------------------------------------------------------------
-- Producten (deck sets). hasbro_name leeg: dit zijn TT-deck sets.
-- ---------------------------------------------------------------------------
insert into products (id, canonical_name, hasbro_name, product_code, brand, kind, line, eu_available) values
  ('44444444-0000-4000-8000-000000000008','3on3 Deck Set',null,'BX-08','takara_tomy','deck_set','BX',true),
  ('44444444-0000-4000-8000-000000000020','DranDagger Deck Set',null,'BX-20','takara_tomy','deck_set','BX',true),
  ('44444444-0000-4000-8000-000000000021','HellsChain Deck Set',null,'BX-21','takara_tomy','deck_set','BX',true),
  ('44444444-0000-4000-8000-000000000107','PhoenixRudder Deck Set',null,'UX-07','takara_tomy','deck_set','UX',true),
  ('44444444-0000-4000-8000-000000000115','SharkScale Deck Set',null,'UX-15','takara_tomy','deck_set','UX',true),
  ('44444444-0000-4000-8000-000000000211','EmperorMight Deck Set',null,'CX-11','takara_tomy','deck_set','CX',true)
on conflict (id) do update set
  canonical_name=excluded.canonical_name, hasbro_name=excluded.hasbro_name,
  kind=excluded.kind, line=excluded.line, eu_available=excluded.eu_available;

delete from product_parts where product_id in (
  '44444444-0000-4000-8000-000000000008','44444444-0000-4000-8000-000000000020',
  '44444444-0000-4000-8000-000000000021','44444444-0000-4000-8000-000000000107',
  '44444444-0000-4000-8000-000000000115','44444444-0000-4000-8000-000000000211');

insert into product_parts (product_id, part_id, quantity)
select p.pid::uuid, parts.id, 1
from parts join (values
  -- BX-08: HellsScythe 3-80B / KnightShield 4-80T / WizardArrow 4-60N
  ('44444444-0000-4000-8000-000000000008','HellsScythe','blade'),
  ('44444444-0000-4000-8000-000000000008','3-80','ratchet'),
  ('44444444-0000-4000-8000-000000000008','Ball','bit'),
  ('44444444-0000-4000-8000-000000000008','KnightShield','blade'),
  ('44444444-0000-4000-8000-000000000008','4-80','ratchet'),
  ('44444444-0000-4000-8000-000000000008','Taper','bit'),
  ('44444444-0000-4000-8000-000000000008','WizardArrow','blade'),
  ('44444444-0000-4000-8000-000000000008','4-60','ratchet'),
  ('44444444-0000-4000-8000-000000000008','Needle','bit'),
  -- BX-20: DranDagger 4-60R / KnightShield 5-80T / SharkEdge 3-80F
  ('44444444-0000-4000-8000-000000000020','DranDagger','blade'),
  ('44444444-0000-4000-8000-000000000020','4-60','ratchet'),
  ('44444444-0000-4000-8000-000000000020','Rush','bit'),
  ('44444444-0000-4000-8000-000000000020','KnightShield','blade'),
  ('44444444-0000-4000-8000-000000000020','5-80','ratchet'),
  ('44444444-0000-4000-8000-000000000020','Taper','bit'),
  ('44444444-0000-4000-8000-000000000020','SharkEdge','blade'),
  ('44444444-0000-4000-8000-000000000020','3-80','ratchet'),
  ('44444444-0000-4000-8000-000000000020','Flat','bit'),
  -- BX-21: HellsChain 5-60HT / KnightLance 3-60LF / WizardArrow 4-80N
  ('44444444-0000-4000-8000-000000000021','HellsChain','blade'),
  ('44444444-0000-4000-8000-000000000021','5-60','ratchet'),
  ('44444444-0000-4000-8000-000000000021','High Taper','bit'),
  ('44444444-0000-4000-8000-000000000021','KnightLance','blade'),
  ('44444444-0000-4000-8000-000000000021','3-60','ratchet'),
  ('44444444-0000-4000-8000-000000000021','Low Flat','bit'),
  ('44444444-0000-4000-8000-000000000021','WizardArrow','blade'),
  ('44444444-0000-4000-8000-000000000021','4-80','ratchet'),
  ('44444444-0000-4000-8000-000000000021','Needle','bit'),
  -- UX-07: PhoenixRudder 9-70G / SphinxCowl 1-80GF / WyvernGale 2-60S
  ('44444444-0000-4000-8000-000000000107','PhoenixRudder','blade'),
  ('44444444-0000-4000-8000-000000000107','9-70','ratchet'),
  ('44444444-0000-4000-8000-000000000107','Glide','bit'),
  ('44444444-0000-4000-8000-000000000107','SphinxCowl','blade'),
  ('44444444-0000-4000-8000-000000000107','1-80','ratchet'),
  ('44444444-0000-4000-8000-000000000107','Gear Flat','bit'),
  ('44444444-0000-4000-8000-000000000107','WyvernGale','blade'),
  ('44444444-0000-4000-8000-000000000107','2-60','ratchet'),
  ('44444444-0000-4000-8000-000000000107','Spike','bit'),
  -- UX-15: SharkScale 4-50UF / TyrannoRoar 1-70L / HellsBrave J3-60GF (CX)
  ('44444444-0000-4000-8000-000000000115','SharkScale','blade'),
  ('44444444-0000-4000-8000-000000000115','4-50','ratchet'),
  ('44444444-0000-4000-8000-000000000115','Under Flat','bit'),
  ('44444444-0000-4000-8000-000000000115','TyrannoRoar','blade'),
  ('44444444-0000-4000-8000-000000000115','1-70','ratchet'),
  ('44444444-0000-4000-8000-000000000115','Level','bit'),
  ('44444444-0000-4000-8000-000000000115','Hells','lock_chip'),
  ('44444444-0000-4000-8000-000000000115','Brave','main_blade'),
  ('44444444-0000-4000-8000-000000000115','Jaggy','assist_blade'),
  ('44444444-0000-4000-8000-000000000115','3-60','ratchet'),
  ('44444444-0000-4000-8000-000000000115','Gear Flat','bit'),
  -- CX-11: EmperorMight HOp / GolemRock M-85HN / SharkGill 5-60FB
  ('44444444-0000-4000-8000-000000000211','Emperor','lock_chip'),
  ('44444444-0000-4000-8000-000000000211','Might','main_blade'),
  ('44444444-0000-4000-8000-000000000211','Heavy','assist_blade'),
  ('44444444-0000-4000-8000-000000000211','Operate','ratchet_integrated_bit'),
  ('44444444-0000-4000-8000-000000000211','GolemRock','blade'),
  ('44444444-0000-4000-8000-000000000211','M-85','ratchet'),
  ('44444444-0000-4000-8000-000000000211','High Needle','bit'),
  ('44444444-0000-4000-8000-000000000211','SharkGill','blade'),
  ('44444444-0000-4000-8000-000000000211','5-60','ratchet'),
  ('44444444-0000-4000-8000-000000000211','Free Ball','bit')
) as p(pid, cname, cat) on parts.canonical_name = p.cname and parts.category = p.cat
on conflict on constraint product_parts_uniq do nothing;


