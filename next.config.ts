import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Afbeeldingen komen straks van de Beyblade Wiki (Fandom) en Supabase Storage.
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "static.wikia.nocookie.net" },
      { protocol: "https", hostname: "*.supabase.co" },
    ],
  },
};

export default nextConfig;
