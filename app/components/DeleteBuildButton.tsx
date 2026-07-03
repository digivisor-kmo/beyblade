"use client";

import { useTransition } from "react";
import { useRouter } from "next/navigation";
import { deleteBuild } from "@/app/actions/builds";

export function DeleteBuildButton({ buildId }: { buildId: string }) {
  const router = useRouter();
  const [pending, start] = useTransition();

  return (
    <button
      onClick={() =>
        start(async () => {
          await deleteBuild(buildId);
          router.refresh();
        })
      }
      disabled={pending}
      className="text-xs text-[var(--color-muted)] hover:text-red-400 disabled:opacity-50"
    >
      {pending ? "..." : "Verwijderen"}
    </button>
  );
}
