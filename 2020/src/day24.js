const fs = require("fs");

const filename_ = process.argv[2] || "tst";
const data = fs.readFileSync(filename_).toString().split("\n").filter(Boolean);

function parse_directions(str) {
  const out = [];
  let acc = "";
  for (const ch of str) {
    if (ch === "s" || ch === "n") acc += ch;
    else {
      out.push(acc + ch);
      acc = "";
    }
  }
  return out;
}

/**
 * Following the system from:
 * https://www.redblobgames.com/grids/hexagons/#coordinates-cube
 * The coordinates has a restraint that q + r + s = 0
 */
function str_dir2dir(str) {
  if (str === "e") return [1, 0, -1];
  else if (str === "se") return [0, 1, -1];
  else if (str === "sw") return [-1, 1, 0];
  else if (str === "w") return [-1, 0, 1];
  else if (str === "nw") return [0, -1, 1];
  else if (str === "ne") return [1, -1, 0];
}

const DIRECTION_VECTORS = [
  [1, 0, -1],
  [0, 1, -1],
  [-1, 1, 0],
  [-1, 0, 1],
  [0, -1, 1],
  [1, -1, 0],
];

function move(pos, dir) {
  for (let i = 0; i < pos.length; i++) pos[i] += dir[i];
}

function flip_tiles(move_instructions) {
  const black_tiles = new Set();
  for (const instructions of move_instructions) {
    const pos = [0, 0, 0];

    for (const dir of instructions) move(pos, dir);

    const hash = JSON.stringify(pos);
    if (black_tiles.has(hash)) black_tiles.delete(hash);
    else black_tiles.add(hash);
  }
  return black_tiles;
}

function get_black_tiles(raw_instructions) {
  const move_instructions = raw_instructions.map((line) =>
    parse_directions(line).map(str_dir2dir),
  );
  const black_tiles = flip_tiles(move_instructions);
  return black_tiles;
}

function* get_neighbors(pos) {
  for (const dir of DIRECTION_VECTORS) {
    let tmp = pos.slice();
    move(tmp, dir);
    yield tmp;
  }
}

function* get_all_neighbors(black_set) {
  const seen = new Set();
  for (const x of black_set) {
    const x_parsed = JSON.parse(x);
    if (!seen.has(x)) {
      yield x_parsed;
      seen.add(x);
    }
    for (const neighbor of get_neighbors(x_parsed)) {
      const hash = JSON.stringify(neighbor);
      if (!seen.has(hash)) {
        yield neighbor;
        seen.add(hash);
      }
    }
  }
}

function count_black_neighbors(pos, black_set) {
  let out = 0;
  for (const nei of get_neighbors(pos))
    out += black_set.has(JSON.stringify(nei));
  return out;
}

function day_cycle(black_tiles) {
  const out = new Set();
  for (const tile of get_all_neighbors(black_tiles)) {
    const tile_hash = JSON.stringify(tile);
    const is_black = black_tiles.has(tile_hash);
    const black_neighbors = count_black_neighbors(tile, black_tiles);
    if (!is_black && black_neighbors === 2) out.add(tile_hash);
    else if (is_black && !(black_neighbors === 0 || black_neighbors > 2))
      out.add(tile_hash);
  }
  return out;
}

function part2(black_tiles) {
  for (let i = 0; i < 100; i++) {
    black_tiles = day_cycle(black_tiles);
  }
  return black_tiles.size;
}

const black_tiles = get_black_tiles(data);

console.log("Part1: ", black_tiles.size);
console.log("Part2: ", part2(black_tiles));
