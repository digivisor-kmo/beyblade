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
