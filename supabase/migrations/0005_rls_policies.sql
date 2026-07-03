-- 0005_rls_policies.sql
-- Row Level Security. Multi-tenant vanaf dag 1.
--
-- Model:
--  * Mastercatalogus = gedeelde read-only reference-data. Iedereen leest,
--    alleen service_role schrijft (seed). Read staat al open voor anon zodat
--    de latere publieke modus geen herbouw vereist.
--  * User-data (owned_parts, builds, build_parts, decks) is user-scoped op
--    auth.uid(). Competitieve builds (user_id null) zijn voor iedereen leesbaar.

-- ===========================================================================
-- Mastercatalogus: RLS aan, publieke SELECT, geen user-writes.
-- (service_role omzeilt RLS en doet de seed.)
-- ===========================================================================
alter table part_categories       enable row level security;
alter table parts                 enable row level security;
alter table part_aliases          enable row level security;
alter table products              enable row level security;
alter table product_parts         enable row level security;
alter table build_templates       enable row level security;
alter table build_template_slots  enable row level security;

create policy "catalog readable" on part_categories
  for select to anon, authenticated using (true);
create policy "catalog readable" on parts
  for select to anon, authenticated using (true);
create policy "catalog readable" on part_aliases
  for select to anon, authenticated using (true);
create policy "catalog readable" on products
  for select to anon, authenticated using (true);
create policy "catalog readable" on product_parts
  for select to anon, authenticated using (true);
create policy "catalog readable" on build_templates
  for select to anon, authenticated using (true);
create policy "catalog readable" on build_template_slots
  for select to anon, authenticated using (true);

-- ===========================================================================
-- owned_parts: volledig user-scoped.
-- ===========================================================================
alter table owned_parts enable row level security;

create policy "own rows readable" on owned_parts
  for select to authenticated using (user_id = auth.uid());
create policy "own rows insertable" on owned_parts
  for insert to authenticated with check (user_id = auth.uid());
create policy "own rows updatable" on owned_parts
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own rows deletable" on owned_parts
  for delete to authenticated using (user_id = auth.uid());

-- ===========================================================================
-- builds: eigen builds + gedeelde competitieve templates (user_id null).
-- Schrijven kan alleen op eigen rijen; null-owner templates komen via seed.
-- ===========================================================================
alter table builds enable row level security;

create policy "own or template readable" on builds
  for select to authenticated
  using (user_id = auth.uid() or user_id is null);
create policy "own builds insertable" on builds
  for insert to authenticated with check (user_id = auth.uid());
create policy "own builds updatable" on builds
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own builds deletable" on builds
  for delete to authenticated using (user_id = auth.uid());

-- ===========================================================================
-- build_parts: zichtbaarheid en schrijfrecht volgen de parent build.
-- ===========================================================================
alter table build_parts enable row level security;

create policy "parent visible readable" on build_parts
  for select to authenticated using (
    exists (
      select 1 from builds b
      where b.id = build_parts.build_id
        and (b.user_id = auth.uid() or b.user_id is null)
    )
  );
create policy "parent owned insertable" on build_parts
  for insert to authenticated with check (
    exists (
      select 1 from builds b
      where b.id = build_parts.build_id and b.user_id = auth.uid()
    )
  );
create policy "parent owned updatable" on build_parts
  for update to authenticated using (
    exists (
      select 1 from builds b
      where b.id = build_parts.build_id and b.user_id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from builds b
      where b.id = build_parts.build_id and b.user_id = auth.uid()
    )
  );
create policy "parent owned deletable" on build_parts
  for delete to authenticated using (
    exists (
      select 1 from builds b
      where b.id = build_parts.build_id and b.user_id = auth.uid()
    )
  );

-- ===========================================================================
-- decks: volledig user-scoped.
-- ===========================================================================
alter table decks enable row level security;

create policy "own rows readable" on decks
  for select to authenticated using (user_id = auth.uid());
create policy "own rows insertable" on decks
  for insert to authenticated with check (user_id = auth.uid());
create policy "own rows updatable" on decks
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own rows deletable" on decks
  for delete to authenticated using (user_id = auth.uid());
