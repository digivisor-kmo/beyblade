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
