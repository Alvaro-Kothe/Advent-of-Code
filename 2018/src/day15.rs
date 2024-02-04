use std::{
    cmp::Reverse,
    collections::{BinaryHeap, HashMap, HashSet},
    io::BufRead,
};

const MAX_ELF_AP: i32 = 200;

type Pos = (i32, i32);

#[derive(Debug, Eq, Hash, PartialEq, Clone, Copy)]
enum UnitType {
    Elf,
    Goblin,
}

#[derive(Debug, Clone, Copy)]
struct Unit {
    pos: Pos,
    hp: i32,
    type_: UnitType,
    attack_power: i32,
}

fn parse_data<R: BufRead>(reader: R) -> (Vec<Unit>, HashSet<Pos>) {
    let mut units = Vec::new();
    let mut walls = HashSet::new();

    for (row, line) in reader.lines().enumerate() {
        match line {
            Ok(line_content) => {
                for (col, ch) in line_content.char_indices() {
                    match ch {
                        '#' => {
                            walls.insert((row.try_into().unwrap(), col.try_into().unwrap()));
                        }
                        'E' => units.push(Unit {
                            pos: (row as i32, col as i32),
                            hp: 200,
                            attack_power: 3,
                            type_: UnitType::Elf,
                        }),
                        'G' => units.push(Unit {
                            pos: (row as i32, col as i32),
                            hp: 200,
                            attack_power: 3,
                            type_: UnitType::Goblin,
                        }),
                        '.' => (),
                        _ => panic!(),
                    }
                }
            }
            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    (units, walls)
}

/// Dijkstra algorithm transverse grid from start_pos and get the target
/// with the minimum distance, if there is a tie, consider reading-order.
/// If unreachable returns None. Otherwise, returns the first step to reach the
/// target.
fn move_torwards_target(
    start_pos: &Pos,
    targets: &HashSet<Pos>,
    units: &[Unit],
    walls: &HashSet<Pos>,
) -> Option<Pos> {
    let other_units = units.iter().filter_map(|&unit| {
        if unit.pos == *start_pos || unit.hp <= 0 {
            None
        } else {
            Some(unit.pos)
        }
    });
    let mut blocked_paths = walls.clone();
    blocked_paths.extend(other_units);
    let mut distances = HashMap::from([(*start_pos, (0, None))]);
    let mut queue = BinaryHeap::new();
    queue.push(Reverse((0, *start_pos)));
    let mut reachable_targets = Vec::new();
    let mut min_dist_to_target = usize::MAX;

    while let Some(Reverse((dst, current_pos))) = queue.pop() {
        if targets.contains(&current_pos) && dst <= min_dist_to_target {
            min_dist_to_target = min_dist_to_target.min(dst);
            reachable_targets.push(current_pos);
        }
        if blocked_paths.contains(&current_pos) || dst >= min_dist_to_target {
            continue;
        }

        let next_dst = dst + 1;
        for nb in get_neighbors(&current_pos) {
            let (alt_dst, paren) = distances.entry(nb).or_insert((usize::MAX, None));
            if next_dst < *alt_dst {
                *alt_dst = next_dst;
                *paren = Some(current_pos);
                queue.push(Reverse((next_dst, nb)));
            }
        }
    }

    let target_pos = reachable_targets.into_iter().min_by(|a, b| a.cmp(&b));

    if let Some(mut current) = target_pos {
        while let Some(&(paren_dst, nxt_paren)) = distances.get(&current) {
            if paren_dst.eq(&1) {
                return Some(current);
            } else {
                current = nxt_paren.unwrap()
            }
        }
    }

    None
}

fn get_neighbors(position: &Pos) -> [Pos; 4] {
    let &(x, y) = position;
    [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]
}

fn get_targets(unit_type: &UnitType, units: &[Unit]) -> HashSet<Pos> {
    units
        .iter()
        .filter_map(|other| {
            if other.type_ != *unit_type && other.hp > 0 {
                Some(other.pos)
            } else {
                None
            }
        })
        .collect()
}

fn unit_turn(unit_idx: usize, units: &mut [Unit], walls: &HashSet<Pos>) -> bool {
    let mut unit = units[unit_idx].clone();
    let mut targets_positions = get_targets(&unit.type_, units);
    if unit.hp <= 0 {
        return false;
    }
    if targets_positions.is_empty() {
        return true;
    }

    let target_in_rng = get_neighbors(&unit.pos)
        .into_iter()
        .any(|pos| targets_positions.contains(&pos));

    if !target_in_rng {
        if let Some(new_pos) = move_torwards_target(&unit.pos, &targets_positions, units, walls) {
            unit.pos = new_pos;
        }
    }

    units[unit_idx] = unit;

    //attack
    let cur_nb = get_neighbors(&unit.pos);
    targets_positions.retain(|pos| cur_nb.contains(&pos));
    let target = units
        .iter_mut()
        .filter(|other_unit| targets_positions.contains(&other_unit.pos))
        .min_by(|a, b| a.hp.cmp(&b.hp).then(a.pos.cmp(&b.pos)));
    if let Some(valid_target) = target {
        valid_target.hp -= unit.attack_power;
    }
    false
}

#[derive(PartialEq)]
enum RoundOutcome {
    BattleFinished,
    ElfDied,
    Ongoing,
}

fn round(units: &mut Vec<Unit>, walls: &HashSet<Pos>) -> RoundOutcome {
    units.sort_by(|a, b| a.pos.cmp(&b.pos));
    for i in 0..units.len() {
        let unit_won = unit_turn(i, units, walls);
        if unit_won {
            units.retain(|unit| unit.hp > 0);
            return RoundOutcome::BattleFinished;
        }
    }
    let mut alive_units = Vec::new();
    let mut result = RoundOutcome::Ongoing;

    for unit in units.drain(..) {
        if unit.hp > 0 {
            alive_units.push(unit);
        } else if unit.type_ == UnitType::Elf {
            result = RoundOutcome::ElfDied;
        }
    }

    *units = alive_units;
    result
}

fn part1(units: &Vec<Unit>, walls: &HashSet<Pos>) -> i32 {
    let mut units_copy = units.clone();
    let mut nround = 0;
    while round(&mut units_copy, walls) != RoundOutcome::BattleFinished {
        nround += 1;
    }
    let remaining_hp: i32 = units_copy.into_iter().map(|unit| unit.hp).sum();
    nround * remaining_hp
}

fn part2(units: &Vec<Unit>, walls: &HashSet<Pos>) -> i32 {
    'increase_ap: for elf_ap in 4..=MAX_ELF_AP {
        let mut units_copy = units.clone();
        for unit in units_copy.iter_mut() {
            if unit.type_ == UnitType::Elf {
                unit.attack_power = elf_ap;
            }
        }
        let mut nround = 0;
        loop {
            match round(&mut units_copy, walls) {
                RoundOutcome::BattleFinished
                    if units_copy.first().unwrap().type_ == UnitType::Elf =>
                {
                    let remaining_hp: i32 = units_copy.into_iter().map(|unit| unit.hp).sum();
                    return nround * remaining_hp;
                }
                RoundOutcome::ElfDied | RoundOutcome::BattleFinished => continue 'increase_ap,
                RoundOutcome::Ongoing => nround += 1,
            }
        }
    }
    -1
}

fn main() {
    let _default_file = None;

    let reader = aoc_lib::create_reader(_default_file);
    let (units, walls) = parse_data(reader);

    println!("Part1: {}", part1(&units, &walls));
    println!("Part2: {}", part2(&units, &walls));
}
