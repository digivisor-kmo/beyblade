"use client";

import Link from "next/link";
import { useMemo, useState, useTransition } from "react";
import { addPart, addProduct } from "@/app/actions/collection";
import { Badge, TypeBadge, Thumb } from "@/app/components/ui";

type Part = {
  id: string;
  name: string;
  tt: string | null;
  image: string | null;
  category: string;
  categoryName: string;
  line: string;
  type: string | null;
  colors: number;
};
type Product = {
  id: string;
  name: string;
  code: string | null;
  line: string | null;
  eu: boolean;
  kind: string;
  image: string | null;
  contents: string[];
  partIds: string[];
};
type Category = { id: string; name: string };

const SET_KINDS = new Set(["deck_set", "random_booster", "customize_set"]);
const LINES = ["BX", "UX", "CX"];
const TYPES = [
  { v: "attack", l: "Attack" },
  { v: "defense", l: "Defense" },
  { v: "stamina", l: "Stamina" },
  { v: "balance", l: "Balance" },
];
const TABS = [
  { v: "producten", l: "Producten" },
  { v: "sets", l: "Sets" },
  { v: "onderdelen", l: "Onderdelen" },
];

export function CatalogClient({
  parts,
  products,
  categories,
  authed,
  owned,
}: {
  parts: Part[];
  products: Product[];
  categories: Category[];
  authed: boolean;
  owned: string[];
}) {
  const [tab, setTab] = useState("producten");
  const [lijn, setLijn] = useState("");
  const [categorie, setCategorie] = useState("");
  const [type, setType] = useState("");
  const [q, setQ] = useState("");
  const [eu, setEu] = useState(false);
  const [ownedSet, setOwnedSet] = useState<Set<string>>(new Set(owned));

  const ql = q.trim().toLowerCase();

  const shownParts = useMemo(
    () =>
      parts.filter(
        (p) =>
          (!lijn || p.line === lijn) &&
          (!categorie || p.category === categorie) &&
          (!type || p.type === type) &&
          (!ql ||
            p.name.toLowerCase().includes(ql) ||
            (p.tt ?? "").toLowerCase().includes(ql)),
      ),
    [parts, lijn, categorie, type, ql],
  );

  const shownProducts = useMemo(
    () =>
      products.filter((pr) => {
        const isSet = SET_KINDS.has(pr.kind);
        if (tab === "sets" ? !isSet : isSet) return false;
        return (
          (!lijn || pr.line === lijn) &&
          (!eu || pr.eu) &&
          (!ql || pr.name.toLowerCase().includes(ql))
        );
      }),
    [products, tab, lijn, eu, ql],
  );

  const selectClass =
    "rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-2)] px-3 py-2 text-sm outline-none focus:border-[var(--color-accent)]";

  return (
    <main className="mx-auto max-w-5xl px-4 py-8">
      <h1 className="font-display text-2xl font-extrabold tracking-wide">
        Catalogus
      </h1>
      <p className="mt-1 text-sm text-[var(--color-muted)]">
        Bekijk alles en voeg toe aan je collectie.
      </p>

      {/* Tabs */}
      <div className="mt-6 inline-flex rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] p-1 text-sm">
        {TABS.map((t) => (
          <button
            key={t.v}
            onClick={() => setTab(t.v)}
            className={`font-display rounded-lg px-4 py-1.5 text-xs font-bold tracking-wide transition ${
              tab === t.v ? "text-white" : "text-[var(--color-muted)]"
            }`}
            style={
              tab === t.v
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

      {/* Filters */}
      <div className="mt-3 flex flex-wrap gap-2">
        <select
          value={lijn}
          onChange={(e) => setLijn(e.target.value)}
          className={selectClass}
        >
          <option value="">Alle lijnen</option>
          {LINES.map((l) => (
            <option key={l} value={l}>
              {l}
            </option>
          ))}
        </select>

        {tab === "onderdelen" && (
          <>
            <select
              value={categorie}
              onChange={(e) => setCategorie(e.target.value)}
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
              value={type}
              onChange={(e) => setType(e.target.value)}
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

        {tab !== "onderdelen" && (
          <label className="flex items-center gap-2 px-1 text-sm text-[var(--color-muted)]">
            <input
              type="checkbox"
              checked={eu}
              onChange={(e) => setEu(e.target.checked)}
            />
            Alleen EU
          </label>
        )}

        <input
          type="search"
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="Zoek op naam..."
          className={`${selectClass} min-w-[10rem] flex-1`}
        />
      </div>

      {/* Inhoud */}
      <div className="mt-6">
        {tab === "onderdelen" ? (
          <PartGrid
            parts={shownParts}
            authed={authed}
            ownedSet={ownedSet}
            setOwnedSet={setOwnedSet}
          />
        ) : (
          <ProductGrid
            products={shownProducts}
            authed={authed}
            ownedSet={ownedSet}
            setOwnedSet={setOwnedSet}
          />
        )}
      </div>
    </main>
  );
}

function OwnedBadge({ children }: { children: React.ReactNode }) {
  return (
    <span
      className="rounded-full border px-2 py-0.5 text-[11px] font-semibold"
      style={{
        color: "var(--color-stamina)",
        borderColor: "var(--color-stamina)",
        backgroundColor: "color-mix(in srgb, var(--color-stamina) 14%, transparent)",
      }}
    >
      {children}
    </span>
  );
}

function AddBtn({
  onAdd,
  label,
}: {
  onAdd: () => Promise<void>;
  label: string;
}) {
  const [pending, start] = useTransition();
  const [done, setDone] = useState(false);
  return (
    <button
      onClick={() =>
        start(async () => {
          await onAdd();
          setDone(true);
          setTimeout(() => setDone(false), 1400);
        })
      }
      disabled={pending}
      className={`w-full px-3 py-2 text-xs ${
        done
          ? "rounded-lg border border-[var(--color-stamina)] font-semibold text-[var(--color-stamina)]"
          : "btn-primary"
      }`}
    >
      {pending ? "Bezig..." : done ? "✓ Toegevoegd" : label}
    </button>
  );
}

function PartGrid({
  parts,
  authed,
  ownedSet,
  setOwnedSet,
}: {
  parts: Part[];
  authed: boolean;
  ownedSet: Set<string>;
  setOwnedSet: (s: Set<string>) => void;
}) {
  if (parts.length === 0)
    return (
      <div className="card p-10 text-center text-sm text-[var(--color-muted)]">
        Geen onderdelen gevonden.
      </div>
    );
  return (
    <ul className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
      {parts.map((p) => {
        const isOwned = ownedSet.has(p.id);
        return (
          <li key={p.id} className="card card-hover flex flex-col p-3">
            <Thumb src={p.image} alt={p.name} className="aspect-square" />
            <div className="mt-2 flex-1">
              <p className="font-semibold leading-tight">{p.name}</p>
              {p.tt && (
                <p className="text-xs text-[var(--color-muted)]">TT: {p.tt}</p>
              )}
              <div className="mt-1.5 flex flex-wrap gap-1">
                {isOwned && <OwnedBadge>In bezit</OwnedBadge>}
                <Badge>{p.categoryName}</Badge>
                <Badge>{p.line}</Badge>
                <TypeBadge type={p.type} />
                {p.colors > 1 && <Badge>{p.colors} kleuren</Badge>}
              </div>
            </div>
            <div className="mt-3">
              {authed ? (
                <AddBtn
                  label="Toevoegen"
                  onAdd={async () => {
                    await addPart(p.id);
                    setOwnedSet(new Set(ownedSet).add(p.id));
                  }}
                />
              ) : (
                <Link
                  href="/login"
                  className="block w-full rounded-lg border border-[var(--color-border)] px-3 py-2 text-center text-xs text-[var(--color-muted)]"
                >
                  Login om toe te voegen
                </Link>
              )}
            </div>
          </li>
        );
      })}
    </ul>
  );
}

function ProductGrid({
  products,
  authed,
  ownedSet,
  setOwnedSet,
}: {
  products: Product[];
  authed: boolean;
  ownedSet: Set<string>;
  setOwnedSet: (s: Set<string>) => void;
}) {
  if (products.length === 0)
    return (
      <div className="card p-10 text-center text-sm text-[var(--color-muted)]">
        Niets gevonden.
      </div>
    );
  return (
    <ul className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {products.map((pr) => {
        const ownedCount = pr.partIds.filter((id) => ownedSet.has(id)).length;
        const complete = pr.partIds.length > 0 && ownedCount === pr.partIds.length;
        return (
          <li
            key={pr.id}
            className={`card card-hover flex flex-col p-4 ${
              complete ? "ring-1 ring-[var(--color-stamina)]/40" : ""
            }`}
          >
            <div className="flex gap-3">
              <Thumb
                src={pr.image}
                alt={pr.name}
                width={200}
                className="h-24 w-24 shrink-0"
              />
              <div className="min-w-0 flex-1">
                <p className="font-semibold leading-tight">{pr.name}</p>
                <div className="mt-1.5 flex flex-wrap gap-1">
                  {authed && ownedCount > 0 && (
                    <OwnedBadge>
                      {complete
                        ? "Compleet in bezit"
                        : `${ownedCount}/${pr.partIds.length} in bezit`}
                    </OwnedBadge>
                  )}
                  {pr.code && <Badge>{pr.code}</Badge>}
                  {pr.line && <Badge>{pr.line}</Badge>}
                  {pr.eu && <Badge>EU</Badge>}
                </div>
              </div>
            </div>
            <ul className="mt-3 space-y-0.5 text-xs text-[var(--color-muted)]">
              {pr.contents.map((c, i) => (
                <li key={i}>+ {c}</li>
              ))}
            </ul>
            <div className="mt-3">
              {authed ? (
                <AddBtn
                  label="Voeg toe aan collectie"
                  onAdd={async () => {
                    await addProduct(pr.id);
                    const next = new Set(ownedSet);
                    pr.partIds.forEach((id) => next.add(id));
                    setOwnedSet(next);
                  }}
                />
              ) : (
                <Link
                  href="/login"
                  className="block w-full rounded-lg border border-[var(--color-border)] px-3 py-2 text-center text-xs text-[var(--color-muted)]"
                >
                  Login om toe te voegen
                </Link>
              )}
            </div>
          </li>
        );
      })}
    </ul>
  );
}
