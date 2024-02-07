use std::{collections::HashMap, io::BufRead};

type Pos = (i32, i32);

fn char_to_next_pos(pos: Pos, ch: char) -> Pos {
    match ch {
        'N' => (pos.0 - 1, pos.1),
        'S' => (pos.0 + 1, pos.1),
        'E' => (pos.0, pos.1 + 1),
        'W' => (pos.0, pos.1 - 1),
        _ => panic!(),
    }
}

fn parse_data<R: BufRead>(reader: R) -> HashMap<Pos, usize> {
    let mut stack = Vec::new();
    let mut cur_pos = (0, 0);
    let mut distances = HashMap::from([(cur_pos, 0)]);
    let mut last_distance = 0;
    for byte in reader.bytes() {
        if let Ok(ch) = byte.and_then(|b| Ok(b as char)) {
            match ch {
                '(' => stack.push(cur_pos),
                ')' => {
                    cur_pos = stack.pop().unwrap();
                    last_distance = *distances.get(&cur_pos).unwrap();
                }
                '|' => {
                    cur_pos = *stack.last().unwrap();
                    last_distance = *distances.get(&cur_pos).unwrap();
                }
                'N' | 'S' | 'E' | 'W' => {
                    cur_pos = char_to_next_pos(cur_pos, ch);
                    let cur_distance = distances.entry(cur_pos).or_insert(last_distance + 1);
                    if (last_distance + 1) < *cur_distance {
                        *cur_distance = last_distance + 1;
                    }
                    last_distance = *cur_distance;
                }
                _ => continue,
            }
        }
    }
    distances
}

fn main() {
    let _default_file = Some("input/day00.txt");

    let reader = aoc_lib::create_reader(None);
    let distances = parse_data(reader);

    println!("Part1: {}", distances.values().max().unwrap());
    println!(
        "Part2: {}",
        distances.values().filter(|&&d| d >= 1000).count()
    );
}
