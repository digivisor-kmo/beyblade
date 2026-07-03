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
