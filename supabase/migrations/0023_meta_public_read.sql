-- 0023_meta_public_read.sql
-- Sta anon toe om de eigenaarloze competitieve combo's te lezen, zodat we ze
-- met de publieke (cookieloze) client kunnen cachen. Gebruikers-builds blijven
-- privé (die policies zijn 'to authenticated' en alleen eigen rijen).

grant select on builds to anon;
grant select on build_parts to anon;

create policy "meta builds readable by anon" on builds
  for select to anon
  using (user_id is null and kind = 'competitive');

create policy "meta build_parts readable by anon" on build_parts
  for select to anon
  using (
    exists (
      select 1 from builds b
      where b.id = build_parts.build_id and b.user_id is null
    )
  );
