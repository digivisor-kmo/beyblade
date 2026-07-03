-- 0004_user_tables.sql
-- User-eigen data: collectie, builds en decks. Alles hangt aan user_id.
-- Competitieve combo's staan in builds met user_id = null (template zonder eigenaar).

-- ---------------------------------------------------------------------------
-- owned_parts: bron van waarheid voor de collectie.
-- Meerdere rijen per part toegestaan indien verschillende condition.
-- ---------------------------------------------------------------------------
create table owned_parts (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  part_id    uuid not null references parts(id) on delete cascade,
  quantity   integer not null default 1 check (quantity > 0),
  condition  part_condition not null default 'new',
  notes      text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, part_id, condition)
);

create index owned_parts_user_id_idx on owned_parts(user_id);
create index owned_parts_part_id_idx on owned_parts(part_id);

create trigger owned_parts_set_updated_at
  before update on owned_parts
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- builds: custom combo's, competitieve templates en deck-slots.
-- user_id null = gedeelde competitieve template.
-- ---------------------------------------------------------------------------
create table builds (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users(id) on delete cascade,   -- null = template zonder eigenaar
  name        text not null,
  template_id text not null references build_templates(id),
  kind        build_kind not null default 'custom',
  source      text,                                               -- bron voor competitieve combo (WBO, event, datum)
  notes       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  -- Een template zonder eigenaar moet competitief zijn; eigen builds niet.
  check (
    (user_id is null and kind = 'competitive')
    or (user_id is not null)
  )
);

create index builds_user_id_idx on builds(user_id);
create index builds_template_id_idx on builds(template_id);
create index builds_kind_idx on builds(kind);

create trigger builds_set_updated_at
  before update on builds
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------------
-- build_parts: de part-assignments van een build.
-- slot_category legt vast welke sjabloon-slot dit part vervult (handig bij
-- categorieen die meerdere parts toestaan of bij validatie-uitleg).
-- ---------------------------------------------------------------------------
create table build_parts (
  id            uuid primary key default gen_random_uuid(),
  build_id      uuid not null references builds(id) on delete cascade,
  part_id       uuid not null references parts(id) on delete restrict,
  slot_category text references part_categories(id),
  quantity      integer not null default 1 check (quantity > 0),
  notes         text,
  unique (build_id, part_id)
);

create index build_parts_build_id_idx on build_parts(build_id);
create index build_parts_part_id_idx on build_parts(part_id);

-- ---------------------------------------------------------------------------
-- decks: drie volledige beys (X Format / 3on3).
-- lock_chip_exception: toggle of lock chips uitgezonderd zijn van de
-- geen-herhaling-regel (verschilt per ruleset).
-- ---------------------------------------------------------------------------
create table decks (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references auth.users(id) on delete cascade,
  name                text not null,
  build_1_id          uuid references builds(id) on delete set null,
  build_2_id          uuid references builds(id) on delete set null,
  build_3_id          uuid references builds(id) on delete set null,
  ruleset             text not null default 'x_format',
  lock_chip_exception boolean not null default false,
  notes               text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  -- De drie slots moeten verschillende builds zijn (indien ingevuld).
  check (
    build_1_id is null or build_2_id is null or build_1_id <> build_2_id
  ),
  check (
    build_1_id is null or build_3_id is null or build_1_id <> build_3_id
  ),
  check (
    build_2_id is null or build_3_id is null or build_2_id <> build_3_id
  )
);

create index decks_user_id_idx on decks(user_id);

create trigger decks_set_updated_at
  before update on decks
  for each row execute function set_updated_at();
