-- 0007_grants.sql
-- Expliciete table-privileges voor de Supabase API-rollen.
-- RLS werkt bovenop GRANTs: zonder grant geen toegang, ongeacht policy.
-- Expliciet houden zodat het schema niet leunt op verborgen defaults.

-- Mastercatalogus: alleen lezen voor anon en authenticated.
grant select on
  part_categories, parts, part_aliases, products, product_parts,
  build_templates, build_template_slots
to anon, authenticated;

-- User-data: authenticated mag CRUD (RLS beperkt tot eigen rijen).
grant select, insert, update, delete on
  owned_parts, builds, build_parts, decks
to authenticated;

-- service_role omzeilt RLS maar heeft nog steeds grants nodig (seed/admin).
grant all on all tables in schema public to service_role;

-- Toekomstige tabellen krijgen dezelfde defaults.
alter default privileges in schema public
  grant select on tables to anon, authenticated;
alter default privileges in schema public
  grant all on tables to service_role;
