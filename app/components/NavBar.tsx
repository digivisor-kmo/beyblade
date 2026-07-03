import Link from "next/link";
import { getUser } from "@/lib/auth";

export async function NavBar() {
  const user = await getUser();

  return (
    <header className="border-b border-[var(--color-border)] bg-[var(--color-surface)]">
      <nav className="mx-auto flex max-w-4xl items-center justify-between px-4 py-3">
        <div className="flex items-center gap-4">
          <Link href="/" className="font-semibold">
            Beyblade X
          </Link>
          <Link
            href="/catalogus"
            className="text-sm text-[var(--color-muted)] hover:text-[var(--color-text)]"
          >
            Catalogus
          </Link>
          <Link
            href="/collectie"
            className="text-sm text-[var(--color-muted)] hover:text-[var(--color-text)]"
          >
            Collectie
          </Link>
        </div>
        <div className="text-sm">
          {user ? (
            <form action="/auth/signout" method="post">
              <button className="text-[var(--color-muted)] hover:text-[var(--color-text)]">
                Uitloggen
              </button>
            </form>
          ) : (
            <Link
              href="/login"
              className="text-[var(--color-muted)] hover:text-[var(--color-text)]"
            >
              Inloggen
            </Link>
          )}
        </div>
      </nav>
    </header>
  );
}
