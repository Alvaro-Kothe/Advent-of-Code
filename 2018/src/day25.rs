use std::io::BufRead;

fn parse_data<R: BufRead>(reader: R) -> Vec<Vec<Vec<i32>>> {
    let mut constelations = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                let point: Vec<_> = line_content
                    .split(',')
                    .filter_map(|s| s.parse().ok())
                    .collect();
                constelations = insert(point, &constelations);
            }

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    constelations
}

fn distance(a: &[i32], b: &[i32]) -> u32 {
    a.iter().zip(b.iter()).map(|(a, b)| a.abs_diff(*b)).sum()
}

fn insert(element: Vec<i32>, groups: &Vec<Vec<Vec<i32>>>) -> Vec<Vec<Vec<i32>>> {
    let mut new_constellation = Vec::from([element.to_vec()]);
    let mut old_constellations = Vec::new();
    for group in groups.iter() {
        let point_close = group
            .iter()
            .any(|group_point| distance(&group_point, &element) <= 3);
        if point_close {
            new_constellation.extend_from_slice(group);
        } else {
            old_constellations.push(group.to_vec());
        }
    }
    old_constellations.push(new_constellation);
    old_constellations
}

fn main() {
    let _default_file = Some("input/day00.txt");

    let reader = aoc_lib::create_reader(None);
    let data = parse_data(reader);

    println!("Part1: {}", data.len());
}
