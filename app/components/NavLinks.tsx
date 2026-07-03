"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const LINKS = [
  { href: "/collectie", label: "Mijn collectie" },
  { href: "/catalogus", label: "Catalogus" },
  { href: "/builder", label: "Bouwer" },
  { href: "/meta", label: "Meta" },
];

export function NavLinks() {
  const pathname = usePathname();
  return (
    <div className="flex items-center gap-1">
      {LINKS.map((l) => {
        const active = pathname === l.href || pathname.startsWith(l.href + "/");
        return (
          <Link
            key={l.href}
            href={l.href}
            className={`rounded-lg px-3 py-1.5 text-sm font-medium transition-colors ${
              active
                ? "bg-[var(--color-surface-2)] text-[var(--color-text)]"
                : "text-[var(--color-muted)] hover:text-[var(--color-text)]"
            }`}
          >
            {l.label}
          </Link>
        );
      })}
    </div>
  );
}
