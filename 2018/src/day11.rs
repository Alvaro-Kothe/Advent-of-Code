use std::io::BufRead;

const GRID_START: usize = 1;
const GRID_END: usize = 300;

fn parse_data<R: BufRead>(reader: R) -> Result<usize, &'static str> {
    for line in reader.lines() {
        if let Ok(line_content) = line {
            return Ok(line_content.trim().parse().unwrap());
        }
    }
    Err("Couldn't parse buffer")
}

fn compute_pow_lvl(x: usize, y: usize, serial_number: usize) -> i8 {
    let id = x + 10;
    let mut pow_lvl = id * y;
    pow_lvl += serial_number;
    pow_lvl *= id;
    let hundreds_digit = (pow_lvl / 100) % 10;
    (hundreds_digit as i8) - 5
}

fn get_grid_powers(serial_number: usize) -> Vec<Vec<i8>> {
    let grid_size = GRID_END - GRID_START + 1;
    let mut grid = vec![vec![0; grid_size]; grid_size];
    for x in GRID_START..=GRID_END {
        for y in GRID_START..=GRID_END {
            grid[x - GRID_START][y - GRID_START] = compute_pow_lvl(x, y, serial_number)
        }
    }
    grid
}

fn part2(grid: &Vec<Vec<i32>>) -> (usize, usize, usize) {
    let (mut large_x, mut large_y, mut large_size) = (0, 0, 0);
    let mut max_sum = i32::MIN;
    let grid_size = grid.len();
    for size in 1..=grid_size {
        let ((x, y), sum) = find_max_sum_sat(grid, size);
        if sum > max_sum {
            max_sum = sum;
            large_x = x;
            large_y = y;
            large_size = size;
        }
    }
    (large_x, large_y, large_size)
}

/// # Summed-area table
fn get_grid_sat(grid: &Vec<Vec<i8>>) -> Vec<Vec<i32>> {
    let grid_size = grid.len();
    let mut grid_sat = vec![vec![0; grid_size]; grid_size];
    for i in 0..grid_size {
        for j in 0..grid_size {
            let sum_above = if i == 0 { 0 } else { grid_sat[i - 1][j] };
            let sum_left = if j == 0 { 0 } else { grid_sat[i][j - 1] };
            let sum_nw = if i == 0 || j == 0 {
                0
            } else {
                grid_sat[i - 1][j - 1]
            };
            grid_sat[i][j] = (grid[i][j] as i32) + sum_left + sum_above - sum_nw;
        }
    }
    grid_sat
}

fn sum_sat(grid: &Vec<Vec<i32>>, x0: usize, y0: usize, x1: usize, y1: usize) -> i32 {
    // sum of the quadrants 2, 4 subtracted by the sum of quadrants 1, 3
    grid[x1][y1]
        + if x0 == 0 || y0 == 0 { // top-left
            0
        } else {
            grid[x0 - 1][y0 - 1]
        }
        - if x0 == 0 { 0 } else { grid[x0 - 1][y1] } // top-right
        - if y0 == 0 { 0 } else { grid[x1][y0 - 1] } // bottom-left
}

fn find_max_sum_sat(grid: &Vec<Vec<i32>>, kernel_size: usize) -> ((usize, usize), i32) {
    let max_possible_sum: i32 = (9 - 5) * ((kernel_size * kernel_size) as i32);
    let grid_size = grid.len();
    let mut max_sum = i32::MIN;
    let mut coord = (0, 0);
    let kernel_end = kernel_size - 1;

    for i in 0..=(grid_size - kernel_size) {
        for j in 0..=(grid_size - kernel_size) {
            let sum = sum_sat(grid, i, j, i + kernel_end, j + kernel_end);
            if sum == max_possible_sum {
                return ((i, j), sum);
            } else if sum > max_sum {
                max_sum = sum;
                coord = (i, j);
            }
        }
    }
    (coord, max_sum)
}

fn main() {
    let _default_input = Some(6878);

    let serial_number = if let Some(inp) = _default_input {
        inp
    } else {
        let reader = aoc_lib::create_reader(None);
        parse_data(reader).unwrap()
    };

    let grid = get_grid_powers(serial_number);
    let grid_sat = get_grid_sat(&grid);
    let ((large_x, large_y), _) = find_max_sum_sat(&grid_sat, 3);
    let (large_x2, large_y2, size2) = part2(&grid_sat);

    println!("Part1: {},{}", large_x + 1, large_y + 1);
    println!("Part2: {},{},{}", large_x2 + 1, large_y2 + 1, size2);
}
