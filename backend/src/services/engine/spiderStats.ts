import { spawnSync } from "child_process";
import path from "path";

type TxInput = {
  amountMinor: number;
  type: string;
  meta: unknown;
};

type SpiderAxis = { key: string; label: string; value: number };

type SpiderOutput = {
  axes: SpiderAxis[];
  raw: {
    totalBetMinor: number;
    totalWonMinor: number;
    transferCount: number;
    uniqueGameTypes: string[];
    txCount: number;
  };
};

const ENGINE = process.env.SPIDER_ENGINE || "ts";
const ENGINE_BIN = process.env.SPIDER_ENGINE_BIN || "Rscript";
const ENGINE_SCRIPT =
  process.env.SPIDER_ENGINE_SCRIPT ||
  path.join(process.cwd(), "engines", "r", "spider", "stats.R");

function runR(input: { txs: TxInput[]; startCreditsMinor: number }): SpiderOutput | null {
  const result = spawnSync(ENGINE_BIN, [ENGINE_SCRIPT], {
    input: JSON.stringify(input),
    encoding: "utf8",
    maxBuffer: 1024 * 1024,
  });

  if (result.error || result.status !== 0 || !result.stdout) {
    return null;
  }

  try {
    const parsed = JSON.parse(result.stdout) as SpiderOutput;
    if (!parsed || !Array.isArray(parsed.axes) || !parsed.raw) return null;
    return parsed;
  } catch {
    return null;
  }
}

export function computeSpiderStatsEngine(input: {
  txs: TxInput[];
  startCreditsMinor: number;
}): SpiderOutput | null {
  if (ENGINE === "r") {
    const result = runR(input);
    if (result) return result;
  }

  return null;
}
