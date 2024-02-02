use std::{collections::HashSet, io::BufRead};

const TOLERANCE_CONSECUTIVE: usize = 10;

fn parse_data<R: BufRead>(reader: R) -> (HashSet<i64>, HashSet<Vec<i64>>) {
    let mut initial_state = HashSet::new();
    let mut notes = HashSet::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                if line_content.starts_with("initial") {
                    initial_state = line_content
                        .split(' ')
                        .nth_back(0)
                        .unwrap()
                        .char_indices()
                        .filter_map(|(idx, ch)| if ch == '#' { Some(idx as i64) } else { None })
                        .collect();
                } else {
                    if let Some((recipe, target)) = line_content.split_once(" => ") {
                        if target.chars().next().unwrap() != '#' {
                            continue;
                        }
                        let idxs: Vec<_> = recipe
                            .char_indices()
                            .filter_map(|(idx, ch)| {
                                if ch == '#' {
                                    Some(idx as i64 - 2)
                                } else {
                                    None
                                }
                            })
                            .collect();
                        notes.insert(idxs);
                    }
                }
            }

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    (initial_state, notes)
}

fn get_neighbors(set: &HashSet<i64>, cur: i64) -> Vec<i64> {
    (-2..=2).filter(|idx| set.contains(&(cur + idx))).collect()
}

fn generation(set: &HashSet<i64>, recipes: &HashSet<Vec<i64>>) -> HashSet<i64> {
    let (start, finish) = set.iter().fold((i64::MAX, i64::MIN), |(min_, max_), &x| {
        (min_.min(x), max_.max(x))
    });
    let mut out = HashSet::new();
    for pot in (start - 2)..=(finish + 2) {
        let pot_nei = get_neighbors(set, pot);
        if recipes.contains(&pot_nei) {
            out.insert(pot);
        }
    }
    out
}

fn count_in_generation(
    set: &HashSet<i64>,
    recipes: &HashSet<Vec<i64>>,
    ngenerations: usize,
) -> i64 {
    let mut generation_set = set.clone();
    let mut last_sum = 0;
    let mut diff = 0;
    let mut same_value_count = 0;
    for i in 0..ngenerations {
        generation_set = generation(&generation_set, &recipes);
        let this_sum = generation_set.iter().sum();
        if diff == this_sum - last_sum {
            same_value_count += 1;
            if same_value_count > TOLERANCE_CONSECUTIVE {
                return last_sum + ((ngenerations - i) as i64) * diff;
            }
        } else {
            diff = this_sum - last_sum;
            same_value_count = 0;
        }
        last_sum = this_sum;
    }
    last_sum
}

fn main() {
    let _default_file = Some("input/day12.txt");

    let reader = aoc_lib::create_reader(_default_file);
    let (set, recipes) = parse_data(reader);

    println!("Part1: {}", count_in_generation(&set, &recipes, 20));
    println!(
        "Part2: {}",
        count_in_generation(&set, &recipes, 50000000000)
    );
}
