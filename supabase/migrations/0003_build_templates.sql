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
