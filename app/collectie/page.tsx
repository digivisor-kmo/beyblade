import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getUser } from "@/lib/auth";
import { getCatalog } from "@/lib/catalog";
import { QuantityControls } from "@/app/components/QuantityControls";

const TYPE_LABEL: Record<string, string> = {
  attack: "Attack",
  defense: "Defense",
  stamina: "Stamina",
  balance: "Balance",
};

export default async function CollectionPage() {
  const user = await getUser();
  if (!user) redirect("/login");

  const supabase = await createClient();
  // Alleen de eigen collectie via de sessie-client; lookups uit de cache.
  const [{ data: owned }, catalog] = await Promise.all([
    supabase
      .from("owned_parts")
      .select("id, part_id, variant_id, quantity, condition"),
    getCatalog(),
  ]);

  const { parts, variants, categories } = catalog;
  const partMap = new Map(parts.map((p) => [p.id, p]));
  const variantName = new Map(variants.map((v) => [v.id, v.colorway]));

  const rows = (owned ?? [])
    .map((o) => {
      const part = partMap.get(o.part_id);
      if (!part) return null;
      return {
        id: o.id,
        quantity: o.quantity,
        condition: o.condition,
        name: part.canonical_name,
        category: part.category,
        line: part.line,
        type: part.type as string | null,
        colorway: o.variant_id ? variantName.get(o.variant_id) : null,
      };
    })
    .filter((r): r is NonNullable<typeof r> => r !== null);

  const totalDistinct = rows.length;
  const totalQty = rows.reduce((s, r) => s + r.quantity, 0);

  const byCategory = new Map<string, number>();
  const byLine = new Map<string, number>();
  const byType = new Map<string, number>();
  rows.forEach((r) => {
    byCategory.set(r.category, (byCategory.get(r.category) ?? 0) + r.quantity);
    byLine.set(r.line, (byLine.get(r.line) ?? 0) + r.quantity);
    if (r.type) byType.set(r.type, (byType.get(r.type) ?? 0) + r.quantity);
  });

  // Groepeer per categorie in sort-volgorde.
  const grouped = (categories ?? [])
    .map((c) => ({ cat: c, items: rows.filter((r) => r.category === c.id) }))
    .filter((g) => g.items.length > 0);

  return (
    <main className="mx-auto max-w-4xl px-4 py-8">
      <h1 className="text-2xl font-bold">Mijn collectie</h1>

      {totalDistinct === 0 ? (
        <div className="mt-6 rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-6 text-sm text-[var(--color-muted)]">
          <p>Je collectie is nog leeg.</p>
          <Link
            href="/catalogus"
            className="mt-2 inline-block text-[var(--color-accent)]"
          >
            Naar de catalogus om onderdelen toe te voegen
          </Link>
        </div>
      ) : (
        <>
          <section className="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4">
            <Stat label="Verschillende onderdelen" value={totalDistinct} />
            <Stat label="Totaal aantal" value={totalQty} />
            <Stat
              label="Per lijn"
              value={[...byLine.entries()].map(([k, v]) => `${k}: ${v}`).join("  ")}
            />
            <Stat
              label="Per type"
              value={
                [...byType.entries()]
                  .map(([k, v]) => `${TYPE_LABEL[k] ?? k}: ${v}`)
                  .join("  ") || "-"
              }
            />
          </section>

          <div className="mt-8 space-y-6">
            {grouped.map((g) => (
              <section key={g.cat.id}>
                <h2 className="mb-2 text-sm font-semibold uppercase tracking-wide text-[var(--color-muted)]">
                  {g.cat.name} ({byCategory.get(g.cat.id)})
                </h2>
                <ul className="divide-y divide-[var(--color-border)] rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)]">
                  {g.items.map((r) => (
                    <li
                      key={r.id}
                      className="flex items-center justify-between gap-3 px-4 py-2.5"
                    >
                      <div>
                        <p className="text-sm font-medium">{r.name}</p>
                        <p className="text-xs text-[var(--color-muted)]">
                          {r.line}
                          {r.colorway ? ` · ${r.colorway}` : ""}
                          {r.condition !== "new" ? ` · ${r.condition}` : ""}
                        </p>
                      </div>
                      <QuantityControls ownedId={r.id} quantity={r.quantity} />
                    </li>
                  ))}
                </ul>
              </section>
            ))}
          </div>
        </>
      )}
    </main>
  );
}

function Stat({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-3">
      <p className="text-xs text-[var(--color-muted)]">{label}</p>
      <p className="mt-1 text-sm font-semibold">{value}</p>
    </div>
  );
}
