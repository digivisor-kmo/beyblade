import { cache } from "react";
import { createClient } from "@/lib/supabase/server";

// Huidige ingelogde user (of null). Gewrapt in React cache() zodat meerdere
// aanroepen binnen dezelfde request (bv. NavBar + pagina) samen 1 auth-call
// doen in plaats van elk een eigen netwerkcall.
export const getUser = cache(async () => {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return user;
});
