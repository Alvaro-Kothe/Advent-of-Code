const fs = require("fs");

const filename_ = process.argv[2] || "input/day14.txt";
const data = fs
  .readFileSync(filename_)
  .toString()
  .split("\n")
  .filter(Boolean)
  .map((line) => line.split(" = "));

function initialize(instructions) {
  let maskow = 0n,
    maskkeep = 0n;
  const memory = new Map();
  for (const [command, value] of instructions) {
    if (command === "mask") {
      maskow = 0n;
      maskkeep = 0n;
      for (const ch of value) {
        maskkeep <<= 1n;
        maskow <<= 1n;
        if (ch === "X") maskkeep |= 1n;
        else maskow |= ch === "0" ? 0n : 1n;
      }
    } else {
      const addr = Number(command.match(/\d+/)[0]);
      const num = BigInt(value);
      memory.set(addr, (num & maskkeep) | maskow);
    }
  }
  return memory;
}

function generate_combinations(mask) {
  let out = [];

  function aux(mask, index, current) {
    if (mask === 0n) {
      out.push(current);
      return;
    }
    const bit = mask & 1n;
    const next_mask = mask >> 1n;
    aux(next_mask, index + 1n, current | (bit << index));
    if (bit === 1n) aux(next_mask, index + 1n, current);
  }

  aux(mask, 0n, 0n);
  return out;
}

function part2(instructions) {
  let maskow = 0n,
    maskkeep = 0n,
    maskfloat = 0n;
  const memory = new Map();
  for (const [command, value] of instructions) {
    if (command === "mask") {
      maskow = 0n;
      maskkeep = 0n;
      maskfloat = 0n;
      for (const ch of value) {
        maskkeep <<= 1n;
        maskow <<= 1n;
        maskfloat <<= 1n;
        if (ch === "X") maskfloat |= 1n;
        else if (ch === "0") maskkeep |= 1n;
        else maskow |= 1n;
      }
    } else {
      const addr = BigInt(command.match(/\d+/)[0]);
      const num = BigInt(value);
      let base_addr = (addr & maskkeep) | maskow;
      const combinations = generate_combinations(maskfloat);
      combinations.forEach((combbit) =>
        memory.set(base_addr | (maskfloat & combbit), num),
      );
    }
  }
  let out = 0n;
  for (let v of memory.values()) out += v;

  return out;
}

const memory = initialize(data);
let p1 = 0n;
for (let v of memory.values()) {
  p1 += v;
}
console.log("Part1: ", p1);
console.log("Part2: ", part2(data));
