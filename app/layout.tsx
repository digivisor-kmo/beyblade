import type { Metadata, Viewport } from "next";
import "./globals.css";
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
        {children}
        <ServiceWorkerRegister />
      </body>
    </html>
  );
}
