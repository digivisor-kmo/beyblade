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
