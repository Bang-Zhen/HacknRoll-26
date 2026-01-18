"use client";

import { useEffect, useRef, useState } from "react";

type MinesMFE = {
  mount: (el: HTMLElement, opts: { groupId: string }) => void;
  unmount?: (el: HTMLElement) => void;
};

declare global {
  interface Window {
    MinesMFE?: MinesMFE;
  }
}

export function MinesHost({
  groupId,
  scriptUrl,
}: {
  groupId: string;
  scriptUrl: string;
}) {
  const rootRef = useRef<HTMLDivElement | null>(null);
  const [ready, setReady] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let script: HTMLScriptElement | null = document.querySelector(
      `script[data-mines-mfe="${scriptUrl}"]`,
    );

    if (!script) {
      script = document.createElement("script");
      script.src = scriptUrl;
      script.async = true;
      script.dataset.minesMfe = scriptUrl;
      document.body.appendChild(script);
    }

    function onLoad() {
      if (window.MinesMFE && rootRef.current) {
        window.MinesMFE.mount(rootRef.current, { groupId });
        setReady(true);
      } else {
        setError("Microfrontend did not register.");
      }
    }

    function onError() {
      setError("Failed to load microfrontend.");
    }

    script.addEventListener("load", onLoad);
    script.addEventListener("error", onError);

    return () => {
      script?.removeEventListener("load", onLoad);
      script?.removeEventListener("error", onError);
      if (rootRef.current && window.MinesMFE?.unmount) {
        window.MinesMFE.unmount(rootRef.current);
      }
    };
  }, [groupId, scriptUrl]);

  if (error) {
    return <p className="text-sm text-destructive">{error}</p>;
  }

  return (
    <div>
      {!ready ? <p className="text-sm text-muted-foreground">Loading…</p> : null}
      <div ref={rootRef} />
    </div>
  );
}
