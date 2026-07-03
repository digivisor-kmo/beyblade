"use client";

import Link from "next/link";
import { useMemo, useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { createBuild } from "@/app/actions/builds";
import { Thumb, Badge } from "@/app/components/ui";

type Template = {
  id: string;
  name: string;
  line: string;
  subtype: string;
  allows_integrated_bit: boolean;
};
type Slot = { template_id: string; category: string; min_quantity: number };
type OwnedPart = {
  partId: string;
  name: string;
  category: string;
  line: string;
  image: string | null;
};

const UNIVERSAL = new Set(["ratchet", "bit", "ratchet_integrated_bit"]);

export function BuilderClient({
  templates,
  templateSlots,
  categoryName,
  ownedParts,
}: {
  templates: Template[];
  templateSlots: Slot[];
  categoryName: Record<string, string>;
  ownedParts: OwnedPart[];
}) {
  const router = useRouter();
  const [templateId, setTemplateId] = useState(templates[0]?.id ?? "");
  const [assignments, setAssignments] = useState<Record<string, string>>({});
  const [name, setName] = useState("");
  const [pending, start] = useTransition();
  const [message, setMessage] = useState<{ ok: boolean; text: string } | null>(
    null,
  );

  const template = templates.find((t) => t.id === templateId);
  const slots = useMemo(
    () => templateSlots.filter((s) => s.template_id === templateId),
    [templateSlots, templateId],
  );

  const partsFor = (category: string) =>
    ownedParts.filter(
      (p) =>
        p.category === category &&
        (UNIVERSAL.has(category) || !template || p.line === template.line),
    );

  const partById = (id: string) => ownedParts.find((p) => p.partId === id);

  const requiredCats = slots
    .filter((s) => s.min_quantity > 0)
    .map((s) => s.category);
  const missing = requiredCats.filter((c) => !assignments[c]);
  const complete = missing.length === 0 && requiredCats.length > 0;

  const pickTemplate = (id: string) => {
    setTemplateId(id);
    setAssignments({});
    setMessage(null);
  };

  const save = () =>
    start(async () => {
      setMessage(null);
      const res = await createBuild({
        templateId,
        name,
        assignments: slots
          .filter((s) => assignments[s.category])
          .map((s) => ({ category: s.category, partId: assignments[s.category] })),
      });
      if ("error" in res) {
        setMessage({ ok: false, text: res.error });
      } else {
        setMessage({ ok: true, text: `"${name}" opgeslagen.` });
        setName("");
        setAssignments({});
        router.refresh();
      }
    });

  const selectClass =
    "w-full rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-2)] px-3 py-2 text-sm";

  return (
    <div className="card p-4">
      {/* Sjabloonkeuze */}
      <p className="text-sm font-semibold">1. Kies een type bey</p>
      <div className="mt-2 flex flex-wrap gap-2">
        {templates.map((t) => (
          <button
            key={t.id}
            onClick={() => pickTemplate(t.id)}
            className={`rounded-lg border px-3 py-1.5 text-sm ${
              t.id === templateId
                ? "border-[var(--color-accent)] bg-[var(--color-surface-2)]"
                : "border-[var(--color-border)] text-[var(--color-muted)]"
            }`}
          >
            {t.name}
          </button>
        ))}
      </div>

      {/* Slots */}
      <p className="mt-6 text-sm font-semibold">2. Vul je onderdelen in</p>
      <div className="mt-2 space-y-3">
        {slots.map((s) => {
          const options = partsFor(s.category);
          const selected = assignments[s.category]
            ? partById(assignments[s.category])
            : undefined;
          return (
            <div key={s.category} className="flex items-center gap-3">
              <Thumb
                src={selected?.image ?? null}
                alt={selected?.name ?? ""}
                className="h-12 w-12 shrink-0"
              />
              <div className="min-w-0 flex-1">
                <label className="text-xs text-[var(--color-muted)]">
                  {categoryName[s.category] ?? s.category}
                </label>
                {options.length === 0 ? (
                  <p className="text-sm">
                    <span className="text-[var(--color-muted)]">
                      Nog geen {categoryName[s.category] ?? s.category} in je
                      collectie.{" "}
                    </span>
                    <Link href="/catalogus" className="text-[var(--color-accent)]">
                      Toevoegen
                    </Link>
                  </p>
                ) : (
                  <select
                    value={assignments[s.category] ?? ""}
                    onChange={(e) =>
                      setAssignments((a) => ({
                        ...a,
                        [s.category]: e.target.value,
                      }))
                    }
                    className={selectClass}
                  >
                    <option value="">Kies...</option>
                    {options.map((p) => (
                      <option key={p.partId} value={p.partId}>
                        {p.name}
                      </option>
                    ))}
                  </select>
                )}
              </div>
            </div>
          );
        })}
      </div>

      {/* Validatie */}
      <div className="mt-5 rounded-lg border border-[var(--color-border)] p-3 text-sm">
        {complete ? (
          <p className="font-medium text-[var(--color-stamina)]">
            ✓ Compleet, klaar om op te slaan
          </p>
        ) : (
          <p className="text-[var(--color-muted)]">
            Nog nodig:{" "}
            {missing.map((c) => categoryName[c] ?? c).join(", ") || "-"}
          </p>
        )}
      </div>

      {/* Opslaan */}
      <div className="mt-4 flex flex-col gap-2 sm:flex-row">
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="Naam van je build"
          className={selectClass + " flex-1"}
        />
        <button
          onClick={save}
          disabled={!complete || !name.trim() || pending}
          className="btn-primary px-5 py-2 text-sm disabled:opacity-50"
        >
          {pending ? "Opslaan..." : "Build opslaan"}
        </button>
      </div>
      {message && (
        <p
          className={`mt-2 text-sm ${
            message.ok ? "text-[var(--color-stamina)]" : "text-red-400"
          }`}
        >
          {message.text}
        </p>
      )}
    </div>
  );
}
