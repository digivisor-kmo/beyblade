"use client";

import { useTransition } from "react";
import { setOwnedQuantity } from "@/app/actions/collection";

export function QuantityControls({
  ownedId,
  quantity,
}: {
  ownedId: string;
  quantity: number;
}) {
  const [pending, start] = useTransition();

  const set = (q: number) => start(() => setOwnedQuantity(ownedId, q).then(() => {}));

  return (
    <div className="flex items-center gap-2">
      <button
        onClick={() => set(quantity - 1)}
        disabled={pending}
        className="h-6 w-6 rounded border border-[var(--color-border)] text-sm disabled:opacity-50"
        aria-label="Minder"
      >
        -
      </button>
      <span className="w-6 text-center text-sm tabular-nums">{quantity}</span>
      <button
        onClick={() => set(quantity + 1)}
        disabled={pending}
        className="h-6 w-6 rounded border border-[var(--color-border)] text-sm disabled:opacity-50"
        aria-label="Meer"
      >
        +
      </button>
    </div>
  );
}
