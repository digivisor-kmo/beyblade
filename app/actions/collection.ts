"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

type Result = { ok: true } | { error: string };

// Voeg alle onderdelen van een product toe aan de collectie.
export async function addProduct(productId: string): Promise<Result> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Niet ingelogd." };

  const { error } = await supabase.rpc("add_product_to_collection", {
    p_product_id: productId,
  });
  if (error) return { error: error.message };
  revalidatePath("/collectie");
  return { ok: true };
}

// Voeg een los onderdeel toe (optioneel met colorway).
export async function addPart(
  partId: string,
  variantId?: string | null,
): Promise<Result> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Niet ingelogd." };

  const { error } = await supabase.rpc("add_owned_part", {
    p_part_id: partId,
    p_variant_id: variantId ?? null,
  });
  if (error) return { error: error.message };
  revalidatePath("/collectie");
  return { ok: true };
}

// Zet de hoeveelheid van een collectie-rij; 0 of minder verwijdert de rij.
export async function setOwnedQuantity(
  ownedId: string,
  quantity: number,
): Promise<Result> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Niet ingelogd." };

  if (quantity <= 0) {
    const { error } = await supabase
      .from("owned_parts")
      .delete()
      .eq("id", ownedId);
    if (error) return { error: error.message };
  } else {
    const { error } = await supabase
      .from("owned_parts")
      .update({ quantity })
      .eq("id", ownedId);
    if (error) return { error: error.message };
  }
  revalidatePath("/collectie");
  return { ok: true };
}
