use std::io::BufRead;

type Position = (i32, i32, i32);

fn distance(point1: Position, point2: Position) -> u32 {
    point1.0.abs_diff(point2.0) + point1.1.abs_diff(point2.1) + point1.2.abs_diff(point2.2)
}

#[derive(Debug)]
struct Nanobot {
    pos: Position,
    signal_radius: u32,
}

fn parse_data<R: BufRead>(reader: R) -> Vec<Nanobot> {
    let mut bots = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                let parts = line_content
                    .split(&['<', '>', ',', '='])
                    .filter_map(|s| s.parse::<i32>().ok());
                let [x, y, z, r] = parts.collect::<Vec<_>>()[..] else {
                    panic!()
                };
                bots.push(Nanobot {
                    pos: (x, y, z),
                    signal_radius: r as u32,
                })
            }

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    bots
}

fn find_strongest_nanobot(bots: &[Nanobot]) -> &Nanobot {
    bots.iter().max_by_key(|bot| bot.signal_radius).unwrap()
}

fn count_in_range(bot: &Nanobot, bots: &[Nanobot]) -> usize {
    bots.iter()
        .filter(|&other_bot| distance(bot.pos, other_bot.pos) <= bot.signal_radius)
        .count()
}

fn part1(bots: &[Nanobot]) -> usize {
    let strongest = find_strongest_nanobot(bots);
    count_in_range(strongest, bots)
}

fn main() {
    let _default_file = Some("input/day00.txt");

    let reader = aoc_lib::create_reader(None);
    let data = parse_data(reader);

    println!("Part1: {}", part1(&data));
    println!("Part2: {}", -1);
}
