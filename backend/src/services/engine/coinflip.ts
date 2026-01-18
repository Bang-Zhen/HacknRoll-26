import { spawnSync } from "child_process";
import path from "path";
import { playCoinflip as playCoinflipTs, type CoinflipResult } from "../games/coinflip";

type CoinflipChoice = "heads" | "tails";

const ENGINE = process.env.COINFLIP_ENGINE || "ts";
const ZIG_BIN =
  process.env.COINFLIP_ENGINE_BIN ||
  path.join(process.cwd(), "engines", "zig", "coinflip", "coinflip");
const JANET_BIN = process.env.COINFLIP_JANET_BIN || "janet";
const JANET_SCRIPT =
  process.env.COINFLIP_JANET_SCRIPT ||
  path.join(process.cwd(), "engines", "janet", "coinflip", "coinflip.janet");

function resolveZigBin() {
  if (process.platform === "win32" && !ZIG_BIN.endsWith(".exe")) {
    return `${ZIG_BIN}.exe`;
  }
  return ZIG_BIN;
}

function runZig(choice: CoinflipChoice, betMinor: number): CoinflipResult | null {
  const bin = resolveZigBin();
  const payload = JSON.stringify({ choice, betMinor });
  const result = spawnSync(bin, [], {
    input: payload,
    encoding: "utf8",
    maxBuffer: 1024 * 1024,
  });

  if (result.error || result.status !== 0 || !result.stdout) {
    return null;
  }

  try {
    const parsed = JSON.parse(result.stdout) as CoinflipResult;
    if (parsed.result !== "heads" && parsed.result !== "tails") return null;
    if (typeof parsed.won !== "boolean") return null;
    if (typeof parsed.payoutMinor !== "number") return null;
    return parsed;
  } catch {
    return null;
  }
}

function runJanet(choice: CoinflipChoice, betMinor: number): CoinflipResult | null {
  const payload = JSON.stringify({ choice, betMinor });
  const result = spawnSync(JANET_BIN, [JANET_SCRIPT], {
    input: payload,
    encoding: "utf8",
    maxBuffer: 1024 * 1024,
  });

  if (result.error || result.status !== 0 || !result.stdout) {
    return null;
  }

  try {
    const parsed = JSON.parse(result.stdout) as CoinflipResult;
    if (parsed.result !== "heads" && parsed.result !== "tails") return null;
    if (typeof parsed.won !== "boolean") return null;
    if (typeof parsed.payoutMinor !== "number") return null;
    return parsed;
  } catch {
    return null;
  }
}

export function playCoinflipEngine(choice: CoinflipChoice, betMinor: number): CoinflipResult {
  if (ENGINE === "zig") {
    const result = runZig(choice, betMinor);
    if (result) return result;
  }

  if (ENGINE === "janet") {
    const result = runJanet(choice, betMinor);
    if (result) return result;
  }

  return playCoinflipTs(choice, betMinor);
}
