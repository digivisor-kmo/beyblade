export default function Loading() {
  return (
    <main className="mx-auto max-w-4xl px-4 py-8">
      <div className="h-8 w-48 animate-pulse rounded bg-[var(--color-surface)]" />
      <div className="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <div
            key={i}
            className="h-16 animate-pulse rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)]"
          />
        ))}
      </div>
      <div className="mt-8 space-y-3">
        {Array.from({ length: 3 }).map((_, i) => (
          <div
            key={i}
            className="h-24 animate-pulse rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)]"
          />
        ))}
      </div>
    </main>
  );
}
