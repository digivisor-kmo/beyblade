import Link from "next/link";
import { getCatalog } from "@/lib/catalog";
import { getUser } from "@/lib/auth";

export default async function Home() {
  const [catalog, user] = await Promise.all([getCatalog(), getUser()]);

  const stats = [
    { label: "Onderdelen", value: catalog.parts.length },
    { label: "Producten", value: catalog.products.length },
    { label: "Bouwsjablonen", value: catalog.templates.length },
  ];

  return (
    <main className="mx-auto max-w-3xl px-5 py-16">
      <section className="text-center">
        <span className="inline-flex items-center gap-2 rounded-full border border-[var(--color-border)] bg-[var(--color-surface)] px-3 py-1 text-xs text-[var(--color-muted)]">
          <span className="h-1.5 w-1.5 rounded-full bg-[var(--color-accent-2)]" />
          Jouw Beyblade X companion
        </span>

        <h1 className="headline mt-5 text-4xl font-extrabold leading-[1.05] tracking-tight sm:text-6xl">
          BEHEER.
          <br />
          BOUW.
          <br />
          DOMINEER.
        </h1>

        <p className="mx-auto mt-5 max-w-md text-[var(--color-muted)]">
          Houd je collectie bij, ontdek welke combo&apos;s je kunt bouwen en
          stel je tornooi-deck samen.
        </p>

        <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
          <Link
            href={user ? "/collectie" : "/login"}
            className="btn-primary w-full px-6 py-3 sm:w-auto"
          >
            {user ? "Naar mijn collectie" : "Inloggen om te starten"}
          </Link>
          <Link
            href="/catalogus"
            className="btn-ghost w-full px-6 py-3 sm:w-auto"
          >
            Bekijk de catalogus
          </Link>
        </div>
      </section>

      <section className="mt-14 grid grid-cols-3 gap-3">
        {stats.map((s) => (
          <div key={s.label} className="card p-5 text-center">
            <p className="font-display text-3xl font-extrabold text-[var(--color-accent)]">
              {s.value}
            </p>
            <p className="mt-1 text-xs uppercase tracking-wide text-[var(--color-muted)]">
              {s.label}
            </p>
          </div>
        ))}
      </section>

      <div className="mt-8 grid gap-3 sm:grid-cols-3">
        <QuickLink href="/catalogus?tab=producten" title="Catalogus" sub="Blader & voeg toe" />
        <QuickLink href="/builder" title="Bouwer" sub="Bouw je combo" />
        <QuickLink href="/collectie" title="Collectie" sub="Wat heb je al" />
      </div>

      <p className="mt-14 text-center text-xs text-[var(--color-muted)]">
        Data en afbeeldingen: Beyblade Wiki (Fandom), CC-BY-SA.
      </p>
    </main>
  );
}

function QuickLink({
  href,
  title,
  sub,
}: {
  href: string;
  title: string;
  sub: string;
}) {
  return (
    <Link href={href} className="card card-hover flex items-center gap-3 p-4">
      <span
        className="h-9 w-1.5 shrink-0 rounded-full"
        style={{
          background:
            "linear-gradient(180deg, var(--color-accent), var(--color-accent-2))",
        }}
      />
      <span>
        <span className="block text-sm font-semibold">{title}</span>
        <span className="block text-xs text-[var(--color-muted)]">{sub}</span>
      </span>
    </Link>
  );
}
