use std::{collections::HashMap, io::BufRead};

fn parse_data<R: BufRead>(reader: R) -> Vec<Vec<char>> {
    let mut grid = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => grid.push(line_content.trim().chars().collect()),

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    grid
}

fn count_nb_char(grid: &Vec<Vec<char>>, x: usize, y: usize, chars: &[char]) -> Vec<usize> {
    let mut result = vec![0; chars.len()];
    for i in -1..=1 {
        for j in -1..=1 {
            if i != 0 || j != 0 {
                let new_x = x as isize + i;
                let new_y = y as isize + j;
                if new_x >= 0 && new_y >= 0 {
                    let char_nb = grid.get(new_x as usize).and_then(|r| r.get(new_y as usize));
                    for (i, &ch) in chars.into_iter().enumerate() {
                        if char_nb.is_some_and(|&c| c == ch) {
                            result[i] += 1;
                            break;
                        }
                    }
                }
            }
        }
    }
    result
}

fn next_grid(grid: &Vec<Vec<char>>) -> Vec<Vec<char>> {
    let mut next_grid = grid.clone();
    for i in 0..grid.len() {
        for j in 0..grid[i].len() {
            match grid[i][j] {
                '.' => {
                    if count_nb_char(grid, i, j, &['|']).first().unwrap() >= &3 {
                        next_grid[i][j] = '|';
                    }
                }
                '|' => {
                    if count_nb_char(grid, i, j, &['#']).first().unwrap() >= &3 {
                        next_grid[i][j] = '#';
                    }
                }
                '#' => match count_nb_char(grid, i, j, &['#', '|'])[..] {
                    [0, _] | [_, 0] => next_grid[i][j] = '.',
                    [_, _] => next_grid[i][j] = '#',
                    _ => panic!(),
                },
                _ => panic!(),
            }
        }
    }
    next_grid
}

fn pass_minutes(grid: &Vec<Vec<char>>, n: usize) -> Vec<Vec<char>> {
    let mut grid_copy = grid.clone();
    let mut seen_states = HashMap::new();
    let mut cycle_start = 0;
    let mut cycle_end = 0;
    for i in 0..n {
        grid_copy = next_grid(&grid_copy);
        let state: String = grid_copy.iter().flatten().collect();
        if let Some(prev_index) = seen_states.insert(state, i) {
            cycle_start = prev_index;
            cycle_end = i;
            break;
        }
    }
    if cycle_end == 0 {
        return grid_copy;
    }
    let period = cycle_end - cycle_start;
    let remaining_iterations = (n - 1 - cycle_end) % period;
    for _ in 0..remaining_iterations {
        grid_copy = next_grid(&grid_copy);
    }
    grid_copy
}

fn count_wood(grid: &Vec<Vec<char>>) -> (usize, usize) {
    let mut nlum = 0;
    let mut nwood = 0;
    for &ch in grid.into_iter().flatten() {
        if ch == '#' {
            nlum += 1;
        } else if ch == '|' {
            nwood += 1;
        }
    }
    (nwood, nlum)
}

fn part1(grid: &Vec<Vec<char>>) -> usize {
    let future_grid = pass_minutes(grid, 10);
    let (nlum, nwood) = count_wood(&future_grid);
    nlum * nwood
}
fn part2(grid: &Vec<Vec<char>>) -> usize {
    let niter = 1000000000;
    let future_grid = pass_minutes(grid, niter);
    let (nlum, nwood) = count_wood(&future_grid);
    nlum * nwood
}

fn main() {
    let _default_file = Some("tst");

    let reader = aoc_lib::create_reader(_default_file);
    let data = parse_data(reader);

    println!("Part1: {}", part1(&data));
    println!("Part2: {}", part2(&data));
}
