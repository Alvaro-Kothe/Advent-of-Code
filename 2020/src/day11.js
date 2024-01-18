const fs = require("fs");

const filename_ = process.argv[2] || "input/day11.txt";
const data = fs
  .readFileSync(filename_)
  .toString()
  .split("\n")
  .filter(Boolean)
  .map((str) => str.split(""));

const DIRECTIONS = [
  [-1, -1],
  [-1, 0],
  [-1, 1],
  [0, -1],
  [0, 1],
  [1, -1],
  [1, 0],
  [1, 1],
];

function count_occupied(arr, x, y) {
  let nrow = arr.length;
  let ncol = arr[0].length;

  let out = 0;
  for (let [dx, dy] of DIRECTIONS) {
    if (
      x + dx >= 0 &&
      x + dx < nrow &&
      y + dy >= 0 &&
      y + dy < ncol &&
      arr[x + dx][y + dy] === "#"
    )
      out++;
  }
  return out;
}

function apply_round(arr, count_fn = count_occupied, limit_occupied = 4) {
  let array_copy = new Array(arr.length);
  for (let i = 0; i < arr.length; i++) array_copy[i] = arr[i].slice();

  let changed = false;
  for (let i = 0; i < arr.length; i++)
    for (let j = 0; j < arr[0].length; j++) {
      if (array_copy[i][j] === ".") continue;
      const n_occupied = count_fn(array_copy, i, j);
      if (array_copy[i][j] === "L" && n_occupied === 0) {
        arr[i][j] = "#";
        changed = true;
      } else if (array_copy[i][j] === "#" && n_occupied >= limit_occupied) {
        arr[i][j] = "L";
        changed = true;
      }
    }
  return changed;
}

function part1(arr) {
  let array_copy = new Array(arr.length);
  for (let i = 0; i < arr.length; i++) array_copy[i] = arr[i].slice();
  while (apply_round(array_copy));

  let ans = 0;
  for (let row of array_copy) for (let seat of row) if (seat === "#") ans++;
  return ans;
}

function count_occupied_v2(arr, x, y) {
  let nrow = arr.length;
  let ncol = arr[0].length;

  let out = 0;
  for (let [dx_, dy_] of DIRECTIONS) {
    let [dx, dy] = [dx_, dy_];
    while (
      x + dx >= 0 &&
      x + dx < nrow &&
      y + dy >= 0 &&
      y + dy < ncol &&
      arr[x + dx][y + dy] === "."
    ) {
      dx += dx_;
      dy += dy_;
    }
    if (
      x + dx >= 0 &&
      x + dx < nrow &&
      y + dy >= 0 &&
      y + dy < ncol &&
      arr[x + dx][y + dy] === "#"
    )
      out++;
  }
  return out;
}

function part2(arr) {
  let array_copy = new Array(arr.length);
  for (let i = 0; i < arr.length; i++) array_copy[i] = arr[i].slice();
  while (apply_round(array_copy, count_occupied_v2, 5));

  let ans = 0;
  for (let row of array_copy) for (let seat of row) if (seat === "#") ans++;
  return ans;
}

console.log("Part1: ", part1(data));
console.log("Part2: ", part2(data));
