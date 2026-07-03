import Link from "next/link";
import { addPartForm, addProductForm } from "@/app/actions/collection";

// Server component: geen client-JS. De form-submit wordt door React afgehandeld
// (server action + revalidate), dus de UI werkt zonder per-kaart hydratie.
export function AddToCollection({
  kind,
  id,
  authed,
  label,
}: {
  kind: "product" | "part";
  id: string;
  authed: boolean;
  label?: string;
}) {
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

  const action = kind === "product" ? addProductForm : addPartForm;
  const field = kind === "product" ? "productId" : "partId";

  return (
    <form action={action}>
      <input type="hidden" name={field} value={id} />
      <button className="btn-primary w-full px-3 py-2 text-xs">
        {label ?? "Toevoegen"}
      </button>
    </form>
  );
}
