import { unstable_cache } from "next/cache";
import { createPublicClient } from "@/lib/supabase/public";

// Gedeelde, publieke catalogusdata. Verandert alleen bij een nieuwe seed, dus
// we cachen het bundeltje (tag 'catalog', 1 uur) i.p.v. het bij elke view
// opnieuw uit de database te halen. Filteren gebeurt in-memory op de pagina.
//
// Bij een data-update kun je de cache legen met revalidateTag('catalog').

async function fetchCatalog() {
  const supabase = createPublicClient();
  const [
    categories,
    parts,
    products,
    productParts,
    aliases,
    variants,
    templates,
    templateSlots,
  ] = await Promise.all([
      supabase
        .from("part_categories")
        .select("id, name, sort_order")
        .order("sort_order"),
      supabase
        .from("parts")
        .select(
          "id, canonical_name, category, line, type, spin_direction, image_url",
        )
        .order("canonical_name"),
      supabase
        .from("products")
        .select(
          "id, canonical_name, product_code, brand, kind, line, eu_available, image_url",
        )
        .order("product_code"),
      supabase
        .from("product_parts")
        .select("product_id, part_id, variant_id, quantity"),
      supabase.from("part_aliases").select("part_id, name, brand"),
      supabase.from("part_variants").select("id, part_id, colorway"),
      supabase
        .from("build_templates")
        .select("id, name, line, subtype, allows_integrated_bit, sort_order")
        .order("sort_order"),
      supabase
        .from("build_template_slots")
        .select("template_id, category, min_quantity, max_quantity, sort_order")
        .order("sort_order"),
    ]);

  return {
    categories: categories.data ?? [],
    parts: parts.data ?? [],
    products: products.data ?? [],
    productParts: productParts.data ?? [],
    aliases: aliases.data ?? [],
    variants: variants.data ?? [],
    templates: templates.data ?? [],
    templateSlots: templateSlots.data ?? [],
  };
}

export const getCatalog = unstable_cache(fetchCatalog, ["catalog-v2"], {
  revalidate: 3600,
  tags: ["catalog"],
});

export type Catalog = Awaited<ReturnType<typeof fetchCatalog>>;
