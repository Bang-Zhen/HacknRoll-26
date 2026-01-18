import fs from "fs";
import path from "path";
import { runBrainfuck } from "./brainfuck";
import { type RouletteBet } from "../games/roulette";

const BF_PATH =
  process.env.ROULETTE_MULTIPLIER_BF_PATH ||
  path.join(process.cwd(), "engines", "brainfuck", "roulette", "multiplier.bf");

let cachedProgram: string | null = null;

function getProgram() {
  if (cachedProgram) return cachedProgram;
  try {
    cachedProgram = fs.readFileSync(BF_PATH, "utf8");
    return cachedProgram;
  } catch {
    return null;
  }
}

export function getRouletteMultiplierBrainfuck(bet: RouletteBet): number | null {
  if (bet.betType !== "red" && bet.betType !== "black") {
    return null;
  }

  const program = getProgram();
  if (!program) return null;

  const result = runBrainfuck(program);
  const byte = result.output[0];
  if (typeof byte !== "number") return null;
  return byte;
}
