use std::io::BufRead;

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

fn main() {
    let _default_file = Some("input/day00.txt");

    let reader = aoc_lib::create_reader(None);
    let data = parse_data(reader);

    println!("Part1: {}", -1);
    println!("Part2: {}", -1);
}
