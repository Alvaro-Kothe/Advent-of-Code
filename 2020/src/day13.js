const fs = require("fs");

const filename_ = process.argv[2] || "input/day13.txt";
const data = fs.readFileSync(filename_).toString().split("\n").filter(Boolean);
const timestamp = +data[0];
const busid = data[1].split(",");

function modinv(a, m) {
  let [old_r, r] = [a, m];
  let [old_s, s] = [1n, 0n];
  let [old_t, t] = [0n, 1n];

  while (r != 0) {
    const quotient = old_r / r;
    [old_r, r] = [r, old_r - quotient * r];
    [old_s, s] = [s, old_s - quotient * s];
    [old_t, t] = [t, old_t - quotient * t];
  }
  if (old_r != 1) {
    throw new Error(
      "The modular inverse does not exist because 'a' and 'm' are not coprime.",
    );
  }

  // Ensure the result is positive
  const result = ((old_s % m) + m) % m;

  return result;
}

function get_next_bus_time(start_time, cooldown) {
  const bus_rep = Math.ceil(start_time / cooldown);
  return bus_rep * cooldown;
}

function part1(timestamp, ids) {
  let out = -1;
  let min_await = timestamp;
  for (let id of ids) {
    if (id === "x") continue;
    let id_num = Number(id);
    const await_time = get_next_bus_time(timestamp, id_num) - timestamp;
    if (await_time < min_await) {
      min_await = await_time;
      out = id_num * min_await;
    }
  }
  return out;
}

function chinese_remainder(num, rem) {
  let sum = 0n;
  const prod = num.reduce((a, c) => a * c);
  for (let i = 0; i < num.length; i++) {
    const [n, r] = [num[i], rem[i]];
    const p = prod / n;
    const minv = modinv(p, n);
    sum += r * p * minv;
  }
  return sum % prod;
}

/**
 * Chinese remainder theorem
 * Find a solution that solves the system:
 * read (=) as congruent
 * t = -k (mod id_k)
 * t = id_k - k (mod id_k)
 * */
function part2(ids) {
  let num = [],
    rem = [];
  for (let offset = 0; offset < ids.length; offset++) {
    const id = ids[offset];
    if (id === "x") continue;
    let bus_num = Number(id);
    num.push(BigInt(bus_num));
    rem.push(BigInt((bus_num - offset) % bus_num));
  }
  return chinese_remainder(num, rem);
}

console.log("Part1: ", part1(timestamp, busid));
console.log("Part2: ", part2(busid));
