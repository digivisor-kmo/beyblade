import { setQtyForm } from "@/app/actions/collection";

// Server component: +/- via server-action forms, geen client-JS.
// quantity 0 verwijdert de rij (afgehandeld in setOwnedQuantity).
export function QtyControls({
  ownedId,
  quantity,
}: {
  ownedId: string;
  quantity: number;
}) {
  const btn =
    "h-7 w-7 rounded-md border border-[var(--color-border)] text-sm hover:bg-[var(--color-surface-2)]";
  return (
    <div className="flex items-center gap-2">
      <form action={setQtyForm}>
        <input type="hidden" name="ownedId" value={ownedId} />
        <input type="hidden" name="quantity" value={quantity - 1} />
        <button className={btn} aria-label="Minder">
          -
        </button>
      </form>
      <span className="w-6 text-center text-sm tabular-nums">{quantity}</span>
      <form action={setQtyForm}>
        <input type="hidden" name="ownedId" value={ownedId} />
        <input type="hidden" name="quantity" value={quantity + 1} />
        <button className={btn} aria-label="Meer">
          +
        </button>
      </form>
    </div>
  );
}
