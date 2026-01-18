"use client";

import { useEffect, useRef, useState } from "react";

type PlinkoMFE = {
  mount: (el: HTMLElement, opts: { groupId: string }) => void;
  unmount?: (el: HTMLElement) => void;
};

declare global {
  interface Window {
    PlinkoMFE?: PlinkoMFE;
  }
}

export function PlinkoHost({
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
      `script[data-plinko-mfe="${scriptUrl}"]`,
    );

    if (!script) {
      script = document.createElement("script");
      script.src = scriptUrl;
      script.async = true;
      script.dataset.plinkoMfe = scriptUrl;
      document.body.appendChild(script);
    }

    function onLoad() {
      if (window.PlinkoMFE && rootRef.current) {
        window.PlinkoMFE.mount(rootRef.current, { groupId });
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
      if (rootRef.current && window.PlinkoMFE?.unmount) {
        window.PlinkoMFE.unmount(rootRef.current);
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
