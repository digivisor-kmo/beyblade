import { unstable_cache } from "next/cache";
import { createPublicClient } from "@/lib/supabase/public";

// Gedeelde competitieve meta-combo's (eigenaarloze builds). Verandert alleen bij
// een meta-update, dus gecachet (tag 'meta', 1 uur). Cookieloze client zodat het
// voor iedereen gelijk en dus cachebaar is.
async function fetchMeta() {
  const supabase = createPublicClient();
  const [builds, buildParts] = await Promise.all([
    supabase
      .from("builds")
      .select("id, name, source, notes, meta_date")
      .is("user_id", null)
      .eq("kind", "competitive")
      .order("meta_date", { ascending: false }),
    supabase.from("build_parts").select("build_id, part_id"),
  ]);

  const byBuild = new Map<string, string[]>();
  (buildParts.data ?? []).forEach((bp) => {
    byBuild.set(bp.build_id, [...(byBuild.get(bp.build_id) ?? []), bp.part_id]);
  });

  return (builds.data ?? []).map((b) => ({
    ...b,
    partIds: byBuild.get(b.id) ?? [],
  }));
}

export const getMetaCombos = unstable_cache(fetchMeta, ["meta-v1"], {
  revalidate: 3600,
  tags: ["meta"],
});
