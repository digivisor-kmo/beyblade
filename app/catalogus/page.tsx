import { createClient } from "@/lib/supabase/server";
import { getCatalog } from "@/lib/catalog";
import { getUser } from "@/lib/auth";
import { CatalogClient } from "@/app/components/CatalogClient";

export default async function CatalogPage() {
  const [catalog, user] = await Promise.all([getCatalog(), getUser()]);

  // Eén keer de eigen part-ids ophalen (voor de "in bezit"-status).
  let owned: string[] = [];
  if (user) {
    const supabase = await createClient();
    const { data } = await supabase.from("owned_parts").select("part_id");
    owned = [...new Set((data ?? []).map((o) => o.part_id))];
  }

  const catName = new Map(catalog.categories.map((c) => [c.id, c.name]));
  const variantCount = new Map<string, number>();
  catalog.variants.forEach((v) =>
    variantCount.set(v.part_id, (variantCount.get(v.part_id) ?? 0) + 1),
  );

  const parts = catalog.parts.map((p) => ({
    id: p.id,
    name: p.display_name,
    tt: p.hasbro_name && p.hasbro_name !== p.canonical_name ? p.canonical_name : null,
    image: p.image_url,
    category: p.category,
    categoryName: catName.get(p.category) ?? p.category,
    line: p.line,
    type: p.type,
    colors: variantCount.get(p.id) ?? 0,
  }));

  const partName = new Map(catalog.parts.map((p) => [p.id, p.display_name]));
  const partImg = new Map(catalog.parts.map((p) => [p.id, p.image_url]));
  const partCat = new Map(catalog.parts.map((p) => [p.id, p.category]));
  const variantName = new Map(catalog.variants.map((v) => [v.id, v.colorway]));

  const contents = new Map<string, string[]>();
  const idsByProduct = new Map<string, string[]>();
  catalog.productParts.forEach((row) => {
    const nm = partName.get(row.part_id) ?? "?";
    const color = row.variant_id ? variantName.get(row.variant_id) : null;
    contents.set(row.product_id, [
      ...(contents.get(row.product_id) ?? []),
      color ? `${nm} (${color})` : nm,
    ]);
    idsByProduct.set(row.product_id, [
      ...(idsByProduct.get(row.product_id) ?? []),
      row.part_id,
    ]);
  });

  // Een bey wordt gedefinieerd door precies 1 "hoofdblade". Meerdere ervan in
  // een product = een set (deck set / multi-bey), anders een gewoon product.
  const MAIN = new Set(["blade", "ratchet_integrated_blade", "main_blade", "metal_blade"]);
  const HERO = ["blade", "main_blade", "ratchet_integrated_blade", "metal_blade", "lock_chip"];
  const products = catalog.products.map((pr) => {
    const ids = idsByProduct.get(pr.id) ?? [];
    const beyCount = ids.filter((id) => MAIN.has(partCat.get(id) ?? "")).length;
    let hero = pr.image_url;
    if (!hero) {
      for (const c of HERO) {
        const hit = ids.find((id) => partCat.get(id) === c && partImg.get(id));
        if (hit) {
          hero = partImg.get(hit) ?? null;
          break;
        }
      }
    }
    return {
      id: pr.id,
      name: pr.hasbro_name ?? pr.canonical_name,
      code: pr.product_code,
      line: pr.line,
      eu: pr.eu_available,
      kind: pr.kind,
      image: hero,
      contents: contents.get(pr.id) ?? [],
      partIds: ids,
      isSet: beyCount >= 2,
    };
  });

  return (
    <CatalogClient
      parts={parts}
      products={products}
      categories={catalog.categories.map((c) => ({ id: c.id, name: c.name }))}
      authed={!!user}
      owned={owned}
    />
  );
}
