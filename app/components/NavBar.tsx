import Link from "next/link";
import { getUser } from "@/lib/auth";
import { NavLinks } from "@/app/components/NavLinks";

export async function NavBar() {
  const user = await getUser();

  return (
    <header className="sticky top-0 z-20 border-b border-[var(--color-border)] bg-[var(--color-bg)]/85 backdrop-blur">
      <nav className="mx-auto flex max-w-5xl items-center justify-between gap-3 px-4 py-2.5">
        <div className="flex items-center gap-3">
          <Link href="/" className="flex items-center gap-2">
            <span className="grid h-7 w-7 place-items-center rounded-lg bg-[var(--color-accent)] text-sm font-black text-white">
              X
            </span>
            <span className="hidden font-bold sm:inline">Beyblade X</span>
          </Link>
          <NavLinks />
        </div>
        <div className="text-sm">
          {user ? (
            <form action="/auth/signout" method="post">
              <button className="rounded-lg px-3 py-1.5 text-[var(--color-muted)] hover:text-[var(--color-text)]">
                Uitloggen
              </button>
            </form>
          ) : (
            <Link
              href="/login"
              className="btn-primary px-3 py-1.5 text-sm"
            >
              Inloggen
            </Link>
          )}
        </div>
      </nav>
    </header>
  );
}
