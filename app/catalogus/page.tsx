import { createClient } from "@/lib/supabase/server";
import { CatalogFilters } from "@/app/components/CatalogFilters";
import { AddButton } from "@/app/components/AddButton";

type SP = { [key: string]: string | string[] | undefined };

const TYPE_LABEL: Record<string, string> = {
  attack: "Attack",
  defense: "Defense",
  stamina: "Stamina",
  balance: "Balance",
};

function Badge({ children }: { children: React.ReactNode }) {
  return (
    <span className="rounded border border-[var(--color-border)] px-1.5 py-0.5 text-[10px] uppercase tracking-wide text-[var(--color-muted)]">
      {children}
    </span>
  );
}

export default async function CatalogPage({
  searchParams,
}: {
  searchParams: Promise<SP>;
}) {
  const sp = await searchParams;
  const str = (v: string | string[] | undefined) =>
    (Array.isArray(v) ? v[0] : v) ?? "";
  const tab = str(sp.tab) || "onderdelen";
  const lijn = str(sp.lijn);
  const categorie = str(sp.categorie);
  const type = str(sp.type);
  const q = str(sp.q);
  const eu = str(sp.eu) === "1";

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  const authed = !!user;

  const { data: categories } = await supabase
    .from("part_categories")
    .select("id, name")
    .order("sort_order");
  const catName = new Map((categories ?? []).map((c) => [c.id, c.name]));

  return (
    <main className="mx-auto max-w-4xl px-4 py-8">
      <h1 className="text-2xl font-bold">Catalogus</h1>
      <p className="mt-1 text-sm text-[var(--color-muted)]">
        Bron: Beyblade Wiki (Fandom), CC-BY-SA.
      </p>

      <div className="mt-6">
        <CatalogFilters
          categories={categories ?? []}
          current={{ tab, lijn, categorie, type, q, eu }}
        />
      </div>

      <div className="mt-6">
        {tab === "producten" ? (
          <ProductList lijn={lijn} q={q} eu={eu} authed={authed} />
        ) : (
          <PartList
            lijn={lijn}
            categorie={categorie}
            type={type}
            q={q}
            authed={authed}
            catName={catName}
          />
        )}
      </div>
    </main>
  );
}

async function PartList({
  lijn,
  categorie,
  type,
  q,
  authed,
  catName,
}: {
  lijn: string;
  categorie: string;
  type: string;
  q: string;
  authed: boolean;
  catName: Map<string, string>;
}) {
  const supabase = await createClient();
  let query = supabase
    .from("parts")
    .select("id, canonical_name, category, line, type, spin_direction")
    .order("canonical_name");
  if (lijn) query = query.eq("line", lijn as "BX" | "UX" | "CX");
  if (categorie) query = query.eq("category", categorie);
  if (type)
    query = query.eq(
      "type",
      type as "attack" | "defense" | "stamina" | "balance",
    );
  if (q) query = query.ilike("canonical_name", `%${q}%`);
  const { data: parts } = await query;

  const [{ data: aliases }, { data: variants }] = await Promise.all([
    supabase.from("part_aliases").select("part_id, name, brand"),
    supabase.from("part_variants").select("part_id, colorway"),
  ]);
  const aliasMap = new Map<string, string[]>();
  (aliases ?? []).forEach((a) => {
    if (a.brand !== "hasbro") return;
    aliasMap.set(a.part_id, [...(aliasMap.get(a.part_id) ?? []), a.name]);
  });
  const variantCount = new Map<string, number>();
  (variants ?? []).forEach((v) =>
    variantCount.set(v.part_id, (variantCount.get(v.part_id) ?? 0) + 1),
  );

  if (!parts || parts.length === 0) {
    return <p className="text-sm text-[var(--color-muted)]">Geen onderdelen gevonden.</p>;
  }

  return (
    <ul className="grid gap-3 sm:grid-cols-2">
      {parts.map((p) => (
        <li
          key={p.id}
          className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-4"
        >
          <div className="flex items-start justify-between gap-2">
            <div>
              <p className="font-medium">{p.canonical_name}</p>
              <div className="mt-1 flex flex-wrap gap-1">
                <Badge>{catName.get(p.category) ?? p.category}</Badge>
                <Badge>{p.line}</Badge>
                {p.type && <Badge>{TYPE_LABEL[p.type]}</Badge>}
                {(variantCount.get(p.id) ?? 0) > 1 && (
                  <Badge>{variantCount.get(p.id)} kleuren</Badge>
                )}
              </div>
              {aliasMap.get(p.id) && (
                <p className="mt-1 text-xs text-[var(--color-muted)]">
                  Hasbro: {aliasMap.get(p.id)!.join(", ")}
                </p>
              )}
            </div>
          </div>
          <div className="mt-3">
            <AddButton kind="part" id={p.id} authed={authed} />
          </div>
        </li>
      ))}
    </ul>
  );
}

async function ProductList({
  lijn,
  q,
  eu,
  authed,
}: {
  lijn: string;
  q: string;
  eu: boolean;
  authed: boolean;
}) {
  const supabase = await createClient();
  let query = supabase
    .from("products")
    .select("id, canonical_name, product_code, brand, kind, line, eu_available")
    .order("product_code");
  if (lijn) query = query.eq("line", lijn as "BX" | "UX" | "CX");
  if (eu) query = query.eq("eu_available", true);
  if (q) query = query.ilike("canonical_name", `%${q}%`);
  const { data: products } = await query;

  const [{ data: pp }, { data: partsAll }, { data: variantsAll }] =
    await Promise.all([
      supabase.from("product_parts").select("product_id, part_id, variant_id, quantity"),
      supabase.from("parts").select("id, canonical_name"),
      supabase.from("part_variants").select("id, colorway"),
    ]);
  const partName = new Map((partsAll ?? []).map((p) => [p.id, p.canonical_name]));
  const variantName = new Map((variantsAll ?? []).map((v) => [v.id, v.colorway]));
  const contents = new Map<string, string[]>();
  (pp ?? []).forEach((row) => {
    const name = partName.get(row.part_id) ?? "?";
    const color = row.variant_id ? variantName.get(row.variant_id) : null;
    const label = color ? `${name} (${color})` : name;
    contents.set(row.product_id, [...(contents.get(row.product_id) ?? []), label]);
  });

  if (!products || products.length === 0) {
    return <p className="text-sm text-[var(--color-muted)]">Geen producten gevonden.</p>;
  }

  return (
    <ul className="grid gap-3 sm:grid-cols-2">
      {products.map((pr) => (
        <li
          key={pr.id}
          className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-4"
        >
          <div className="flex items-center gap-2">
            <p className="font-medium">{pr.canonical_name}</p>
            {pr.eu_available && <Badge>EU</Badge>}
          </div>
          <div className="mt-1 flex flex-wrap gap-1">
            {pr.product_code && <Badge>{pr.product_code}</Badge>}
            {pr.line && <Badge>{pr.line}</Badge>}
            <Badge>{pr.kind}</Badge>
          </div>
          <ul className="mt-2 text-xs text-[var(--color-muted)]">
            {(contents.get(pr.id) ?? []).map((c, i) => (
              <li key={i}>+ {c}</li>
            ))}
          </ul>
          <div className="mt-3">
            <AddButton
              kind="product"
              id={pr.id}
              authed={authed}
              label="Voeg product toe"
            />
          </div>
        </li>
      ))}
    </ul>
  );
}
