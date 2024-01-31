use std::{collections::VecDeque, io::BufRead};

fn parse_data<R: BufRead>(reader: R) -> (usize, usize) {
    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                let parts: Vec<_> = line_content
                    .split(' ')
                    .filter_map(|s| s.parse().ok())
                    .collect();
                return (parts[0], parts[1]);
            }
            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    (0, 0)
}

fn play_game(nplayers: usize, last_marble_points: usize) -> usize {
    assert!(nplayers > 0);
    let mut marbles = VecDeque::from([0]);
    let mut scores = vec![0; nplayers];
    let player_it = (0..nplayers).cycle();

    for (marble, player_idx) in (1..=last_marble_points).zip(player_it) {
        if marble % 23 == 0 {
            marbles.rotate_left(7);
            scores[player_idx] += marble + marbles.pop_front().unwrap();
            marbles.rotate_right(1);
        } else {
            marbles.rotate_right(1);
            marbles.push_front(marble);
        }
    }
    *scores.iter().max().unwrap()
}

fn main() {
    let reader = aoc_lib::create_reader(None);
    let (nplayers, last_marble_points) = parse_data(reader);

    println!("Part1: {}", play_game(nplayers, last_marble_points));
    println!("Part2: {}", play_game(nplayers, 100 * last_marble_points));
}
