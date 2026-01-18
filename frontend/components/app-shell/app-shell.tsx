"use client";

import { type PropsWithChildren, useEffect, useState } from "react";
import { TopBar } from "./top-bar";
import { isStaticDemo } from "../../lib/api-base";

export function AppShell({ children }: PropsWithChildren) {
  const [showStaticNotice, setShowStaticNotice] = useState(false);

  useEffect(() => {
    setShowStaticNotice(isStaticDemo());
  }, []);

  return (
    <div className="min-h-screen bg-background flex flex-col">
      <TopBar />
      {showStaticNotice ? (
        <div className="border-b border-border bg-surface-elevated px-4 py-3 text-sm text-muted-foreground">
          GitHub Pages is a static demo. Buttons that need the backend won&apos;t
          work unless you run it locally or set `NEXT_PUBLIC_API_URL`.
        </div>
      ) : null}
      <main className="flex-1 overflow-y-auto overflow-x-hidden p-6">
        <div className="mx-auto w-full max-w-6xl">{children}</div>
      </main>
      <footer className="border-t border-border py-3 px-4 bg-surface">
        <p className="text-xs text-muted text-center">
          18+ Only • Virtual credits for entertainment purposes only • No real money • Play responsibly
        </p>
      </footer>
    </div>
  );
}

