const fs = require("fs");

const filename_ = process.argv[2] || "input/day25.txt";
const data = fs
  .readFileSync(filename_)
  .toString()
  .split("\n")
  .filter(Boolean)
  .map(Number);

const MOD = 20201227;
const MAX_ITERATIONS = 0xffffff;

function modpower(base, exp, m) {
  if (base <= 1 || exp <= 0 || m <= 0) return 1;
  let out = 1;
  while (exp > 0) {
    if (exp & 1) out = (out * base) % m;
    base = (base * base) % m;
    exp >>= 1;
  }
  return out;
}

function tsn(num, loop_size) {
  return modpower(num, loop_size, MOD);
}

function get_loop_size(num) {
  for (let i = 1; i <= MAX_ITERATIONS; i++) {
    if (tsn(7, i) === num) return i;
  }
  throw new Error("Loop size not found");
}

const card_pub = data[0],
  door_pub = data[1];
const card_loop_size = get_loop_size(card_pub);
const encryption_key = tsn(door_pub, card_loop_size);

console.log("Part1: ", encryption_key);
