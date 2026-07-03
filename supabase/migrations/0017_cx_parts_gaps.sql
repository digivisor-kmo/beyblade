-- 0017_cx_parts_gaps.sql
-- Ontbrekende CX-onderdelen die na de steekproef-seed nog misten.
-- 1 main blade (Fang), 4 assist blades (Knuckle, Vertical, Erase, Odd),
-- 2 ratchets (4-55, 6-80). 6-80 zonder afbeelding (backfill later).

insert into parts (id, canonical_name, category, line, image_url) values
  ('77777777-0000-4000-8000-000000000013','Fang','main_blade','CX','https://static.wikia.nocookie.net/beyblade/images/a/ae/MainBladeFang.png/revision/latest/scale-to-width-down/320?cb=20250515031203')
on conflict (id) do update set image_url=excluded.image_url;

insert into parts (id, canonical_name, category, line, image_url) values
  ('88888888-0000-4000-8000-000000000014','Knuckle','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/1/11/AssistBladeKnuckle.png/revision/latest/scale-to-width-down/320?cb=20260214040432'),
  ('88888888-0000-4000-8000-000000000015','Vertical','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/6/65/AssistBladeVertical.png/revision/latest/scale-to-width-down/320?cb=20260214040558'),
  ('88888888-0000-4000-8000-000000000016','Erase','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/0/0c/AssistBladeErase.png/revision/latest/scale-to-width-down/320?cb=20260214043159'),
  ('88888888-0000-4000-8000-000000000017','Odd','assist_blade','CX','https://static.wikia.nocookie.net/beyblade/images/8/85/AssistBladeOdd.png/revision/latest/scale-to-width-down/320?cb=20260415025441')
on conflict (id) do update set image_url=excluded.image_url;

insert into parts (id, canonical_name, category, line, ratchet_height, image_url) values
  ('22222222-0000-4000-8000-000000000455','4-55','ratchet','CX','55','https://static.wikia.nocookie.net/beyblade/images/7/7a/Ratchet4-55.png/revision/latest/scale-to-width-down/320?cb=20250605000210'),
  ('22222222-0000-4000-8000-000000000680','6-80','ratchet','CX','80',null)
on conflict (id) do update set ratchet_height=excluded.ratchet_height, image_url=excluded.image_url;
