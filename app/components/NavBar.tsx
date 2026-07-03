import Link from "next/link";
import { getUser } from "@/lib/auth";
import { NavLinks } from "@/app/components/NavLinks";

export async function NavBar() {
  const user = await getUser();

  return (
    <header className="sticky top-0 z-20 border-b border-[var(--color-border)] bg-[var(--color-bg)]/85 backdrop-blur">
      <nav className="mx-auto flex max-w-5xl items-center justify-between gap-3 px-4 py-2.5">
        <div className="flex items-center gap-3">
          <Link href="/" className="group flex items-center gap-2">
            <span
              className="grid h-8 w-8 place-items-center rounded-lg text-sm font-black text-white transition-transform group-hover:rotate-180"
              style={{
                background:
                  "linear-gradient(135deg, var(--color-accent), var(--color-accent-2))",
                boxShadow: "0 4px 14px -4px rgba(61,123,255,0.7)",
              }}
            >
              X
            </span>
            <span className="font-display hidden text-sm font-extrabold tracking-wider sm:inline">
              BEYBLADE X
            </span>
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
