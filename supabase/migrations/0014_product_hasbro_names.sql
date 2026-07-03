-- 0014_product_hasbro_names.sql
-- Hasbro EU-productnamen (zoals op de Europese verpakking). De app toont deze
-- als weergavenaam; de TT-naam (canonical_name) blijft als referentie bestaan.
-- Geverifieerd tegen de Hasbro-productlijst op de Beyblade Wiki.

alter table products add column if not exists hasbro_name text;

update products set hasbro_name = 'Sword Dran 3-60F'     where id = '44444444-0000-4000-8000-000000000001';
update products set hasbro_name = 'Scythe Incendio 4-60T' where id = '44444444-0000-4000-8000-000000000002';
update products set hasbro_name = 'Arrow Wizard 4-80B'    where id = '44444444-0000-4000-8000-000000000003';
update products set hasbro_name = 'Helm Knight 3-80N'     where id = '44444444-0000-4000-8000-000000000004';
update products set hasbro_name = 'Keel Shark 3-60LF'     where id = '44444444-0000-4000-8000-000000000014';
update products set hasbro_name = 'Claw Leon 5-60P'       where id = '44444444-0000-4000-8000-000000000015';
update products set hasbro_name = 'Horn Rhino 3-80S'      where id = '44444444-0000-4000-8000-000000000019';
update products set hasbro_name = 'Soar Phoenix 9-60GF'   where id = '44444444-0000-4000-8000-000000000023';
update products set hasbro_name = 'Tail Viper 5-80O'      where id = '44444444-0000-4000-8000-000000000016';
update products set hasbro_name = 'Chain Incendio 5-60HT' where id = '44444444-0000-4000-8000-000000000021';
update products set hasbro_name = 'Beat Tyranno 4-70Q'    where id = '44444444-0000-4000-8000-000000000031';
