import { createClient } from "@/lib/supabase/server";

// Huidige ingelogde user (of null). Voor gebruik in Server Components.
export async function getUser() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return user;
}
