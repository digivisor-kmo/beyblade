import { redirect } from "next/navigation";
import { getUser } from "@/lib/auth";
import { SignInButton } from "@/app/components/SignInButton";

export default async function LoginPage() {
  const user = await getUser();
  if (user) redirect("/collectie");

  return (
    <main className="mx-auto flex max-w-md flex-col items-center px-6 py-24 text-center">
      <h1 className="text-2xl font-bold">Inloggen</h1>
      <p className="mt-2 text-sm text-[var(--color-muted)]">
        Log in om je collectie en builds te beheren.
      </p>
      <div className="mt-8">
        <SignInButton />
      </div>
    </main>
  );
}
