const fs = require("fs");

const data = [18, 8, 0, 5, 4, 1, 20];
// const data = [0, 3, 6];

function get_nth_number(arr, n) {
  let last_number, prev_age;
  const number_history = new Map();
  let age = 0;
  for (; age < arr.length; ++age) {
    last_number = arr[age];
    number_history.set(last_number, age);
    prev_age = age;
  }
  while (age < n) {
    last_number = age - prev_age - 1;
    prev_age = number_history.get(last_number);
    if (prev_age === undefined) prev_age = age;
    number_history.set(last_number, age);
    age++;
  }
  return last_number;
}

console.log("Part1: ", get_nth_number(data, 2020));
console.log("Part2: ", get_nth_number(data, 30000000));
