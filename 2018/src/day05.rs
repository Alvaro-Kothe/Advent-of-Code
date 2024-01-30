use std::{collections::HashSet, io::BufRead};

fn react(this: char, other: char) -> bool {
    let diff = this as i32 - other as i32;
    diff.abs() == 32
}

fn react_chain<R: BufRead>(reader: R) -> Vec<char> {
    let mut stack: Vec<char> = Vec::new();

    for ch_content in reader.bytes() {
        let ch = ch_content.unwrap() as char;
        if ch.eq(&'\n') {
            continue;
        }
        if let Some(ch_front) = stack.pop() {
            if !react(ch_front, ch) {
                stack.push(ch_front);
                stack.push(ch);
            }
        } else {
            stack.push(ch);
        }
    }
    stack
}

fn remove_and_react(chain: Vec<char>, removed_char: char) -> Vec<char> {
    let mut stack: Vec<char> = Vec::new();
    for ch in chain.iter() {
        if ch.to_ascii_lowercase().eq(&removed_char) {
            continue;
        }
        if let Some(ch_front) = stack.pop() {
            if !react(ch_front, *ch) {
                stack.push(ch_front);
                stack.push(*ch);
            }
        } else {
            stack.push(*ch);
        }
    }
    stack
}

fn part2(chain: Vec<char>) -> usize {
    let mut seen: HashSet<char> = HashSet::new();
    let mut shortest_len = usize::MAX;
    for ch in chain.iter() {
        let removed_char = ch.to_ascii_lowercase();
        if seen.contains(&removed_char) {
            continue;
        }
        seen.insert(removed_char);
        let chain_removed = remove_and_react(chain.clone(), removed_char);
        shortest_len = shortest_len.min(chain_removed.len());
    }
    shortest_len
}

fn main() {
    let _default_file = Some("input/day05.txt");

    let reader = aoc_lib::create_reader(_default_file);
    let reaction_result = react_chain(reader);

    println!("Part1: {}", reaction_result.len());
    println!("Part2: {}", part2(reaction_result));
}
