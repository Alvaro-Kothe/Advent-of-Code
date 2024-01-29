use std::{
    collections::{HashMap, HashSet},
    io::BufRead,
};

fn str_intersect(str1: &str, str2: &str) -> Option<String> {
    let mut out = String::new();
    let mut count = 0;
    for (c1, c2) in str1.chars().zip(str2.chars()) {
        if c1 != c2 {
            count += 1;
            if count > 1 {
                return None;
            }
        } else {
            out.push(c1);
        }
    }
    Some(out)
}

fn get_common_letters<R: BufRead>(
    reader: R,
    two_counter: &mut i32,
    three_counter: &mut i32,
) -> String {
    let mut seen: HashSet<String> = HashSet::new();
    let mut out = String::new();
    for line in reader.lines() {
        let mut letters = HashMap::new();
        match line {
            Ok(line_content) => {
                if out.is_empty() {
                    for seen_str in seen.iter() {
                        let inter = str_intersect(seen_str, &line_content);
                        if let Some(value) = inter {
                            out = value;
                            break;
                        }
                    }
                    seen.insert(line_content.clone());
                }

                for ch in line_content.chars() {
                    letters
                        .entry(ch)
                        .and_modify(|counter| *counter += 1)
                        .or_insert(1);
                }
            }
            Err(err) => eprintln!("Error reading line: {}", err),
        }
        if letters.values().any(|&v| v == 2) {
            *two_counter += 1;
        }
        if letters.values().any(|&v| v == 3) {
            *three_counter += 1;
        }
    }
    out
}

fn main() {
    let default_file = "input/day00.txt";

    let reader = aoc_lib::create_reader(default_file);
    let mut twos = 0;
    let mut threes = 0;
    let common_letters = get_common_letters(reader, &mut twos, &mut threes);

    println!("Part1: {}", twos * threes);
    println!("Part2: {}", common_letters);
}
