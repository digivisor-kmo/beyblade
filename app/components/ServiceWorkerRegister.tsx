"use client";

import { useEffect } from "react";

// Registreert de service worker voor offline-gebruik (winkel, tornooi).
// De SW zelf staat in public/sw.js.
export function ServiceWorkerRegister() {
  useEffect(() => {
    if (
      typeof window === "undefined" ||
      !("serviceWorker" in navigator) ||
      process.env.NODE_ENV !== "production"
    ) {
      return;
    }
    const onLoad = () => {
      navigator.serviceWorker.register("/sw.js").catch(() => {
        // Registratie mislukt is niet fataal; app werkt online gewoon.
      });
    };
    window.addEventListener("load", onLoad);
    return () => window.removeEventListener("load", onLoad);
  }, []);

  return null;
}
