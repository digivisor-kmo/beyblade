import { type NextRequest } from "next/server";
import { updateSession } from "@/lib/supabase/middleware";

// Next 16: 'proxy' vervangt de oude 'middleware' conventie.
export async function proxy(request: NextRequest) {
  return await updateSession(request);
}

export const config = {
  matcher: [
    // Alles behalve statics, images en het service worker-bestand.
    "/((?!_next/static|_next/image|favicon.ico|manifest.webmanifest|sw.js|icon-.*\\.png|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};
