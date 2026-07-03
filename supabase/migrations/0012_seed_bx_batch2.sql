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
