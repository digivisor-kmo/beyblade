-- 0011_seed_images.sql
-- Afbeeldings-URLs (Beyblade Wiki / Fandom, CC-BY-SA), 320px thumbnails.
-- Bron-attributie staat al in de UI. Losse colorways delen voorlopig de
-- basis-afbeelding van hun part.

-- Blades
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/5/5f/BladeDranSword.png/revision/latest/scale-to-width-down/320?cb=20250814202546' where id = '11111111-0000-4000-8000-000000000001';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/e/e4/BladeHellsScythe.png/revision/latest/scale-to-width-down/320?cb=20250817035337' where id = '11111111-0000-4000-8000-000000000002';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/4/44/BladeWizardArrow.png/revision/latest/scale-to-width-down/320?cb=20250626062049' where id = '11111111-0000-4000-8000-000000000003';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/9/9c/BladeKnightShield.png/revision/latest/scale-to-width-down/320?cb=20250609060142' where id = '11111111-0000-4000-8000-000000000004';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/2/2e/BladeSharkEdge.png/revision/latest/scale-to-width-down/320?cb=20230812203549' where id = '11111111-0000-4000-8000-000000000005';

-- Ratchets
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/1/1b/Ratchet3-60.png/revision/latest/scale-to-width-down/320?cb=20240913063429' where id = '22222222-0000-4000-8000-000000000360';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/4/46/Ratchet4-60.png/revision/latest/scale-to-width-down/320?cb=20250317055414' where id = '22222222-0000-4000-8000-000000000460';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/a/ae/Ratchet4-80.png/revision/latest/scale-to-width-down/320?cb=20250608045210' where id = '22222222-0000-4000-8000-000000000480';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/6/69/Ratchet3-80.png/revision/latest/scale-to-width-down/320?cb=20250609060206' where id = '22222222-0000-4000-8000-000000000380';

-- Bits
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/b/b0/BitFlat.png/revision/latest/scale-to-width-down/320?cb=20240913063436' where id = '33333333-0000-4000-8000-000000000001';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/a/ad/BitTaper.png/revision/latest/scale-to-width-down/320?cb=20250317055452' where id = '33333333-0000-4000-8000-000000000002';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/8/8c/BitBall.png/revision/latest/scale-to-width-down/320?cb=20250608045235' where id = '33333333-0000-4000-8000-000000000003';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/2/26/BitNeedle.png/revision/latest/scale-to-width-down/320?cb=20250609060238' where id = '33333333-0000-4000-8000-000000000004';
update parts set image_url = 'https://static.wikia.nocookie.net/beyblade/images/0/0e/BitLowFlat.png/revision/latest?cb=20230812203610' where id = '33333333-0000-4000-8000-000000000005';

-- Producten
update products set image_url = 'https://static.wikia.nocookie.net/beyblade/images/0/09/DranSword_3-60F.png/revision/latest/scale-to-width-down/320?cb=20230516042157' where id = '44444444-0000-4000-8000-000000000001';
update products set image_url = 'https://static.wikia.nocookie.net/beyblade/images/1/1a/HellsScythe_4-60T.jpeg/revision/latest/scale-to-width-down/320?cb=20230517044323' where id = '44444444-0000-4000-8000-000000000002';
update products set image_url = 'https://static.wikia.nocookie.net/beyblade/images/6/6d/WizardArrow_4-80B.jpeg/revision/latest/scale-to-width-down/320?cb=20230517044837' where id = '44444444-0000-4000-8000-000000000003';
update products set image_url = 'https://static.wikia.nocookie.net/beyblade/images/a/ac/KnightShield_3-80N.jpeg/revision/latest/scale-to-width-down/320?cb=20230517045417' where id = '44444444-0000-4000-8000-000000000004';
update products set image_url = 'https://static.wikia.nocookie.net/beyblade/images/7/7c/SharkEdge_3-60LF.png/revision/latest/scale-to-width-down/320?cb=20230812090317' where id = '44444444-0000-4000-8000-000000000014';
