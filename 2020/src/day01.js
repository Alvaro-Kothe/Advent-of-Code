const fs = require("fs");

const data = fs
  .readFileSync("input/day01.txt")
  .toString()
  .split("\n")
  .filter(Boolean)
  .map(Number);
const result_sum = 2020;
const do_part2 = true;

for (let i = 0; i < data.length; i++) {
  const x1 = data[i];
  for (let j = i + 1; j < data.length; j++) {
    const x2 = data[j];
    // Part 1
    x1 + x2 === result_sum && console.log("Part 1: %d", x1 * x2);
    if (do_part2) {
      for (let k = j + 1; k < data.length; k++) {
        const x3 = data[k];
        // Part 2
        x1 + x2 + x3 === result_sum && console.log("Part 2: %d", x1 * x2 * x3);
      }
    }
  }
}
