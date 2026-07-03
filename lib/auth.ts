import { cache } from "react";
import { createClient } from "@/lib/supabase/server";

// Huidige ingelogde user (of null). Leest de sessie LOKAAL uit de cookie
// (getSession) i.p.v. een netwerk-validatie (getUser) bij elke navigatie.
// Veilig voor UI-beslissingen: de echte beveiliging zit in RLS op de database.
// Gewrapt in cache() zodat NavBar + pagina samen 1 keer lezen per request.
export const getUser = cache(async () => {
  const supabase = await createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();
  return session?.user ?? null;
});
