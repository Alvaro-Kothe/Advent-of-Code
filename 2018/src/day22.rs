use core::panic;
use std::{
    cmp::Reverse,
    collections::{BinaryHeap, HashMap},
    io::BufRead,
};

type Pos = (usize, usize);
const NEITHER: u8 = 0;
const TORCH: u8 = 1;
const CLIMBING_GEAR: u8 = 2;

const ROCKY: u8 = 0;
const WET: u8 = 1;
const NARROW: u8 = 2;

fn parse_data<R: BufRead>(reader: R) -> (usize, Pos) {
    let mut numbers = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                let iter = line_content
                    .trim()
                    .split(&[' ', ','])
                    .filter_map(|s| s.parse::<usize>().ok());
                numbers.extend(iter);
            }

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    let mut iter = numbers.into_iter();
    let depth = iter.next().unwrap();
    let x = iter.next().unwrap();
    let y = iter.next().unwrap();
    (depth, (x, y))
}

#[derive(Debug, Clone, Copy)]
struct Terrain {
    erosion_level: usize,
    type_: u8,
}

fn compute_terrain_measures(pos: &Pos, depth: usize, map: &HashMap<Pos, Terrain>) -> Terrain {
    let &(x, y) = pos;

    let geo_index = if (x, y) == (0, 0) {
        0
    } else if y == 0 {
        x * 16807
    } else if x == 0 {
        y * 48271
    } else {
        let left = map.get(&(x - 1, y)).unwrap().erosion_level;
        let up = map.get(&(x, y - 1)).unwrap().erosion_level;
        left * up
    };
    let erosion_level = (geo_index + depth) % 20183;
    let type_ = (erosion_level % 3) as u8;
    Terrain {
        erosion_level,
        type_,
    }
}

fn get_terrain_or_insert(position: &Pos, depth: usize, map: &mut HashMap<Pos, Terrain>) -> Terrain {
    if let Some(&terrain) = map.get(position) {
        terrain
    } else {
        let &(x, y) = position;
        if x > 0 && !map.contains_key(&(x - 1, y)) {
            get_terrain_or_insert(&(x - 1, y), depth, map);
        }
        if y > 0 && !map.contains_key(&(x, y - 1)) {
            get_terrain_or_insert(&(x, y - 1), depth, map);
        }
        let terrain = compute_terrain_measures(position, depth, map);
        map.insert(*position, terrain);
        terrain
    }
}

fn get_terrain_until_target(depth: usize, target: Pos) -> HashMap<Pos, Terrain> {
    let mut result = HashMap::new();
    get_terrain_or_insert(&target, depth, &mut result);
    // Make target rocky
    result
        .get_mut(&target)
        .and_then(|terrain| Some(terrain.type_ = 0));
    result
}

fn get_neighbors(position: &Pos) -> Vec<Pos> {
    let &(x, y) = position;
    let mut neighbors = vec![(x + 1, y), (x, y + 1)];
    if y > 0 {
        neighbors.push((x, y - 1));
    }
    if x > 0 {
        neighbors.push((x - 1, y));
    }
    neighbors
}

fn item_valid_for_terrain(item: u8, terrain: u8) -> bool {
    match terrain {
        ROCKY => item == CLIMBING_GEAR || item == TORCH,
        WET => item == CLIMBING_GEAR || item == NEITHER,
        NARROW => item == NEITHER || item == TORCH,
        _ => panic!(),
    }
}

fn get_alternative_item(item: u8, terrain: u8) -> u8 {
    let mut next_item = item;
    loop {
        next_item += 1;
        next_item %= 3;
        if item_valid_for_terrain(next_item, terrain) {
            return next_item;
        }
    }
}

fn get_shortest_time_to_target(
    map: &mut HashMap<Pos, Terrain>,
    target: Pos,
    depth: usize,
) -> Result<usize, &str> {
    let start_pos = (0, 0);
    let initial_item = TORCH;
    let mut queue = BinaryHeap::new();
    let mut distances = HashMap::from([((start_pos, initial_item), 0)]);
    queue.push(Reverse((0, start_pos, initial_item)));

    while let Some(Reverse((time, pos, item))) = queue.pop() {
        let cur_terrain_type = map.get(&pos).unwrap().type_;
        if pos == target && item == TORCH {
            return Ok(time);
        }
        // switch item
        let switch_time = time + 7;
        let next_item = get_alternative_item(item, cur_terrain_type);
        let switch_alt_time = distances.entry((pos, next_item)).or_insert(usize::MAX);
        if switch_time < *switch_alt_time {
            *switch_alt_time = switch_time;
            queue.push(Reverse((switch_time, pos, next_item)));
        }

        let move_time = time + 1;
        for neighbor in get_neighbors(&pos) {
            let nb_type = get_terrain_or_insert(&neighbor, depth, map).type_;
            if !item_valid_for_terrain(item, nb_type) {
                continue;
            }

            let alt_time = distances.entry((neighbor, item)).or_insert(usize::MAX);
            if move_time < *alt_time {
                *alt_time = move_time;
                queue.push(Reverse((move_time, neighbor, item)));
            }
        }
    }
    Err("Unreachable")
}

fn part1(map: &HashMap<Pos, Terrain>, target: Pos) -> usize {
    let mut result = 0;
    for x in 0..=target.0 {
        for y in 0..=target.1 {
            result += map.get(&(x, y)).unwrap().type_ as usize;
        }
    }
    result
}

fn part2(map: &HashMap<Pos, Terrain>, target: Pos, depth: usize) -> usize {
    let mut map_cp = map.clone();
    get_shortest_time_to_target(&mut map_cp, target, depth).unwrap()
}

fn main() {
    let _default_file = None;

    let reader = aoc_lib::create_reader(_default_file);
    let (depth, target) = parse_data(reader);
    let map = get_terrain_until_target(depth, target);

    println!("Part1: {}", part1(&map, target));
    println!("Part2: {}", part2(&map, target, depth));
}
