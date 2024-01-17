const fs = require("fs");

const data = fs
  .readFileSync("input/day03.txt")
  .toString()
  .split("\n")
  .filter(Boolean);

const slopes = [
  [1, 1],
  [3, 1],
  [5, 1],
  [7, 1],
  [1, 2],
];
let prod = 1;

for (let i = 0; i < slopes.length; i++) {
  const slope = slopes[i];
  let ntrees = 0;
  let row = 0;
  let col = 0;

  while (row < data.length - 1) {
    row += slope[1];
    col = (col + slope[0]) % data[row].length;
    if (data[row][col] == "#") {
      ntrees += 1;
    }
  }
  prod *= ntrees;

  if (slope[0] === 3 && slope[1] === 1) console.log("Part1: ", ntrees);
}
console.log("Part2: ", prod);
