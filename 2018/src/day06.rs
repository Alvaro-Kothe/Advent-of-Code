use std::{
    collections::{HashSet, VecDeque},
    io::BufRead,
};

fn parse_data<R: BufRead>(reader: R) -> Vec<(i32, i32)> {
    let mut positions: Vec<(i32, i32)> = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                let mut parts = line_content.split(", ").map(|s| s.trim().parse());
                let x = parts.next().unwrap().unwrap();
                let y = parts.next().unwrap().unwrap();
                positions.push((x, y));
            }

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    positions
}

fn get_limits(positions: &Vec<(i32, i32)>) -> (i32, i32, i32, i32) {
    positions.iter().fold(
        (i32::MAX, i32::MIN, i32::MAX, i32::MIN),
        |(xmin, xmax, ymin, ymax), (x, y)| (xmin.min(*x), xmax.max(*x), ymin.min(*y), ymax.max(*y)),
    )
}

fn manhattan_distance(this: (i32, i32), other: (i32, i32)) -> u32 {
    this.0.abs_diff(other.0) + this.1.abs_diff(other.1)
}

fn within_bounds(pos: (i32, i32), limits: (i32, i32, i32, i32)) -> bool {
    limits.0 <= pos.0 && pos.0 <= limits.1 && limits.2 <= pos.1 && pos.1 <= limits.3
}

fn get_neighbors(pos: (i32, i32)) -> impl Iterator<Item = (i32, i32)> {
    let deltas = [-1, 0, 1];
    deltas.into_iter().flat_map(move |dx| {
        deltas.into_iter().filter_map(move |dy| {
            if dx != 0 || dy != 0 {
                Some((pos.0 + dx, pos.1 + dy))
            } else {
                None
            }
        })
    })
}

fn compute_area(
    positions: &Vec<(i32, i32)>,
    start: (i32, i32),
    limits: (i32, i32, i32, i32),
) -> Option<usize> {
    let origin = start;
    let others_positions: Vec<_> = positions
        .iter()
        .filter(|&&v| v != origin)
        .cloned()
        .collect();
    let mut area = 0;
    let mut to_explore = Vec::from([start]);
    let mut seen = HashSet::from([start]);

    while let Some(pos) = to_explore.pop() {
        area += 1;
        for nei in get_neighbors(pos) {
            if !within_bounds(nei, limits) {
                return None;
            } else if seen.contains(&nei) {
                continue;
            }
            seen.insert(nei);
            let dst_origin = manhattan_distance(nei, origin);
            let is_closest = others_positions
                .iter()
                .all(|&coord| dst_origin < manhattan_distance(nei, coord));
            if is_closest {
                to_explore.push(nei);
            }
        }
    }
    Some(area)
}

fn part1(positions: &Vec<(i32, i32)>) -> usize {
    let limits = get_limits(&positions);
    let mut result = usize::MIN;
    for coord in positions.iter() {
        if let Some(area) = compute_area(positions, *coord, limits) {
            result = result.max(area);
        }
    }
    result
}

fn compute_total_distance(positions: &Vec<(i32, i32)>, pos: (i32, i32)) -> u32 {
    positions
        .iter()
        .fold(0, |acc, &coord| acc + manhattan_distance(pos, coord))
}

fn find_region_start(positions: &Vec<(i32, i32)>, max_distance: u32) -> Result<(i32, i32), &str> {
    let mut deque = VecDeque::new();
    let mut seen = HashSet::new();
    deque.extend(positions.iter().cloned());

    while let Some(pos) = deque.pop_front() {
        if seen.contains(&pos) {
            continue;
        }
        seen.insert(pos);
        let cur_dst = compute_total_distance(positions, pos);
        if cur_dst < max_distance {
            return Ok(pos);
        }
        let to_explore_nei =
            get_neighbors(pos).filter(|&nei| compute_total_distance(positions, nei) < cur_dst);
        deque.extend(to_explore_nei);
    }
    Err("Not found")
}

fn compute_region_area(positions: &Vec<(i32, i32)>, start: (i32, i32), max_distance: u32) -> usize {
    let mut to_explore = Vec::from([start]);
    let mut seen = HashSet::new();
    let mut area = 0;
    while let Some(pos) = to_explore.pop() {
        if seen.contains(&pos) {
            continue;
        }
        seen.insert(pos);
        area += 1;
        let to_explore_nei =
            get_neighbors(pos).filter(|&nei| compute_total_distance(positions, nei) < max_distance);
        to_explore.extend(to_explore_nei);
    }
    area
}

fn part2(positions: &Vec<(i32, i32)>, max_distance: u32) -> usize {
    let region_start = find_region_start(positions, max_distance).unwrap();
    compute_region_area(positions, region_start, max_distance)
}

fn main() {
    let _default_file = Some("input/day00.txt");

    let reader = aoc_lib::create_reader(None);
    let data = parse_data(reader);

    println!("Part1: {}", part1(&data));
    println!("Part2: {}", part2(&data, 10000));
}
