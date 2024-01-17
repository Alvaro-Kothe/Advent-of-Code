const fs = require("fs");

const filename_ = process.argv[2] || "input/day09.txt";
const data = fs
  .readFileSync(filename_)
  .toString()
  .split("\n")
  .filter(Boolean)
  .map(Number);

function verify_sum(arr, index, len_before) {
  const sum_result = arr[index];
  for (let i = index - len_before; i < index; i++)
    for (let j = i + 1; j < index; ++j)
      if (arr[i] + arr[j] === sum_result) return true;
  return false;
}

function get_invalid_number(data) {
  for (let i = 25; i < data.length; i++)
    if (!verify_sum(data, i, 25)) return data[i];
  return -1;
}

function get_contiguous_set(arr, number) {
  let i = 0;
  let n = arr.length;
  for (let i = 0; i < n; i++) {
    let j = i;
    let min = (max = sum = arr[j]);
    while (sum < number) {
      j++;
      const value = arr[j];
      min = value < min ? value : min;
      max = value > max ? value : max;
      sum += value;
      if (sum === number) return min + max;
    }
  }
  return -1;
}

const invalid = get_invalid_number(data);

console.log("Part1: ", invalid);
console.log("Part2: ", get_contiguous_set(data, invalid));
