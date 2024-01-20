const fs = require("fs");

const filename_ = process.argv[2] || "input/day00.txt";
const data = fs
  .readFileSync(filename_)
  .toString()
  .split("\n")
  .filter(Boolean)
  .map(Number);

console.log("Part1: ", -1);
console.log("Part2: ", -1);
