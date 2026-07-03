-- 0019_meta_date.sql
-- Recency-datum voor competitieve meta-combo's. Deze combo's staan in builds
-- met user_id = null en kind = 'competitive' (eigenaarloze templates).
-- source houdt de bron vast (bv. WBO-event), notes de type-rol.

alter table builds add column if not exists meta_date date;

create index if not exists builds_meta_idx
  on builds (kind, meta_date desc)
  where user_id is null;
