import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getUser } from "@/lib/auth";
import { getCatalog } from "@/lib/catalog";
import { BuilderClient } from "@/app/components/BuilderClient";
import { DeleteBuildButton } from "@/app/components/DeleteBuildButton";
import { Thumb } from "@/app/components/ui";

export default async function BuilderPage() {
  const user = await getUser();
  if (!user) redirect("/login");

  const supabase = await createClient();
  const [{ data: owned }, { data: builds }, { data: buildParts }, catalog] =
    await Promise.all([
      supabase.from("owned_parts").select("part_id"),
      supabase
        .from("builds")
        .select("id, name, template_id, created_at")
        .eq("kind", "custom")
        .order("created_at", { ascending: false }),
      supabase.from("build_parts").select("build_id, part_id, slot_category"),
      getCatalog(),
    ]);

  const partMap = new Map(catalog.parts.map((p) => [p.id, p]));
  const categoryName: Record<string, string> = Object.fromEntries(
    catalog.categories.map((c) => [c.id, c.name]),
  );
  const templateName = new Map(catalog.templates.map((t) => [t.id, t.name]));

  // Eigen onderdelen, ontdubbeld per part_id, verrijkt met catalogusdata.
  const seen = new Set<string>();
  const ownedParts = (owned ?? [])
    .filter((o) => {
      if (seen.has(o.part_id)) return false;
      seen.add(o.part_id);
      return true;
    })
    .map((o) => {
      const p = partMap.get(o.part_id);
      if (!p) return null;
      return {
        partId: p.id,
        name: p.display_name,
        category: p.category,
        line: p.line,
        image: p.image_url,
      };
    })
    .filter((x): x is NonNullable<typeof x> => x !== null);

  // Opgeslagen builds met hun onderdelen.
  const partsByBuild = new Map<
    string,
    { name: string; image: string | null }[]
  >();
  (buildParts ?? []).forEach((bp) => {
    const p = partMap.get(bp.part_id);
    if (!p) return;
    partsByBuild.set(bp.build_id, [
      ...(partsByBuild.get(bp.build_id) ?? []),
      { name: p.display_name, image: p.image_url },
    ]);
  });

  return (
    <main className="mx-auto max-w-3xl px-4 py-8">
      <h1 className="font-display text-2xl font-extrabold tracking-wide">
        Bouwer
      </h1>
      <p className="mt-1 text-sm text-[var(--color-muted)]">
        Stel een combo samen uit je eigen onderdelen. De bouwer controleert live
        of je bey compleet is.
      </p>

      <div className="mt-6">
        <BuilderClient
          templates={catalog.templates}
          templateSlots={catalog.templateSlots}
          categoryName={categoryName}
          ownedParts={ownedParts}
        />
      </div>

      {(builds ?? []).length > 0 && (
        <section className="mt-10">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-[var(--color-muted)]">
            Mijn builds
          </h2>
          <ul className="mt-3 space-y-2">
            {(builds ?? []).map((b) => (
              <li key={b.id} className="card p-3">
                <div className="flex items-center justify-between gap-2">
                  <div>
                    <p className="font-semibold">{b.name}</p>
                    <p className="text-xs text-[var(--color-muted)]">
                      {templateName.get(b.template_id) ?? b.template_id}
                    </p>
                  </div>
                  <DeleteBuildButton buildId={b.id} />
                </div>
                <div className="mt-2 flex flex-wrap gap-2">
                  {(partsByBuild.get(b.id) ?? []).map((p, i) => (
                    <div key={i} className="flex items-center gap-1.5">
                      <Thumb src={p.image} alt={p.name} className="h-8 w-8" />
                      <span className="text-xs text-[var(--color-muted)]">
                        {p.name}
                      </span>
                    </div>
                  ))}
                </div>
              </li>
            ))}
          </ul>
        </section>
      )}
    </main>
  );
}
