const fs = require("fs");

const filename_ = process.argv[2] || "input/day17.txt";
const data = fs.readFileSync(filename_).toString().split("\n").filter(Boolean);

let initial_state = [];
for (let i = 0; i < data.length; i++) {
  for (let j = 0; j < data[i].length; j++) {
    if (data[i][j] === "#") initial_state.push([i, j]);
  }
}

function* get_neighbors(coord) {
  function* generate(cur, rem) {
    if (rem.length === 0) {
      if (!cur.every((val, i) => val === coord[i])) yield [...cur];
      return;
    }
    const curd = rem[0];
    const rest = rem.slice(1);

    for (let i = -1; i <= 1; i++) {
      const adjv = curd + i;
      cur.push(adjv);
      yield* generate(cur, rest);
      cur.pop();
    }
  }
  yield* generate([], coord);
}

function count_active(active_coords, coord) {
  let out = 0;
  for (let neighbor of get_neighbors(coord))
    out += active_coords.has(JSON.stringify(neighbor));
  return out;
}

function* get_all_neighbors(active_coords) {
  for (const coord of active_coords) yield* get_neighbors(coord);
}

function cycle(active_coords) {
  let new_active = new Set();
  const active_coords_nd = Array.from(active_coords).map(JSON.parse);
  for (const coord of get_all_neighbors(active_coords_nd)) {
    const active_neighbors = count_active(active_coords, coord);
    const key = JSON.stringify(coord);
    const is_active = active_coords.has(key);
    if (is_active && (active_neighbors === 2 || active_neighbors === 3))
      new_active.add(key);
    else if (!is_active && active_neighbors === 3) new_active.add(key);
  }
  return new_active;
}

function part1(initial_state) {
  let active_coords = new Set(); // why js cant have good sets?
  initial_state.forEach((coord) =>
    active_coords.add(JSON.stringify([coord[0], coord[1], 0])),
  );
  for (let i = 0; i < 6; i++) active_coords = cycle(active_coords);
  return active_coords.size;
}

function part2(initial_state) {
  let active_coords = new Set();
  initial_state.forEach((coord) =>
    active_coords.add(JSON.stringify([coord[0], coord[1], 0, 0])),
  );
  for (let i = 0; i < 6; i++) active_coords = cycle(active_coords);
  return active_coords.size;
}

console.log("Part1: ", part1(initial_state));
console.log("Part2: ", part2(initial_state));
