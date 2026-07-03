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
