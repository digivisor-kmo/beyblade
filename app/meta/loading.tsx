export default function Loading() {
  return (
    <main className="mx-auto max-w-3xl px-4 py-8">
      <div className="h-8 w-52 animate-pulse rounded bg-[var(--color-surface)]" />
      <div className="mt-8 space-y-3">
        {Array.from({ length: 4 }).map((_, i) => (
          <div
            key={i}
            className="h-28 animate-pulse rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)]"
          />
        ))}
      </div>
    </main>
  );
}
