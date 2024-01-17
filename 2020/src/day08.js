const fs = require("fs");

const data = fs
  .readFileSync("input/day08.txt")
  .toString()
  .split("\n")
  .filter(Boolean)
  .map((x) => x.split(" "));

let accumulator = 0;
let seen_index = [];

let cur_idx = 0;
while (!seen_index.includes(cur_idx)) {
  let [operation, arg] = data[cur_idx];
  arg = Number(arg);
  seen_index.push(cur_idx);

  switch (operation) {
    case "nop":
      cur_idx++;
      break;
    case "acc":
      accumulator += arg;
      cur_idx++;
      break;
    case "jmp":
      cur_idx += arg;
      break;
  }
}
console.log(accumulator);

let possible_change = [];

for (let i = 0; i < data.length; i++) {
  if (data[i][0] != "acc") {
    const op_change = data[i][0] === "nop" ? "jmp" : "nop";
    possible_change.push([i, op_change]);
  }
}

let accumulator2;
change: for (const [idx_change, op_change] of possible_change) {
  let seen_index = [];
  accumulator2 = 0;
  let cur_idx = 0;

  while (!seen_index.includes(cur_idx)) {
    let [operation, arg] = data[cur_idx];
    if (cur_idx === idx_change) operation = op_change;
    arg = Number(arg);
    seen_index.push(cur_idx);

    switch (operation) {
      case "nop":
        cur_idx++;
        break;
      case "acc":
        accumulator2 += arg;
        cur_idx++;
        break;
      case "jmp":
        cur_idx += arg;
        break;
    }

    if (cur_idx === data.length) break change;
  }
}

console.log(accumulator2);
