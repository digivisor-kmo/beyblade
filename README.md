# Beyblade X Collectie

PWA om mijn Beyblade X collectie te beheren, combo's te bouwen, de meta te bekijken en tornooi-decks samen te stellen.

Stack: Next.js 16 (App Router) + TypeScript, Supabase (Postgres, Auth, Storage), Tailwind CSS v4. Multi-tenant met Row Level Security vanaf dag 1.

## Opstarten

1. Dependencies installeren:

   ```
   npm install
   ```

2. Supabase koppelen. Maak een project op supabase.com en zet de env:

   ```
   cp .env.local.example .env.local
   # vul NEXT_PUBLIC_SUPABASE_URL en NEXT_PUBLIC_SUPABASE_ANON_KEY in
   ```

3. Migraties draaien (schema + RLS + statische seed). Via de Supabase CLI:

   ```
   supabase link --project-ref <ref>
   supabase db push
   ```

   Of plak de bestanden in `supabase/migrations/` op volgorde in de SQL-editor.

4. Draaien:

   ```
   npm run dev
   ```

   De homepage toont een Supabase-statusregel: groen betekent dat Next -> Supabase -> RLS-catalogus werkt.

## Structuur

- `supabase/migrations/` — schema, RLS-policies en statische seed (categorieen + bouwsjablonen). Losgetest op Postgres 18.
- `lib/supabase/` — browser-, server- en proxy-clients (`@supabase/ssr`).
- `lib/database.types.ts` — types die aansluiten op de migraties. Regenereren: `npm run db:types`.
- `proxy.ts` — ververst de auth-sessie per request (Next 16 conventie, opvolger van middleware).
- `app/` — App Router, PWA-manifest en service worker (`public/sw.js`).

## Scripts

- `npm run dev` / `build` / `start`
- `npm run typecheck` — `tsc --noEmit`
- `npm run db:types` — types uit lokale Supabase regenereren

## Nog te doen

Catalogus seeden (BX eerst), collectie-overzicht, custom builder met sjabloon-validatie, meta-matching, deckbuilder. Zie de projectinstructies voor de fasering.

Afbeeldingen en seed-data: Beyblade Wiki (Fandom, CC-BY-SA), met zichtbare bronvermelding in de UI.
