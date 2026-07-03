export default function Loading() {
  return (
    <main className="mx-auto max-w-3xl px-4 py-8">
      <div className="h-8 w-32 animate-pulse rounded bg-[var(--color-surface)]" />
      <div className="mt-6 h-80 animate-pulse rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)]" />
    </main>
  );
}
