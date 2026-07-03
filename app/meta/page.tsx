import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { getUser } from "@/lib/auth";
import { getCatalog } from "@/lib/catalog";
import { Thumb, TypeBadge, Badge } from "@/app/components/ui";

type PartInfo = { name: string; image: string | null; category: string };

export default async function MetaPage() {
  const user = await getUser();
  if (!user) redirect("/login");

  const supabase = await createClient();
  const [{ data: builds }, { data: buildParts }, { data: owned }, catalog] =
    await Promise.all([
      supabase
        .from("builds")
        .select("id, name, template_id, source, notes, meta_date")
        .is("user_id", null)
        .eq("kind", "competitive")
        .order("meta_date", { ascending: false }),
      supabase.from("build_parts").select("build_id, part_id"),
      supabase.from("owned_parts").select("part_id"),
      getCatalog(),
    ]);

  const partInfo = new Map<string, PartInfo>(
    catalog.parts.map((p) => [
      p.id,
      { name: p.display_name, image: p.image_url, category: p.category },
    ]),
  );
  const ownedIds = new Set((owned ?? []).map((o) => o.part_id));

  const partsByBuild = new Map<string, string[]>();
  (buildParts ?? []).forEach((bp) => {
    partsByBuild.set(bp.build_id, [
      ...(partsByBuild.get(bp.build_id) ?? []),
      bp.part_id,
    ]);
  });

  const combos = (builds ?? []).map((b) => {
    const ids = partsByBuild.get(b.id) ?? [];
    const parts = ids.map((id) => ({
      id,
      owned: ownedIds.has(id),
      ...(partInfo.get(id) ?? { name: "?", image: null, category: "" }),
    }));
    const missing = parts.filter((p) => !p.owned);
    return { ...b, parts, missingCount: missing.length, missing };
  });

  const buildable = combos.filter((c) => c.missingCount === 0);
  const almost = combos.filter((c) => c.missingCount === 1);
  const far = combos.filter((c) => c.missingCount >= 2);

  return (
    <main className="mx-auto max-w-3xl px-4 py-8">
      <h1 className="font-display text-2xl font-extrabold tracking-wide">
        Competitieve meta
      </h1>
      <p className="mt-1 text-sm text-[var(--color-muted)]">
        Populaire tornooi-combo&apos;s gematcht met jouw collectie.
      </p>

      <div className="mt-4 flex flex-wrap gap-2 text-xs">
        <Badge>{buildable.length} nu bouwbaar</Badge>
        <Badge>{almost.length} mis 1 onderdeel</Badge>
        <Badge>{far.length} mis meer</Badge>
      </div>

      <Section
        title="Nu bouwbaar"
        subtitle="Je hebt alle onderdelen"
        combos={buildable}
        tone="stamina"
      />
      <Section
        title="Bijna compleet"
        subtitle="Mis nog 1 onderdeel"
        combos={almost}
        tone="accent-2"
      />
      <Section
        title="Verder weg"
        subtitle="Mis 2 of meer onderdelen"
        combos={far}
        tone="muted"
      />
    </main>
  );
}

type Combo = {
  id: string;
  name: string;
  source: string | null;
  notes: string | null;
  meta_date: string | null;
  parts: { id: string; owned: boolean; name: string; image: string | null }[];
  missingCount: number;
  missing: { name: string }[];
};

function Section({
  title,
  subtitle,
  combos,
  tone,
}: {
  title: string;
  subtitle: string;
  combos: Combo[];
  tone: "stamina" | "accent-2" | "muted";
}) {
  if (combos.length === 0) return null;
  const color =
    tone === "stamina"
      ? "var(--color-stamina)"
      : tone === "accent-2"
        ? "var(--color-accent-2)"
        : "var(--color-muted)";
  return (
    <section className="mt-8">
      <div className="flex items-baseline gap-2">
        <h2 className="font-display text-sm font-bold" style={{ color }}>
          {title}
        </h2>
        <span className="text-xs text-[var(--color-muted)]">{subtitle}</span>
      </div>

      <ul className="mt-3 space-y-3">
        {combos.map((c) => (
          <li key={c.id} className="card p-4">
            <div className="flex items-center justify-between gap-2">
              <p className="font-semibold">{c.name}</p>
              <TypeBadge type={c.notes} />
            </div>

            <div className="mt-3 flex flex-wrap gap-2">
              {c.parts.map((p) => (
                <div
                  key={p.id}
                  className="flex items-center gap-1.5 rounded-lg border px-2 py-1"
                  style={{
                    borderColor: p.owned
                      ? "color-mix(in srgb, var(--color-stamina) 45%, var(--color-border))"
                      : "color-mix(in srgb, var(--color-accent-2) 45%, var(--color-border))",
                    backgroundColor: p.owned
                      ? "color-mix(in srgb, var(--color-stamina) 10%, transparent)"
                      : "transparent",
                  }}
                >
                  <Thumb src={p.image} alt={p.name} width={80} className="h-6 w-6" />
                  <span className="text-xs">{p.name}</span>
                  <span className="text-xs">{p.owned ? "✓" : "✗"}</span>
                </div>
              ))}
            </div>

            {c.missingCount === 1 && (
              <p className="mt-2 text-xs text-[var(--color-accent-2)]">
                Mis enkel: {c.missing[0].name}
              </p>
            )}

            <p className="mt-2 text-[11px] text-[var(--color-muted)]">
              {c.source}
              {c.meta_date ? ` · ${c.meta_date}` : ""}
            </p>
          </li>
        ))}
      </ul>
    </section>
  );
}
