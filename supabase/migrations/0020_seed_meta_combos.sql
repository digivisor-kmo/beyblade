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
