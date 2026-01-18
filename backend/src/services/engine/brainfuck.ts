type BrainfuckResult = {
  output: number[];
  steps: number;
};

export function runBrainfuck(
  program: string,
  input: number[] = [],
  maxSteps = 100000,
): BrainfuckResult {
  const tape = new Uint8Array(30000);
  let ptr = 0;
  let ip = 0;
  let steps = 0;
  let inputIdx = 0;
  const output: number[] = [];

  const bracketMap = buildBracketMap(program);

  while (ip < program.length && steps < maxSteps) {
    const op = program[ip];
    steps += 1;
    switch (op) {
      case ">":
        ptr = (ptr + 1) % tape.length;
        break;
      case "<":
        ptr = (ptr - 1 + tape.length) % tape.length;
        break;
      case "+":
        tape[ptr] = (tape[ptr] + 1) & 0xff;
        break;
      case "-":
        tape[ptr] = (tape[ptr] - 1) & 0xff;
        break;
      case ".":
        output.push(tape[ptr]);
        break;
      case ",":
        tape[ptr] = inputIdx < input.length ? input[inputIdx] & 0xff : 0;
        inputIdx += 1;
        break;
      case "[":
        if (tape[ptr] === 0) {
          ip = bracketMap.get(ip) ?? ip;
        }
        break;
      case "]":
        if (tape[ptr] !== 0) {
          ip = bracketMap.get(ip) ?? ip;
        }
        break;
      default:
        break;
    }
    ip += 1;
  }

  return { output, steps };
}

function buildBracketMap(program: string) {
  const stack: number[] = [];
  const map = new Map<number, number>();
  for (let i = 0; i < program.length; i += 1) {
    const op = program[i];
    if (op === "[") {
      stack.push(i);
    } else if (op === "]") {
      const start = stack.pop();
      if (start !== undefined) {
        map.set(start, i);
        map.set(i, start);
      }
    }
  }
  return map;
}
