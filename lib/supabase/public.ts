import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/lib/database.types";

// Cookieloze client voor publieke, gedeelde catalogus-reads (anon key).
// Geen sessie -> resultaat is voor iedereen gelijk en dus cachebaar.
export function createPublicClient() {
  return createClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
}
