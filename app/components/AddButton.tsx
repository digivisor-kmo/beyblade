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
        className="block w-full rounded-lg border border-[var(--color-border)] px-3 py-2 text-center text-xs text-[var(--color-muted)] hover:text-[var(--color-text)]"
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
    <div>
      <button
        onClick={onClick}
        disabled={pending}
        className={`w-full px-3 py-2 text-xs ${
          done
            ? "rounded-lg border border-[var(--color-stamina)] font-semibold text-[var(--color-stamina)]"
            : "btn-primary"
        }`}
      >
        {pending ? "Bezig..." : done ? "✓ Toegevoegd" : (label ?? "Toevoegen")}
      </button>
      {error && <span className="mt-1 block text-xs text-red-400">{error}</span>}
    </div>
  );
}
