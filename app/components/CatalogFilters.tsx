"use client";

import { useRouter } from "next/navigation";

type Category = { id: string; name: string };

const LINES = ["BX", "UX", "CX"];
const TYPES = [
  { v: "attack", l: "Attack" },
  { v: "defense", l: "Defense" },
  { v: "stamina", l: "Stamina" },
  { v: "balance", l: "Balance" },
];

export function CatalogFilters({
  categories,
  current,
}: {
  categories: Category[];
  current: {
    tab: string;
    lijn: string;
    categorie: string;
    type: string;
    q: string;
    eu: boolean;
  };
}) {
  const router = useRouter();

  const update = (patch: Partial<typeof current>) => {
    const next = { ...current, ...patch };
    const params = new URLSearchParams();
    if (next.tab && next.tab !== "producten") params.set("tab", next.tab);
    if (next.lijn) params.set("lijn", next.lijn);
    if (next.categorie) params.set("categorie", next.categorie);
    if (next.type) params.set("type", next.type);
    if (next.q) params.set("q", next.q);
    if (next.eu) params.set("eu", "1");
    const qs = params.toString();
    router.push(qs ? `/catalogus?${qs}` : "/catalogus");
  };

  const selectClass =
    "rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-2)] px-3 py-2 text-sm outline-none focus:border-[var(--color-accent)]";

  return (
    <div className="space-y-3">
      <div className="inline-flex rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] p-1 text-sm">
        {[
          { v: "producten", l: "Producten" },
          { v: "onderdelen", l: "Onderdelen" },
        ].map((t) => (
          <button
            key={t.v}
            onClick={() => update({ tab: t.v })}
            className={`font-display rounded-lg px-4 py-1.5 text-xs font-bold tracking-wide transition ${
              current.tab === t.v
                ? "text-white"
                : "text-[var(--color-muted)] hover:text-[var(--color-text)]"
            }`}
            style={
              current.tab === t.v
                ? {
                    background:
                      "linear-gradient(180deg, var(--color-accent), var(--color-accent-hover))",
                    boxShadow: "0 6px 16px -8px rgba(61,123,255,0.7)",
                  }
                : undefined
            }
          >
            {t.l}
          </button>
        ))}
      </div>

      <div className="flex flex-wrap gap-2">
        <select
          value={current.lijn}
          onChange={(e) => update({ lijn: e.target.value })}
          className={selectClass}
        >
          <option value="">Alle lijnen</option>
          {LINES.map((l) => (
            <option key={l} value={l}>
              {l}
            </option>
          ))}
        </select>

        {current.tab !== "producten" && (
          <>
            <select
              value={current.categorie}
              onChange={(e) => update({ categorie: e.target.value })}
              className={selectClass}
            >
              <option value="">Alle categorieen</option>
              {categories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </select>

            <select
              value={current.type}
              onChange={(e) => update({ type: e.target.value })}
              className={selectClass}
            >
              <option value="">Alle types</option>
              {TYPES.map((t) => (
                <option key={t.v} value={t.v}>
                  {t.l}
                </option>
              ))}
            </select>
          </>
        )}

        {current.tab === "producten" && (
          <label className="flex items-center gap-2 px-1 text-sm text-[var(--color-muted)]">
            <input
              type="checkbox"
              checked={current.eu}
              onChange={(e) => update({ eu: e.target.checked })}
            />
            Alleen EU
          </label>
        )}

        <input
          type="search"
          defaultValue={current.q}
          placeholder="Zoek op naam..."
          onKeyDown={(e) => {
            if (e.key === "Enter") update({ q: (e.target as HTMLInputElement).value });
          }}
          className={`${selectClass} min-w-[10rem] flex-1`}
        />
      </div>
    </div>
  );
}
