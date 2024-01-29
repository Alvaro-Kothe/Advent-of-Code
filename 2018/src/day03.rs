use std::{collections::HashMap, io::BufRead};

#[derive(Debug)]
struct Claim {
    id: u32,
    x0: u32,
    y0: u32,
    x1: u32,
    y1: u32,
}

fn parse_claim(str: String) -> Claim {
    let items: Vec<&str> = str
        .split(&['#', '@', ',', ' ', 'x', ':'])
        .filter(|s| !s.is_empty())
        .collect();
    let id = items[0].parse().unwrap();
    let y0 = items[1].parse().unwrap();
    let x0 = items[2].parse().unwrap();
    let y1 = items[3].parse::<u32>().unwrap() + y0 - 1;
    let x1 = items[4].parse::<u32>().unwrap() + x0 - 1;
    Claim { id, x0, y0, x1, y1 }
}

fn parse_data<R: BufRead>(reader: R) -> Vec<Claim> {
    let mut claims: Vec<Claim> = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                claims.push(parse_claim(line_content));
            }

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    claims
}

fn solve_parts(claims: Vec<Claim>) -> Result<(usize, u32), &'static str> {
    let mut claims_grid: HashMap<(u32, u32), u32> = HashMap::new();
    for claim in claims.iter() {
        for x in claim.x0..=claim.x1 {
            for y in claim.y0..=claim.y1 {
                claims_grid
                    .entry((x, y))
                    .and_modify(|v| *v += 1)
                    .or_insert(1);
            }
        }
    }
    let fabric_size = claims_grid.values().filter(|&v| v > &1).count();

    'claim_loop: for claim in claims.iter() {
        for x in claim.x0..=claim.x1 {
            for y in claim.y0..=claim.y1 {
                if claims_grid.get(&(x, y)).unwrap() > &1 {
                    continue 'claim_loop;
                }
            }
        }
        return Ok((fabric_size, claim.id));
    }

    Err("Not found")
}

fn main() {
    let default_file = Some("input/day03.txt");

    let reader = aoc_lib::create_reader(default_file);
    let data = parse_data(reader);

    let (p1, p2) = solve_parts(data).unwrap_or((0, 0));

    println!("Part1: {}", p1);
    println!("Part2: {}", p2);
}
