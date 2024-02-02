use core::panic;
use std::{
    collections::{HashMap, HashSet},
    io::BufRead,
};

#[derive(Debug, Clone, Copy)]
struct Cart {
    x: i32,
    y: i32,
    dx: i32,
    dy: i32,
    turn_cycle: u8,
    destroyed: bool,
}

fn create_cart(x: i32, y: i32, char_dir: char) -> Cart {
    match char_dir {
        '>' => Cart {
            x,
            y,
            dx: 1,
            dy: 0,
            turn_cycle: 0,
            destroyed: false,
        },
        '<' => Cart {
            x,
            y,
            dx: -1,
            dy: 0,
            turn_cycle: 0,
            destroyed: false,
        },
        '^' => Cart {
            x,
            y,
            dx: 0,
            dy: -1,
            turn_cycle: 0,
            destroyed: false,
        },
        'v' => Cart {
            x,
            y,
            dx: 0,
            dy: 1,
            turn_cycle: 0,
            destroyed: false,
        },
        _ => panic!("Invalid char_dir {}", char_dir),
    }
}

impl Cart {
    fn move_(&mut self) {
        self.x += self.dx;
        self.y += self.dy;
    }

    fn turn_left(&mut self) {
        let tmp = self.dx;
        self.dx = self.dy;
        self.dy = -tmp;
    }

    fn turn_right(&mut self) {
        let tmp = self.dx;
        self.dx = -self.dy;
        self.dy = tmp;
    }

    fn turn(&mut self, path: char) {
        match (path, self.dx, self.dy) {
            ('\\', 0, _) | ('/', _, 0) => self.turn_left(),
            ('\\', _, 0) | ('/', 0, _) => self.turn_right(),
            ('+', ..) => {
                match self.turn_cycle {
                    0 => self.turn_left(),
                    2 => self.turn_right(),
                    _ => (),
                };
                self.turn_cycle = (self.turn_cycle + 1) % 3;
            }
            _ => panic!("Invalid turn instruction"),
        }
    }
}

fn parse_data<R: BufRead>(reader: R) -> (Vec<Cart>, HashMap<(i32, i32), char>) {
    let mut carts = Vec::new();
    let mut turns = HashMap::new();

    for (row, line) in reader.lines().enumerate() {
        match line {
            Ok(line_content) => {
                for (col, ch) in line_content.char_indices() {
                    match ch {
                        '>' | '<' | '^' | 'v' => {
                            carts.push(create_cart(col as i32, row as i32, ch))
                        }
                        '\\' | '/' | '+' => {
                            turns.insert((col as i32, row as i32), ch);
                        }
                        _ => (),
                    }
                }
            }

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    (carts, turns)
}

fn tick(carts: &mut Vec<Cart>, turns: &HashMap<(i32, i32), char>) -> Option<(i32, i32)> {
    let mut carts_positions = HashSet::new();
    carts.iter().for_each(|cart| {
        carts_positions.insert((cart.x, cart.y));
    });

    carts.sort_by(|a, b| {
        if a.y == b.y {
            a.x.cmp(&b.x)
        } else {
            a.y.cmp(&b.y)
        }
    });
    let mut last_collision_loc = None;
    let ncarts = carts.len();

    for cart_idx in 0..ncarts {
        let cart = &mut carts[cart_idx];
        if cart.destroyed {
            continue;
        }
        carts_positions.remove(&(cart.x, cart.y));
        cart.move_();
        let new_pos = (cart.x, cart.y);
        if let Some(&turn_char) = turns.get(&(new_pos)) {
            cart.turn(turn_char)
        }
        if !carts_positions.insert(new_pos) {
            carts_positions.remove(&new_pos);
            last_collision_loc = Some(new_pos);
            for cart_ in carts.iter_mut() {
                if cart_.x == new_pos.0 && cart_.y == new_pos.1 {
                    cart_.destroyed = true;
                }
            }
        }
    }
    last_collision_loc
}

fn move_until_collision(carts: &mut Vec<Cart>, turns: &HashMap<(i32, i32), char>) -> (i32, i32) {
    loop {
        if let Some(collision_loc) = tick(carts, turns) {
            return collision_loc;
        }
    }
}

fn part1(carts: &Vec<Cart>, turns: &HashMap<(i32, i32), char>) -> String {
    let mut carts_clone = carts.clone();
    let (coli_x, coli_y) = move_until_collision(&mut carts_clone, turns);
    format!("{},{}", coli_x, coli_y)
}

fn part2(carts: &Vec<Cart>, turns: &HashMap<(i32, i32), char>) -> String {
    let mut carts_clone = carts.clone();
    while carts_clone.len() > 1 {
        move_until_collision(&mut carts_clone, turns);
        carts_clone.retain(|cart| !cart.destroyed);
    }
    let Cart {
        x: remaining_x,
        y: remaining_y,
        ..
    } = carts_clone.iter().next().unwrap();
    format!("{},{}", remaining_x, remaining_y)
}

fn main() {
    let _default_file = Some("input/day13.txt");

    let reader = aoc_lib::create_reader(_default_file);
    let (carts, turns) = parse_data(reader);

    println!("Part1: {}", part1(&carts, &turns));
    println!("Part2: {}", part2(&carts, &turns));
}
