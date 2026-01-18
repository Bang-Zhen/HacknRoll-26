import { spawnSync } from "child_process";
import path from "path";
import {
  resolveRouletteBet as resolveRouletteBetTs,
  type RouletteBet,
  type RouletteResult,
} from "../games/roulette";

const ENGINE = process.env.ROULETTE_RESOLVE_ENGINE || "ts";
const ENGINE_BIN = process.env.ROULETTE_RESOLVE_ENGINE_BIN || "racket";
const ENGINE_SCRIPT =
  process.env.ROULETTE_RESOLVE_ENGINE_SCRIPT ||
  path.join(process.cwd(), "engines", "racket", "roulette_resolve", "resolve.rkt");

type ResolveInput = {
  bet: RouletteBet;
  result: RouletteResult;
  amountMinor: number;
};

type ResolveOutput = {
  won: boolean;
  payoutMinor: number;
};

function runRacket(input: ResolveInput): ResolveOutput | null {
  const result = spawnSync(ENGINE_BIN, [ENGINE_SCRIPT], {
    input: JSON.stringify(input),
    encoding: "utf8",
    maxBuffer: 1024 * 1024,
  });

  if (result.error || result.status !== 0 || !result.stdout) {
    return null;
  }

  try {
    const parsed = JSON.parse(result.stdout) as ResolveOutput;
    if (typeof parsed.won !== "boolean") return null;
    if (typeof parsed.payoutMinor !== "number") return null;
    return parsed;
  } catch {
    return null;
  }
}

export function resolveRouletteBetEngine(
  bet: RouletteBet,
  result: RouletteResult,
  amountMinor: number,
): ResolveOutput {
  if (ENGINE === "racket") {
    const resolved = runRacket({ bet, result, amountMinor });
    if (resolved) return resolved;
  }

  return resolveRouletteBetTs(bet, result, amountMinor);
}
