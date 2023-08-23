const fs = require("fs");
const { argv0 } = require("process");

function partition(zone, lower, upper) {
  const middle = (lower + upper) / 2;
  if (zone == "F" || zone == "L") {
    return [lower, Math.floor(middle)];
  }
  return [Math.ceil(middle), upper];
}

const data = fs
  .readFileSync("input.txt")
  .toString()
  .split("\n")
  .filter(Boolean);

let max_id = 0;

const reRow = /[FB]/g;
const reCol = /[RL]/g;

let missing_seats = new Set();
for (let i = 10; i < 117; i++) {
  for (let j = 0; j < 7; j++) {
    missing_seats.add(i * 8 + j);
  }
}

for (let i = 0; i < data.length; i++) {
  const seat = data[i];
  let [lower, upper] = [0, 127];

  while ((m = reRow.exec(seat)) !== null) {
    [lower, upper] = partition(m[0], lower, upper);
  }
  const row = lower;

  lower = 0;
  upper = 7;

  while ((m = reCol.exec(seat)) !== null) {
    [lower, upper] = partition(m[0], lower, upper);
  }
  const col = lower;

  const seat_id = row * 8 + col;

  missing_seats.delete(seat_id);

  max_id = Math.max(max_id, seat_id);
}
console.log(max_id);
console.log(missing_seats);
