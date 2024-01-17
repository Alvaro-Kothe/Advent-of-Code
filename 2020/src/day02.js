const fs = require("fs");

const data = fs
  .readFileSync("input/day02.txt")
  .toString()
  .split("\n")
  .filter(Boolean);

// Part 1
let valid = 0;
let valid2 = 0;

re = /(\d+)-(\d+) (\w): (.+)/;
for (let i = 0; i < data.length; i++) {
  const line = data[i];
  let [_, min, max, ch, pass] = line.match(re);
  min = Number(min);
  max = Number(max);
  const ch_occurrences = (pass.match(RegExp(ch, "g")) || []).length;
  if (min <= ch_occurrences && ch_occurrences <= max) {
    valid += 1;
  }

  if ((pass[min - 1] == ch) ^ (pass[max - 1] == ch)) {
    valid2 += 1;
  }
}

console.log(valid);
console.log(valid2);
