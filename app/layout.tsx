import type { Metadata, Viewport } from "next";
import "./globals.css";
import { NavBar } from "@/app/components/NavBar";
import { Preloader } from "@/app/components/Preloader";
import { ServiceWorkerRegister } from "@/app/components/ServiceWorkerRegister";

export const metadata: Metadata = {
  title: "Beyblade X Collectie",
  description:
    "Beheer je Beyblade X collectie, bouw combo's, bekijk de meta en stel tornooi-decks samen.",
  appleWebApp: {
    capable: true,
    statusBarStyle: "black-translucent",
    title: "Beyblade X",
  },
};

export const viewport: Viewport = {
  themeColor: "#0b0f1a",
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="nl">
      <body className="min-h-dvh">
        <link
          rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Orbitron:wght@600;700;800&display=swap"
        />
        <Preloader />
        <NavBar />
        {children}
        <ServiceWorkerRegister />
      </body>
    </html>
  );
}
