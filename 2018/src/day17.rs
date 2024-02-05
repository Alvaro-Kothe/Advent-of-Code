use std::{collections::HashSet, io::BufRead};

type Pos = (usize, usize);

fn parse_line(line: &String) -> Vec<Pos> {
    let mut ranges: Vec<(_, Pos)> = line
        .split(", ")
        .map(|s| {
            let (identifier, values_str) = s.split_once('=').unwrap();
            let range = {
                if let Some((start, finish)) = values_str.split_once("..") {
                    (start.parse().unwrap(), finish.parse().unwrap())
                } else {
                    let val = values_str.parse().unwrap();
                    (val, val)
                }
            };
            (identifier, range)
        })
        .collect();
    ranges.sort_by(|a, b| a.0.cmp(&b.0));
    let (startx, endx) = ranges[0].1;
    let (starty, endy) = ranges[1].1;
    (startx..=endx)
        .flat_map(|x| (starty..=endy).map(move |y| (x, y)))
        .collect()
}

fn parse_data<R: BufRead>(reader: R) -> HashSet<Pos> {
    let mut clays = HashSet::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                let clay_pos = parse_line(&line_content).into_iter();
                clays.extend(clay_pos);
            }

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    clays
}

fn create_grid(clays: &HashSet<Pos>) -> (Vec<Vec<char>>, usize) {
    let (mut minx, mut maxx, maxy) = clays.iter().fold(
        (usize::MAX, usize::MIN, usize::MIN),
        |(minx, maxx, maxy), (x, y)| (minx.min(*x), maxx.max(*x), maxy.max(*y)),
    );
    minx = minx.min(500) - 1;
    maxx = maxx.max(500) + 1;

    let mut grid = vec![vec!['.'; 1 + (maxx - minx)]; 1 + maxy];
    for (x, y) in clays.into_iter() {
        grid[*y][x - minx] = '#';
    }
    (grid, 500 - minx)
}

fn water_flow(grid: &mut Vec<Vec<char>>, x: usize, y: usize) {
    if let Some(cell_below @ '.') = grid.get_mut(y + 1).and_then(|r| r.get_mut(x)) {
        *cell_below = '|';
        water_flow(grid, x, y + 1)
    }
    // test if cell below was replaced with ~ or is '#'
    let cell_below = grid.get(y + 1).and_then(|r| r.get(x));
    if cell_below == Some(&'#') || cell_below == Some(&'~') {
        if let Some(cell_left @ '.') = grid.get_mut(y).and_then(|r| r.get_mut(x - 1)) {
            *cell_left = '|';
            water_flow(grid, x - 1, y);
        }
        if let Some(cell_right @ '.') = grid.get_mut(y).and_then(|r| r.get_mut(x + 1)) {
            *cell_right = '|';
            water_flow(grid, x + 1, y);
        }
        if neighbor_blocks_fill(grid, x, y) {
            fill_row(grid, x, y);
        }
    }
}

fn neighbor_blocks_fill(grid: &Vec<Vec<char>>, x: usize, y: usize) -> bool {
    let row = &grid[y];
    let mut left_idx = x;
    let mut right_idx = x;
    while left_idx > 0 && row[left_idx] == '|' {
        left_idx -= 1;
    }
    if row[left_idx] != '#' {
        return false;
    }
    while right_idx < row.len() && row[right_idx] == '|' {
        right_idx += 1;
    }
    if row[right_idx] != '#' {
        return false;
    }
    true
}

fn fill_row(grid: &mut Vec<Vec<char>>, x: usize, y: usize) {
    if grid[y][x] == '|' {
        grid[y][x] = '~';
        fill_row(grid, x + 1, y);
        fill_row(grid, x - 1, y);
    }
}

fn count_water(clays: &HashSet<Pos>) -> (usize, usize) {
    let (mut grid, origin) = create_grid(clays);
    water_flow(&mut grid, origin, 0);
    let miny = clays.iter().min_by_key(|&&(_, y)| y).unwrap().1;
    let mut running_watter = 0;
    let mut resting_water = 0;
    for ch in grid.into_iter().skip(miny).flatten() {
        if ch == '|' {
            running_watter += 1;
        } else if ch == '~' {
            resting_water += 1;
        }
    }
    (running_watter, resting_water)
}

fn main() {
    let _default_file = Some("tst");

    let reader = aoc_lib::create_reader(_default_file);
    let data = parse_data(reader);
    let (running_water, resting_water) = count_water(&data);
    let p1 = running_water + resting_water;
    let p2 = resting_water;

    println!("Part1: {}", p1);
    println!("Part2: {}", p2);
}

fn _print_grid(grid: &Vec<Vec<char>>) {
    for row in grid {
        for ch in row {
            print!("{}", ch);
        }
        println!();
    }
}
