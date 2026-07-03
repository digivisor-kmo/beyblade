-- 0022_seed_deck_sets.sql
-- Deck Sets: producten met 3 vaste beys. "Voeg toe" zet alle onderdelen in de
-- collectie (past in het bestaande model). BX-21 was half-gemodelleerd als
-- enkele bey; hier bijgewerkt naar de volledige set.
-- Random Boosters (een-van-meerdere) volgen later, met een ander model.

-- ---------------------------------------------------------------------------
-- Producten (deck sets). hasbro_name leeg: dit zijn TT-deck sets.
-- ---------------------------------------------------------------------------
insert into products (id, canonical_name, hasbro_name, product_code, brand, kind, line, eu_available) values
  ('44444444-0000-4000-8000-000000000008','3on3 Deck Set',null,'BX-08','takara_tomy','deck_set','BX',true),
  ('44444444-0000-4000-8000-000000000020','DranDagger Deck Set',null,'BX-20','takara_tomy','deck_set','BX',true),
  ('44444444-0000-4000-8000-000000000021','HellsChain Deck Set',null,'BX-21','takara_tomy','deck_set','BX',true),
  ('44444444-0000-4000-8000-000000000107','PhoenixRudder Deck Set',null,'UX-07','takara_tomy','deck_set','UX',true),
  ('44444444-0000-4000-8000-000000000115','SharkScale Deck Set',null,'UX-15','takara_tomy','deck_set','UX',true),
  ('44444444-0000-4000-8000-000000000211','EmperorMight Deck Set',null,'CX-11','takara_tomy','deck_set','CX',true)
on conflict (id) do update set
  canonical_name=excluded.canonical_name, hasbro_name=excluded.hasbro_name,
  kind=excluded.kind, line=excluded.line, eu_available=excluded.eu_available;

delete from product_parts where product_id in (
  '44444444-0000-4000-8000-000000000008','44444444-0000-4000-8000-000000000020',
  '44444444-0000-4000-8000-000000000021','44444444-0000-4000-8000-000000000107',
  '44444444-0000-4000-8000-000000000115','44444444-0000-4000-8000-000000000211');

insert into product_parts (product_id, part_id, quantity)
select p.pid::uuid, parts.id, 1
from parts join (values
  -- BX-08: HellsScythe 3-80B / KnightShield 4-80T / WizardArrow 4-60N
  ('44444444-0000-4000-8000-000000000008','HellsScythe','blade'),
  ('44444444-0000-4000-8000-000000000008','3-80','ratchet'),
  ('44444444-0000-4000-8000-000000000008','Ball','bit'),
  ('44444444-0000-4000-8000-000000000008','KnightShield','blade'),
  ('44444444-0000-4000-8000-000000000008','4-80','ratchet'),
  ('44444444-0000-4000-8000-000000000008','Taper','bit'),
  ('44444444-0000-4000-8000-000000000008','WizardArrow','blade'),
  ('44444444-0000-4000-8000-000000000008','4-60','ratchet'),
  ('44444444-0000-4000-8000-000000000008','Needle','bit'),
  -- BX-20: DranDagger 4-60R / KnightShield 5-80T / SharkEdge 3-80F
  ('44444444-0000-4000-8000-000000000020','DranDagger','blade'),
  ('44444444-0000-4000-8000-000000000020','4-60','ratchet'),
  ('44444444-0000-4000-8000-000000000020','Rush','bit'),
  ('44444444-0000-4000-8000-000000000020','KnightShield','blade'),
  ('44444444-0000-4000-8000-000000000020','5-80','ratchet'),
  ('44444444-0000-4000-8000-000000000020','Taper','bit'),
  ('44444444-0000-4000-8000-000000000020','SharkEdge','blade'),
  ('44444444-0000-4000-8000-000000000020','3-80','ratchet'),
  ('44444444-0000-4000-8000-000000000020','Flat','bit'),
  -- BX-21: HellsChain 5-60HT / KnightLance 3-60LF / WizardArrow 4-80N
  ('44444444-0000-4000-8000-000000000021','HellsChain','blade'),
  ('44444444-0000-4000-8000-000000000021','5-60','ratchet'),
  ('44444444-0000-4000-8000-000000000021','High Taper','bit'),
  ('44444444-0000-4000-8000-000000000021','KnightLance','blade'),
  ('44444444-0000-4000-8000-000000000021','3-60','ratchet'),
  ('44444444-0000-4000-8000-000000000021','Low Flat','bit'),
  ('44444444-0000-4000-8000-000000000021','WizardArrow','blade'),
  ('44444444-0000-4000-8000-000000000021','4-80','ratchet'),
  ('44444444-0000-4000-8000-000000000021','Needle','bit'),
  -- UX-07: PhoenixRudder 9-70G / SphinxCowl 1-80GF / WyvernGale 2-60S
  ('44444444-0000-4000-8000-000000000107','PhoenixRudder','blade'),
  ('44444444-0000-4000-8000-000000000107','9-70','ratchet'),
  ('44444444-0000-4000-8000-000000000107','Glide','bit'),
  ('44444444-0000-4000-8000-000000000107','SphinxCowl','blade'),
  ('44444444-0000-4000-8000-000000000107','1-80','ratchet'),
  ('44444444-0000-4000-8000-000000000107','Gear Flat','bit'),
  ('44444444-0000-4000-8000-000000000107','WyvernGale','blade'),
  ('44444444-0000-4000-8000-000000000107','2-60','ratchet'),
  ('44444444-0000-4000-8000-000000000107','Spike','bit'),
  -- UX-15: SharkScale 4-50UF / TyrannoRoar 1-70L / HellsBrave J3-60GF (CX)
  ('44444444-0000-4000-8000-000000000115','SharkScale','blade'),
  ('44444444-0000-4000-8000-000000000115','4-50','ratchet'),
  ('44444444-0000-4000-8000-000000000115','Under Flat','bit'),
  ('44444444-0000-4000-8000-000000000115','TyrannoRoar','blade'),
  ('44444444-0000-4000-8000-000000000115','1-70','ratchet'),
  ('44444444-0000-4000-8000-000000000115','Level','bit'),
  ('44444444-0000-4000-8000-000000000115','Hells','lock_chip'),
  ('44444444-0000-4000-8000-000000000115','Brave','main_blade'),
  ('44444444-0000-4000-8000-000000000115','Jaggy','assist_blade'),
  ('44444444-0000-4000-8000-000000000115','3-60','ratchet'),
  ('44444444-0000-4000-8000-000000000115','Gear Flat','bit'),
  -- CX-11: EmperorMight HOp / GolemRock M-85HN / SharkGill 5-60FB
  ('44444444-0000-4000-8000-000000000211','Emperor','lock_chip'),
  ('44444444-0000-4000-8000-000000000211','Might','main_blade'),
  ('44444444-0000-4000-8000-000000000211','Heavy','assist_blade'),
  ('44444444-0000-4000-8000-000000000211','Operate','ratchet_integrated_bit'),
  ('44444444-0000-4000-8000-000000000211','GolemRock','blade'),
  ('44444444-0000-4000-8000-000000000211','M-85','ratchet'),
  ('44444444-0000-4000-8000-000000000211','High Needle','bit'),
  ('44444444-0000-4000-8000-000000000211','SharkGill','blade'),
  ('44444444-0000-4000-8000-000000000211','5-60','ratchet'),
  ('44444444-0000-4000-8000-000000000211','Free Ball','bit')
) as p(pid, cname, cat) on parts.canonical_name = p.cname and parts.category = p.cat
on conflict on constraint product_parts_uniq do nothing;
