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
