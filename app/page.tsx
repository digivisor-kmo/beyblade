import { createClient } from "@/lib/supabase/server";

// Statusregel: bewijst dat Next -> Supabase -> RLS-catalogus werkt zodra
// .env.local ingevuld is en de migraties gedraaid zijn.
async function getCatalogStatus() {
  if (!process.env.NEXT_PUBLIC_SUPABASE_URL) {
    return { state: "no-env" as const };
  }
  try {
    const supabase = await createClient();
    const [templates, parts, products] = await Promise.all([
      supabase.from("build_templates").select("*", { count: "exact", head: true }),
      supabase.from("parts").select("*", { count: "exact", head: true }),
      supabase.from("products").select("*", { count: "exact", head: true }),
    ]);
    const err = templates.error || parts.error || products.error;
    if (err) return { state: "error" as const, message: err.message };
    return {
      state: "ok" as const,
      templates: templates.count ?? 0,
      parts: parts.count ?? 0,
      products: products.count ?? 0,
    };
  } catch (e) {
    return {
      state: "error" as const,
      message: e instanceof Error ? e.message : "onbekende fout",
    };
  }
}

export default async function Home() {
  const status = await getCatalogStatus();

  return (
    <main className="mx-auto max-w-2xl px-6 py-16">
      <h1 className="text-3xl font-bold tracking-tight">Beyblade X Collectie</h1>
      <p className="mt-2 text-[var(--color-muted)]">
        Collectie, combo-builder, meta-matching en deckbuilder.
      </p>

      <section className="mt-10 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] p-6">
        <h2 className="text-sm font-semibold uppercase tracking-wide text-[var(--color-muted)]">
          Supabase-status
        </h2>

        {status.state === "no-env" && (
          <div className="mt-3 text-sm">
            <p>Nog niet gekoppeld. Zet de env-variabelen:</p>
            <pre className="mt-3 overflow-x-auto rounded-lg bg-black/40 p-3 text-xs text-[var(--color-muted)]">
              cp .env.local.example .env.local{"\n"}# vul NEXT_PUBLIC_SUPABASE_URL
              en _ANON_KEY in
            </pre>
          </div>
        )}

        {status.state === "error" && (
          <div className="mt-3 text-sm">
            <p className="text-amber-400">Verbonden, maar query faalde.</p>
            <p className="mt-1 text-[var(--color-muted)]">{status.message}</p>
            <p className="mt-2 text-[var(--color-muted)]">
              Draai de migraties in supabase/migrations.
            </p>
          </div>
        )}

        {status.state === "ok" && (
          <div className="mt-3 text-sm">
            <p className="text-emerald-400">Verbonden.</p>
            <p className="mt-1 text-[var(--color-muted)]">
              {status.parts} onderdelen, {status.products} producten en{" "}
              {status.templates} bouwsjablonen in de catalogus.
            </p>
          </div>
        )}
      </section>

      <section className="mt-6 text-sm text-[var(--color-muted)]">
        <p className="font-medium text-[var(--color-text)]">Volgende stappen</p>
        <ol className="mt-2 list-inside list-decimal space-y-1">
          <li>Supabase-project maken en migraties draaien.</li>
          <li>Catalogus seeden (BX eerst).</li>
          <li>Collectie-overzicht en custom builder bouwen.</li>
        </ol>
      </section>
    </main>
  );
}
