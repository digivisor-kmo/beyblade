import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getUser } from "@/lib/auth";
import { getCatalog } from "@/lib/catalog";
import { QtyControls } from "@/app/components/QtyControls";
import { Thumb } from "@/app/components/ui";

export default async function CollectionPage() {
  const user = await getUser();
  if (!user) redirect("/login");

  const supabase = await createClient();
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
        name: part.display_name,
        category: part.category,
        line: part.line,
        type: part.type as string | null,
        image: part.image_url,
        colorway: o.variant_id ? variantName.get(o.variant_id) : null,
      };
    })
    .filter((r): r is NonNullable<typeof r> => r !== null);

  const totalDistinct = rows.length;
  const byCategory = new Map<string, number>();
  rows.forEach((r) =>
    byCategory.set(r.category, (byCategory.get(r.category) ?? 0) + r.quantity),
  );

  const grouped = categories
    .map((c) => ({ cat: c, items: rows.filter((r) => r.category === c.id) }))
    .filter((g) => g.items.length > 0);

  return (
    <main className="mx-auto max-w-4xl px-4 py-8">
      <h1 className="font-display text-2xl font-extrabold tracking-wide">
        Mijn collectie
      </h1>

      {totalDistinct === 0 ? (
        <div className="card mt-6 p-10 text-center">
          <p className="text-4xl">🌀</p>
          <p className="mt-3 font-semibold">Je collectie is nog leeg</p>
          <p className="mt-1 text-sm text-[var(--color-muted)]">
            Voeg je eerste beys toe vanuit de catalogus.
          </p>
          <Link
            href="/catalogus"
            className="btn-primary mt-5 inline-block px-5 py-2.5 text-sm"
          >
            Naar de catalogus
          </Link>
        </div>
      ) : (
        <>
          <div className="mt-6 space-y-6">
            {grouped.map((g) => (
              <section key={g.cat.id}>
                <h2 className="mb-2 flex items-center gap-2 text-sm font-semibold">
                  {g.cat.name}
                  <span className="text-xs font-normal text-[var(--color-muted)]">
                    {byCategory.get(g.cat.id)}
                  </span>
                </h2>
                <ul className="space-y-2">
                  {g.items.map((r) => (
                    <li
                      key={r.id}
                      className="card flex items-center gap-3 p-2.5"
                    >
                      <Thumb
                        src={r.image}
                        alt={r.name}
                        width={96}
                        className="h-14 w-14 shrink-0"
                      />
                      <div className="min-w-0 flex-1">
                        <p className="truncate text-sm font-semibold">{r.name}</p>
                        <p className="text-xs text-[var(--color-muted)]">
                          {r.line}
                          {r.colorway ? ` · ${r.colorway}` : ""}
                          {r.condition !== "new" ? ` · ${r.condition}` : ""}
                        </p>
                      </div>
                      <QtyControls ownedId={r.id} quantity={r.quantity} />
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
