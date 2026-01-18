import { spawnSync } from "child_process";
import path from "path";

const ENGINE = process.env.DIAG_ENGINE || "none";

const GO_BIN =
  process.env.DIAG_GO_BIN || path.join(process.cwd(), "engines", "go", "diag", "diag");
const RUST_BIN =
  process.env.DIAG_RUST_BIN || path.join(process.cwd(), "engines", "rust", "diag", "diag");

const ELIXIR_BIN = process.env.DIAG_ELIXIR_BIN || "elixir";
const ELIXIR_SCRIPT =
  process.env.DIAG_ELIXIR_SCRIPT ||
  path.join(process.cwd(), "engines", "elixir", "diag", "diag.exs");

const TCL_BIN = process.env.DIAG_TCL_BIN || "tclsh";
const TCL_SCRIPT =
  process.env.DIAG_TCL_SCRIPT || path.join(process.cwd(), "engines", "tcl", "diag", "diag.tcl");

const SCHEME_BIN = process.env.DIAG_SCHEME_BIN || "guile";
const SCHEME_SCRIPT =
  process.env.DIAG_SCHEME_SCRIPT ||
  path.join(process.cwd(), "engines", "scheme", "diag", "diag.scm");

function run(bin: string, args: string[] = []) {
  const result = spawnSync(bin, args, {
    encoding: "utf8",
    maxBuffer: 1024 * 1024,
  });
  if (result.error || result.status !== 0 || !result.stdout) {
    return null;
  }
  try {
    const parsed = JSON.parse(result.stdout) as { diag?: string };
    if (typeof parsed.diag !== "string") return null;
    return parsed.diag;
  } catch {
    return null;
  }
}

function resolveBin(bin: string) {
  if (process.platform === "win32" && !bin.endsWith(".exe")) {
    return `${bin}.exe`;
  }
  return bin;
}

export function getDiag(): string | null {
  if (ENGINE === "go") {
    return run(resolveBin(GO_BIN));
  }
  if (ENGINE === "rust") {
    return run(resolveBin(RUST_BIN));
  }
  if (ENGINE === "elixir") {
    return run(ELIXIR_BIN, [ELIXIR_SCRIPT]);
  }
  if (ENGINE === "tcl") {
    return run(TCL_BIN, [TCL_SCRIPT]);
  }
  if (ENGINE === "scheme") {
    return run(SCHEME_BIN, [SCHEME_SCRIPT]);
  }
  return null;
}
