use std::io::BufRead;

const GRID_START: usize = 1;
const GRID_END: usize = 300;
const UNCHANGED_ITERATION_TOLERANCE: usize = 5;

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

fn find_max_sum(grid: &Vec<Vec<i8>>, kernel_size: usize) -> ((usize, usize), i32) {
    let max_possible_sum: i32 = (9 - 5) * ((kernel_size * kernel_size) as i32);
    let mut max_sum = i32::MIN;
    let mut coord = (0, 0);

    for i in GRID_START..=(GRID_END - kernel_size + 1) {
        for j in GRID_START..=(GRID_END - kernel_size + 1) {
            let sum = (0..kernel_size)
                .flat_map(|k| {
                    (0..kernel_size)
                        .map(move |l| grid[i + k - GRID_START][j + l - GRID_START] as i32)
                })
                .sum();
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

fn part2(grid: &Vec<Vec<i8>>) -> (usize, usize, usize) {
    let (mut large_x, mut large_y, mut large_size) = (0, 0, 0);
    let mut max_sum = i32::MIN;
    let mut consecutive_unchanged_iteration = 0;
    for size in 1..=(GRID_END - GRID_START + 1) {
        let ((x, y), sum) = find_max_sum(grid, size);
        if sum > max_sum {
            consecutive_unchanged_iteration = 0;
            max_sum = sum;
            large_x = x;
            large_y = y;
            large_size = size;
        } else {
            consecutive_unchanged_iteration += 1;
            if consecutive_unchanged_iteration >= UNCHANGED_ITERATION_TOLERANCE {
                return (large_x, large_y, large_size);
            }
        }
    }
    (large_x, large_y, large_size)
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
    let ((large_x, large_y), _) = find_max_sum(&grid, 3);
    let (large_x2, large_y2, size2) = part2(&grid);

    println!("Part1: {},{}", large_x, large_y);
    println!("Part2: {},{},{}", large_x2, large_y2, size2);
}
