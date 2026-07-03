"use client";

import Link from "next/link";
import { useState, useTransition } from "react";
import { addProduct, addPart } from "@/app/actions/collection";

type Props = {
  kind: "product" | "part";
  id: string;
  variantId?: string | null;
  authed: boolean;
  label?: string;
};

export function AddButton({ kind, id, variantId, authed, label }: Props) {
  const [pending, start] = useTransition();
  const [done, setDone] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!authed) {
    return (
      <Link
        href="/login"
        className="rounded-md border border-[var(--color-border)] px-3 py-1.5 text-xs text-[var(--color-muted)] hover:text-[var(--color-text)]"
      >
        Login om toe te voegen
      </Link>
    );
  }

  const onClick = () =>
    start(async () => {
      setError(null);
      const res =
        kind === "product"
          ? await addProduct(id)
          : await addPart(id, variantId ?? null);
      if ("error" in res) setError(res.error);
      else {
        setDone(true);
        setTimeout(() => setDone(false), 1500);
      }
    });

  return (
    <div className="flex items-center gap-2">
      <button
        onClick={onClick}
        disabled={pending}
        className="rounded-md bg-[var(--color-accent)] px-3 py-1.5 text-xs font-medium text-white hover:opacity-90 disabled:opacity-60"
      >
        {pending ? "..." : done ? "Toegevoegd" : (label ?? "Toevoegen")}
      </button>
      {error && <span className="text-xs text-red-400">{error}</span>}
    </div>
  );
}
