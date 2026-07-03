"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

type Result = { ok: true; id?: string } | { error: string };

export async function createBuild(input: {
  templateId: string;
  name: string;
  assignments: { category: string; partId: string }[];
}): Promise<Result> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Niet ingelogd." };

  const name = input.name.trim();
  if (!name) return { error: "Geef je build een naam." };

  // Validatie tegen het bouwsjabloon.
  const { data: slots } = await supabase
    .from("build_template_slots")
    .select("category, min_quantity")
    .eq("template_id", input.templateId);
  if (!slots || slots.length === 0) return { error: "Onbekend bouwsjabloon." };

  const assignedCats = new Set(input.assignments.map((a) => a.category));
  const missing = slots.filter(
    (s) => s.min_quantity > 0 && !assignedCats.has(s.category),
  );
  if (missing.length > 0)
    return { error: "Je build is nog niet compleet." };

  // Verifieer dat elk onderdeel echt in de opgegeven categorie zit.
  const partIds = input.assignments.map((a) => a.partId);
  const { data: parts } = await supabase
    .from("parts")
    .select("id, category")
    .in("id", partIds);
  const catOf = new Map((parts ?? []).map((p) => [p.id, p.category]));
  for (const a of input.assignments) {
    if (catOf.get(a.partId) !== a.category)
      return { error: "Een onderdeel past niet in zijn sleuf." };
  }

  const { data: build, error } = await supabase
    .from("builds")
    .insert({
      user_id: user.id,
      name,
      template_id: input.templateId,
      kind: "custom",
    })
    .select("id")
    .single();
  if (error || !build) return { error: error?.message ?? "Opslaan mislukt." };

  const rows = input.assignments.map((a) => ({
    build_id: build.id,
    part_id: a.partId,
    slot_category: a.category,
  }));
  const { error: bpErr } = await supabase.from("build_parts").insert(rows);
  if (bpErr) {
    await supabase.from("builds").delete().eq("id", build.id); // rollback
    return { error: bpErr.message };
  }

  revalidatePath("/builder");
  return { ok: true, id: build.id };
}

export async function deleteBuild(buildId: string): Promise<Result> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Niet ingelogd." };

  const { error } = await supabase.from("builds").delete().eq("id", buildId);
  if (error) return { error: error.message };
  revalidatePath("/builder");
  return { ok: true };
}
