export default function Loading() {
  return (
    <main className="mx-auto max-w-4xl px-4 py-8">
      <div className="h-8 w-40 animate-pulse rounded bg-[var(--color-surface)]" />
      <div className="mt-6 h-9 w-64 animate-pulse rounded bg-[var(--color-surface)]" />
      <ul className="mt-6 grid gap-3 sm:grid-cols-2">
        {Array.from({ length: 6 }).map((_, i) => (
          <li
            key={i}
            className="h-28 animate-pulse rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)]"
          />
        ))}
      </ul>
    </main>
  );
}
