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
