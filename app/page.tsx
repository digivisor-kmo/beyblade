import Link from "next/link";
import { getCatalog } from "@/lib/catalog";
import { getUser } from "@/lib/auth";

export default async function Home() {
  const [catalog, user] = await Promise.all([getCatalog(), getUser()]);

  const stats = [
    { label: "Onderdelen", value: catalog.parts.length },
    { label: "Producten", value: catalog.products.length },
    { label: "Kleurvarianten", value: catalog.variants.length },
  ];

  return (
    <main className="mx-auto max-w-3xl px-5 py-14">
      <section className="text-center">
        <span className="inline-block rounded-full border border-[var(--color-border)] bg-[var(--color-surface)] px-3 py-1 text-xs text-[var(--color-muted)]">
          Jouw Beyblade X companion
        </span>
        <h1 className="mt-4 text-4xl font-black tracking-tight sm:text-5xl">
          Beheer je collectie.
          <br />
          <span className="text-[var(--color-accent)]">Bouw je beys.</span>
        </h1>
        <p className="mx-auto mt-4 max-w-md text-[var(--color-muted)]">
          Houd bij welke onderdelen je hebt, ontdek welke combo&apos;s je kunt
          bouwen en stel je tornooi-deck samen.
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
            className="card card-hover w-full px-6 py-3 font-semibold sm:w-auto"
          >
            Bekijk de catalogus
          </Link>
        </div>
      </section>

      <section className="mt-14 grid grid-cols-3 gap-3">
        {stats.map((s) => (
          <div key={s.label} className="card p-4 text-center">
            <p className="text-3xl font-black text-[var(--color-accent)]">
              {s.value}
            </p>
            <p className="mt-1 text-xs text-[var(--color-muted)]">{s.label}</p>
          </div>
        ))}
      </section>

      <p className="mt-14 text-center text-xs text-[var(--color-muted)]">
        Data en afbeeldingen: Beyblade Wiki (Fandom), CC-BY-SA.
      </p>
    </main>
  );
}
