use std::{collections::HashSet, io::BufRead};

fn parse_data<R: BufRead>(reader: R) -> Vec<i32> {
    let mut numbers: Vec<i32> = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                if let Ok(number) = line_content.trim().parse::<i32>() {
                    numbers.push(number);
                }
            }

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    numbers
}

fn part2(data: Vec<i32>) -> i32 {
    let mut seen: HashSet<i32> = HashSet::new();
    let mut sum: i32 = 0;
    let mut numbers = data.iter().cycle();
    while !seen.contains(&sum) {
        seen.insert(sum);
        sum += numbers.next().unwrap();
    }
    sum
}

fn main() {
    let default_file = "input/day01.txt";

    let reader = aoc_lib::create_reader(Some(default_file));
    let data = parse_data(reader);

    let p1: i32 = data.iter().sum();

    println!("Part1: {}", p1);
    println!("Part2: {}", part2(data));
}
