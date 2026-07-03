import { getCatalog, type Catalog } from "@/lib/catalog";
import { getUser } from "@/lib/auth";
import { CatalogFilters } from "@/app/components/CatalogFilters";
import { AddButton } from "@/app/components/AddButton";
import { Badge, TypeBadge, Thumb } from "@/app/components/ui";

type SP = { [key: string]: string | string[] | undefined };

export default async function CatalogPage({
  searchParams,
}: {
  searchParams: Promise<SP>;
}) {
  const sp = await searchParams;
  const str = (v: string | string[] | undefined) =>
    (Array.isArray(v) ? v[0] : v) ?? "";
  const tab = str(sp.tab) || "producten";
  const lijn = str(sp.lijn);
  const categorie = str(sp.categorie);
  const type = str(sp.type);
  const q = str(sp.q).toLowerCase();
  const eu = str(sp.eu) === "1";

  const [catalog, user] = await Promise.all([getCatalog(), getUser()]);
  const authed = !!user;
  const catName = new Map(catalog.categories.map((c) => [c.id, c.name]));

  return (
    <main className="mx-auto max-w-5xl px-4 py-8">
      <h1 className="text-2xl font-bold">Catalogus</h1>
      <p className="mt-1 text-sm text-[var(--color-muted)]">
        Bekijk alle onderdelen en producten, en voeg toe aan je collectie.
      </p>

      <div className="mt-6">
        <CatalogFilters
          categories={catalog.categories}
          current={{ tab, lijn, categorie, type, q, eu }}
        />
      </div>

      <div className="mt-6">
        {tab === "producten" ? (
          <ProductList catalog={catalog} lijn={lijn} q={q} eu={eu} authed={authed} />
        ) : (
          <PartList
            catalog={catalog}
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

function Empty({ text }: { text: string }) {
  return (
    <div className="card p-10 text-center text-sm text-[var(--color-muted)]">
      {text}
    </div>
  );
}

function PartList({
  catalog,
  lijn,
  categorie,
  type,
  q,
  authed,
  catName,
}: {
  catalog: Catalog;
  lijn: string;
  categorie: string;
  type: string;
  q: string;
  authed: boolean;
  catName: Map<string, string>;
}) {
  const aliasMap = new Map<string, string[]>();
  catalog.aliases.forEach((a) => {
    if (a.brand !== "hasbro") return;
    aliasMap.set(a.part_id, [...(aliasMap.get(a.part_id) ?? []), a.name]);
  });
  const variantCount = new Map<string, number>();
  catalog.variants.forEach((v) =>
    variantCount.set(v.part_id, (variantCount.get(v.part_id) ?? 0) + 1),
  );

  const parts = catalog.parts.filter(
    (p) =>
      (!lijn || p.line === lijn) &&
      (!categorie || p.category === categorie) &&
      (!type || p.type === type) &&
      (!q || p.canonical_name.toLowerCase().includes(q)),
  );

  if (parts.length === 0) return <Empty text="Geen onderdelen gevonden." />;

  return (
    <ul className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
      {parts.map((p) => (
        <li key={p.id} className="card card-hover flex flex-col p-3">
          <Thumb src={p.image_url} alt={p.canonical_name} className="aspect-square" />
          <div className="mt-2 flex-1">
            <p className="font-semibold leading-tight">{p.canonical_name}</p>
            <div className="mt-1.5 flex flex-wrap gap-1">
              <Badge>{catName.get(p.category) ?? p.category}</Badge>
              <Badge>{p.line}</Badge>
              <TypeBadge type={p.type} />
              {(variantCount.get(p.id) ?? 0) > 1 && (
                <Badge>{variantCount.get(p.id)} kleuren</Badge>
              )}
            </div>
            {aliasMap.get(p.id) && (
              <p className="mt-1.5 text-xs text-[var(--color-muted)]">
                Hasbro: {aliasMap.get(p.id)!.join(", ")}
              </p>
            )}
          </div>
          <div className="mt-3">
            <AddButton kind="part" id={p.id} authed={authed} />
          </div>
        </li>
      ))}
    </ul>
  );
}

function ProductList({
  catalog,
  lijn,
  q,
  eu,
  authed,
}: {
  catalog: Catalog;
  lijn: string;
  q: string;
  eu: boolean;
  authed: boolean;
}) {
  const partName = new Map(catalog.parts.map((p) => [p.id, p.canonical_name]));
  const variantName = new Map(catalog.variants.map((v) => [v.id, v.colorway]));
  const contents = new Map<string, string[]>();
  catalog.productParts.forEach((row) => {
    const name = partName.get(row.part_id) ?? "?";
    const color = row.variant_id ? variantName.get(row.variant_id) : null;
    const label = color ? `${name} (${color})` : name;
    contents.set(row.product_id, [...(contents.get(row.product_id) ?? []), label]);
  });

  const products = catalog.products.filter(
    (pr) =>
      (!lijn || pr.line === lijn) &&
      (!eu || pr.eu_available) &&
      (!q || pr.canonical_name.toLowerCase().includes(q)),
  );

  if (products.length === 0) return <Empty text="Geen producten gevonden." />;

  return (
    <ul className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {products.map((pr) => (
        <li key={pr.id} className="card card-hover flex flex-col p-4">
          <div className="flex gap-3">
            <Thumb
              src={pr.image_url}
              alt={pr.canonical_name}
              className="h-24 w-24 shrink-0"
            />
            <div className="min-w-0 flex-1">
              <p className="font-semibold leading-tight">{pr.canonical_name}</p>
              <div className="mt-1.5 flex flex-wrap gap-1">
                {pr.product_code && <Badge>{pr.product_code}</Badge>}
                {pr.line && <Badge>{pr.line}</Badge>}
                {pr.eu_available && <Badge>EU</Badge>}
              </div>
            </div>
          </div>
          <ul className="mt-3 space-y-0.5 text-xs text-[var(--color-muted)]">
            {(contents.get(pr.id) ?? []).map((c, i) => (
              <li key={i}>+ {c}</li>
            ))}
          </ul>
          <div className="mt-3">
            <AddButton
              kind="product"
              id={pr.id}
              authed={authed}
              label="Voeg toe aan collectie"
            />
          </div>
        </li>
      ))}
    </ul>
  );
}
