-- 0010_collection_functions.sql
-- Helper-functies om aan de collectie toe te voegen, met atomair ophogen.
-- SECURITY INVOKER: draaien onder RLS als de ingelogde user (auth.uid()).

-- Voeg een los onderdeel toe (of hoog de hoeveelheid op).
create or replace function add_owned_part(
  p_part_id   uuid,
  p_variant_id uuid default null,
  p_condition part_condition default 'new',
  p_qty       integer default 1
)
returns void
language sql
security invoker
as $$
  insert into owned_parts (user_id, part_id, variant_id, condition, quantity)
  values (auth.uid(), p_part_id, p_variant_id, p_condition, greatest(p_qty, 1))
  on conflict on constraint owned_parts_uniq
  do update set quantity = owned_parts.quantity + greatest(p_qty, 1),
                updated_at = now();
$$;

-- Voeg alle onderdelen van een product toe aan de collectie.
create or replace function add_product_to_collection(
  p_product_id uuid,
  p_condition  part_condition default 'new'
)
returns void
language sql
security invoker
as $$
  insert into owned_parts (user_id, part_id, variant_id, condition, quantity)
  select auth.uid(), pp.part_id, pp.variant_id, p_condition, pp.quantity
  from product_parts pp
  where pp.product_id = p_product_id
  on conflict on constraint owned_parts_uniq
  do update set quantity = owned_parts.quantity + excluded.quantity,
                updated_at = now();
$$;

grant execute on function add_owned_part(uuid, uuid, part_condition, integer) to authenticated;
grant execute on function add_product_to_collection(uuid, part_condition) to authenticated;
