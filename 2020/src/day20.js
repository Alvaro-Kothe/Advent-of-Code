const fs = require("fs");

const filename_ = process.argv[2] || "input/day20.txt";
const data = fs.readFileSync(filename_).toString().trim().split("\n\n");

function parse_data(tiles_str) {
  const out = new Map();
  for (const tile of tiles_str) {
    let rows = tile.trim().split("\n");
    const tile_id = Number(rows[0].match(/\d+/));
    const grid = rows
      .slice(1)
      .map((row) => row.split("").map((ch) => ch === "#"));
    out.set(tile_id, grid);
  }
  return out;
}

function transpose(matrix) {
  return matrix[0].map((_, col_idx) => matrix.map((row) => row[col_idx]));
}
function horizontal_flip(matrix) {
  return matrix.map((row) => row.slice().reverse());
}
function rotate90_clkwise(matrix) {
  return horizontal_flip(transpose(matrix));
}

class Tile {
  constructor(id, data) {
    this.id = id;
    this.data = data;
    this.ncol = data[0].length;
    this.nrow = data.length;
  }
  equal_right(matrix) {
    for (let i = 0; i < this.nrow; i++)
      if (this.data[i][this.ncol - 1] !== matrix[i][0]) return false;
    return true;
  }
  equal_bot(matrix) {
    for (let i = 0; i < this.ncol; i++)
      if (this.data[this.nrow - 1][i] !== matrix[0][i]) return false;
    return true;
  }
}

function* get_rotations(matrix) {
  let new_matrix = matrix; // transpose generate a deepcopy
  yield new_matrix;
  for (let i = 0; i < 3; i++) {
    new_matrix = rotate90_clkwise(new_matrix);
    yield new_matrix;
  }
  new_matrix = horizontal_flip(new_matrix);
  yield new_matrix;
  for (let i = 0; i < 3; i++) {
    new_matrix = rotate90_clkwise(new_matrix);
    yield new_matrix;
  }
}

const grids = parse_data(data);
const rotated_grids = new Map();
for (const [id, img] of grids)
  rotated_grids.set(id, Array.from(get_rotations(img)));

function is_place_valid(grid, row, col, img) {
  if (row > 0 && !grid[row - 1][col].equal_bot(img)) return false;
  if (col > 0 && !grid[row][col - 1].equal_right(img)) return false;
  return true;
}

function solve_arrangement(tiles, grid, row, col, placed_tiles) {
  if (row === grid.length - 1 && col === grid[0].length) return true;
  if (col === grid[0].length) {
    row++;
    col = 0;
  }
  for (const [tileid, rotations] of tiles) {
    if (placed_tiles.has(tileid)) continue;
    placed_tiles.add(tileid);

    for (const image_rot of rotations) {
      if (is_place_valid(grid, row, col, image_rot)) {
        grid[row][col] = new Tile(tileid, image_rot);
        if (solve_arrangement(tiles, grid, row, col + 1, placed_tiles))
          return true;
      }
    }
    placed_tiles.delete(tileid);
  }
  return false;
}

function find_arrangement(tiles) {
  const grid_size = Math.sqrt(tiles.size);
  const arrangement = Array.from(Array(grid_size), () =>
    Array(grid_size).fill(null),
  );
  const placed_tiles = new Set();
  if (solve_arrangement(tiles, arrangement, 0, 0, placed_tiles))
    return arrangement;
  throw new Error("No solution");
}

const arrangement = find_arrangement(rotated_grids);
const nrow = arrangement.length,
  ncol = arrangement[0].length;
const p1 =
  arrangement[0][0].id *
  arrangement[0][ncol - 1].id *
  arrangement[nrow - 1][0].id *
  arrangement[nrow - 1][ncol - 1].id;

console.log("Part1: ", p1);

let monster = `                  # 
#    ##    ##    ###
 #  #  #  #  #  #   `
  .split("\n")
  .map((row) => row.split("").map((ch) => ch === "#"));

function get_image(arrangement) {
  const tiledim = arrangement[0][0].data.length; // assuming squared
  const tile_per_row = arrangement.length;
  const out = [];
  for (let i = 0; i < tile_per_row * tiledim; i++) {
    if (i % tiledim === 0 || i % tiledim === tiledim - 1) continue;
    const aux = [];
    const cur_row = Math.floor(i / tiledim);
    for (let j = 0; j < tile_per_row * tiledim; j++) {
      if (j % tiledim === 0 || j % tiledim === tiledim - 1) continue;
      const cur_col = Math.floor(j / tiledim);
      aux.push(arrangement[cur_row][cur_col].data[i % tiledim][j % tiledim]);
    }
    out.push(aux);
  }
  return out;
}

function find_monster(img, row, col, monster) {
  for (let i = 0; i < monster.length; i++)
    for (let j = 0; j < monster[0].length; j++)
      if (monster[i][j] && img[row + i][col + j] !== monster[i][j])
        return false;
  return true;
}

function hide_monster(img, row, col, monster) {
  for (let i = 0; i < monster.length; i++)
    for (let j = 0; j < monster[0].length; j++)
      if (monster[i][j]) img[row + i][col + j] = false;
}

function sum_matrix(matrix) {
  let out = 0;
  for (let i = 0; i < matrix.length; i++) {
    for (let j = 0; j < matrix[i].length; j++) {
      out += matrix[i][j];
    }
  }
  return out;
}

function compute_habitat(image) {
  const h = monster.length,
    w = monster[0].length;
  for (const rot of get_rotations(image)) {
    let monsters_found = 0;
    for (let i = 0; i + h - 1 < image.length; i++) {
      for (let j = 0; j + w - 1 < image[0].length; j++) {
        if (find_monster(rot, i, j, monster)) {
          hide_monster(rot, i, j, monster);
          monsters_found++;
        }
      }
    }
    if (monsters_found > 0) {
      return sum_matrix(rot);
    }
  }
}

const final_image = get_image(arrangement);
console.log("Part2: ", compute_habitat(final_image));
