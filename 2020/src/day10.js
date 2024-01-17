const fs = require("fs");

const filename_ = process.argv[2] || "input/day10.txt";
const data = fs
  .readFileSync(filename_)
  .toString()
  .split("\n")
  .filter(Boolean)
  .map(Number);

function compareNumbers(a, b) {
  return a - b;
}

function part1(arr_ref) {
  let arr = arr_ref.slice();
  arr.sort(compareNumbers);
  arr.unshift(0);
  let diff1 = 0,
    diff3 = 1;
  for (let i = 0; i < arr.length - 1; i++) {
    let dif = arr[i + 1] - arr[i];
    if (dif === 1) diff1++;
    else if (dif === 3) diff3++;
  }
  return diff1 * diff3;
}

function count_arrangements(arr_ref) {
  let arr = arr_ref.slice();
  arr.sort(compareNumbers);
  const max_value = arr.at(-1);
  arr.unshift(0);
  arr.push(max_value + 3);
  let cache = {};
  cache[arr.length - 1] = 1;

  function aux(i) {
    const cached_value = cache[i];
    if (cached_value !== undefined) return cached_value;
    let result = 0;
    let j = i + 1;
    while (j < arr.length && arr[j] - arr[i] <= 3) {
      result += aux(j);
      j++;
    }
    cache[i] = result;
    return result;
  }
  return aux(0);
}

console.log("Part1: ", part1(data));
console.log("Part2: ", count_arrangements(data));
