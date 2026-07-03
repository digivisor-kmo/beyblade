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

// Afbeelding met nette fallback. Plain <img> zodat externe wiki-URLs en
// redirects zonder configuratie werken.
export function Thumb({
  src,
  alt,
  className = "",
}: {
  src: string | null;
  alt: string;
  className?: string;
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
        src={src}
        alt={alt}
        loading="lazy"
        className="h-full w-full object-contain"
      />
    </div>
  );
}
