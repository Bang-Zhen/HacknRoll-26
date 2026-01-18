import { getApiBase } from "./api-base";

export async function apiFetch<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  const apiBase = getApiBase();
  if (!apiBase) {
    const error = new Error(
      "Backend unavailable on GitHub Pages. Run locally or set NEXT_PUBLIC_API_URL.",
    );
    (error as Error & { status?: number }).status = 0;
    throw error;
  }

  const res = await fetch(`${apiBase}${path}`, {
    ...options,
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
  });

  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    const error = new Error(body.error || "Request failed");
    (error as Error & { status?: number }).status = res.status;
    throw error;
  }

  return res.json();
}
