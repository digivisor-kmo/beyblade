import type { CSSProperties } from "react";

const TYPE_STYLE: Record<string, { label: string; color: string }> = {
  attack: { label: "Attack", color: "var(--color-attack)" },
  defense: { label: "Defense", color: "var(--color-defense)" },
  stamina: { label: "Stamina", color: "var(--color-stamina)" },
  balance: { label: "Balance", color: "var(--color-balance)" },
};

export function TypeBadge({ type }: { type: string | null }) {
  if (!type || !TYPE_STYLE[type]) return null;
  const t = TYPE_STYLE[type];
  const style: CSSProperties = {
    color: t.color,
    borderColor: t.color,
    backgroundColor: "color-mix(in srgb, " + t.color + " 14%, transparent)",
  };
  return (
    <span
      className="rounded-full border px-2 py-0.5 text-[11px] font-semibold"
      style={style}
    >
      {t.label}
    </span>
  );
}

export function Badge({ children }: { children: React.ReactNode }) {
  return (
    <span className="rounded-full border border-[var(--color-border)] bg-[var(--color-surface-2)] px-2 py-0.5 text-[11px] font-medium text-[var(--color-muted)]">
      {children}
    </span>
  );
}

// Vraag een kleinere wiki-thumbnail op i.p.v. de volledige 320px. Scheelt fors
// aan bytes op pagina's met veel afbeeldingen.
function sized(url: string, width: number): string {
  if (!url.includes("static.wikia")) return url;
  if (/scale-to-width-down\/\d+/.test(url)) {
    return url.replace(/scale-to-width-down\/\d+/, `scale-to-width-down/${width}`);
  }
  return url.replace(
    /\/revision\/latest(\?|$)/,
    `/revision/latest/scale-to-width-down/${width}$1`,
  );
}

// Afbeelding met nette fallback. Plain <img> zodat externe wiki-URLs en
// redirects zonder configuratie werken. Lazy + async decoding voor scroll.
export function Thumb({
  src,
  alt,
  className = "",
  width = 160,
}: {
  src: string | null;
  alt: string;
  className?: string;
  width?: number;
}) {
  if (!src) {
    return (
      <div
        className={`thumb flex items-center justify-center text-[var(--color-muted)] ${className}`}
        aria-hidden
      >
        <span className="text-lg">🌀</span>
      </div>
    );
  }
  return (
    <div className={`thumb overflow-hidden ${className}`}>
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        src={sized(src, width)}
        alt={alt}
        loading="lazy"
        decoding="async"
        className="h-full w-full object-contain"
      />
    </div>
  );
}
