const DEFAULT_API_BASE = "http://localhost:4000";

function isGithubPagesHost() {
  if (typeof window === "undefined") return false;
  return window.location.hostname.endsWith("github.io");
}

export function isStaticDemo() {
  return !process.env.NEXT_PUBLIC_API_URL && isGithubPagesHost();
}

export function getApiBase() {
  if (process.env.NEXT_PUBLIC_API_URL) {
    return process.env.NEXT_PUBLIC_API_URL;
  }
  if (isGithubPagesHost()) {
    return null;
  }
  return DEFAULT_API_BASE;
}
