use std::{
    collections::HashSet,
    io::BufRead,
    sync::atomic::{AtomicUsize, Ordering},
};

#[derive(Debug, Clone, Copy, PartialEq)]
enum SideType {
    Immune,
    Infection,
}

#[derive(Debug, Clone)]
struct Group {
    uid: usize,
    nunits: usize,
    hp: i64,
    attack_damage: i64,
    attack_type: String,
    initiative: u8,
    weakness: Vec<String>,
    immunities: Vec<String>,
    side: SideType,
    target: Option<usize>,
}

impl Group {
    fn new(
        nunits: usize,
        hp: i64,
        attack_damage: i64,
        attack_type: String,
        initiative: u8,
        weakness: Vec<String>,
        immunities: Vec<String>,
        side: SideType,
    ) -> Self {
        static NEXT_ID: AtomicUsize = AtomicUsize::new(0);
        let uid = NEXT_ID.fetch_add(1, Ordering::Relaxed);
        Self {
            uid,
            nunits,
            hp,
            attack_damage,
            attack_type,
            initiative,
            weakness,
            immunities,
            side,
            target: None,
        }
    }

    fn effective_power(&self) -> i64 {
        (self.nunits as i64) * self.attack_damage
    }

    fn compute_damage(&self, other: &Self) -> i64 {
        if other.immunities.contains(&self.attack_type) {
            0
        } else if other.weakness.contains(&self.attack_type) {
            2 * self.effective_power()
        } else {
            self.effective_power()
        }
    }
}

fn parse_data<R: BufRead>(reader: R) -> Vec<Group> {
    let mut groups = Vec::new();
    let mut current_side = SideType::Immune;

    let mut lines = reader.lines();

    while let Some(line) = lines.next() {
        match line {
            Ok(line_content) => {
                if line_content.starts_with("Immune") {
                    current_side = SideType::Immune;
                } else if line_content.starts_with("Infection") {
                    current_side = SideType::Infection;
                } else if !line_content.is_empty() {
                    groups.push(parse_line(line_content, &current_side));
                }
            }

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    groups
}

fn parse_line(str: String, side: &SideType) -> Group {
    let mut iter = str.split_whitespace();
    let nunits = iter.next().unwrap().parse().unwrap();
    let hp = iter.find_map(|s| s.parse().ok()).unwrap();
    let mut immunities = Vec::new();
    let mut weakness = Vec::new();

    //parenthesis
    let next_word = iter.nth(2).unwrap();
    if next_word.starts_with("(weak") {
        weakness = iterate_inside_parenthesis(&mut iter)
    } else if next_word.starts_with("(immune") {
        immunities = iterate_inside_parenthesis(&mut iter)
    }
    let next_word = iter.next().unwrap();
    match next_word {
        "weak" => weakness = iterate_inside_parenthesis(&mut iter),
        "immune" => immunities = iterate_inside_parenthesis(&mut iter),
        _ => (),
    }
    let attack_damage = iter.find_map(|s| s.parse().ok()).unwrap();
    let attack_type = iter.next().unwrap().to_string();
    let initiative = iter.find_map(|s| s.parse().ok()).unwrap();
    Group::new(
        nunits,
        hp,
        attack_damage,
        attack_type,
        initiative,
        weakness,
        immunities,
        *side,
    )
}

fn iterate_inside_parenthesis<'a, I>(iter: &mut I) -> Vec<String>
where
    I: Iterator<Item = &'a str>,
{
    let mut result = Vec::new();
    while let Some(s) = iter.next() {
        if s.ends_with(',') {
            result.push(s[..s.len() - 1].to_string())
        } else if s.ends_with(';') || s.ends_with(')') {
            result.push(s[..s.len() - 1].to_string());
            break;
        }
    }
    result
}

fn select_targets(groups: &mut [Group]) {
    groups.sort_by(|a, b| {
        b.effective_power()
            .cmp(&a.effective_power())
            .then(b.initiative.cmp(&a.initiative))
    });

    let mut chosen = HashSet::new();

    for i in 0..groups.len() {
        let this_side = groups[i].side;
        let enemies = groups
            .iter()
            .filter(|&other| other.side != this_side && !chosen.contains(&other.uid));
        let target = enemies.max_by(|a, b| {
            groups[i]
                .compute_damage(&a)
                .cmp(&groups[i].compute_damage(b))
                .then(a.effective_power().cmp(&b.effective_power()))
                .then(a.initiative.cmp(&b.initiative))
        });

        if let Some(target) = target {
            let damage = groups[i].compute_damage(target);
            if damage > 0 {
                chosen.insert(target.uid);
                groups[i].target = Some(target.uid);
            }
        }
    }
}

fn attack_targets(groups: &mut [Group]) {
    groups.sort_by(|a, b| b.initiative.cmp(&a.initiative));

    for i in 0..groups.len() {
        if groups[i].nunits <= 0 {
            continue;
        }
        if let Some(target_id) = groups[i].target {
            let damage =
                groups[i].compute_damage(groups.iter().find(|g| g.uid == target_id).unwrap());
            if let Some(target) = groups.iter_mut().find(|grp| grp.uid == target_id) {
                let units_lost = target.nunits.min((damage / target.hp) as usize);
                target.nunits -= units_lost;
            }
        }
        groups[i].target = None;
    }
}

/// Return false if the battle ended (or finished in a draw). Otherwise return true
fn fight(groups: &mut Vec<Group>) -> bool {
    let starting_units = count_units(groups);
    select_targets(groups);
    attack_targets(groups);
    groups.retain(|grp| grp.nunits > 0);
    let remaining_units = count_units(groups);
    starting_units != remaining_units
}

fn fight_until_end(groups: &[Group]) -> Vec<Group> {
    let mut groups = groups.to_vec();

    while fight(&mut groups) {}
    groups
}

fn count_units(groups: &[Group]) -> usize {
    groups.into_iter().map(|grp| grp.nunits).sum()
}

fn part1(groups: &[Group]) -> usize {
    let groups = fight_until_end(groups);
    groups.into_iter().map(|grp| grp.nunits).sum()
}

fn apply_boost(groups: &mut [Group], boost: i64) {
    for grp in groups.iter_mut() {
        if grp.side == SideType::Immune {
            grp.attack_damage += boost;
        }
    }
}

fn find_best_boost(groups: &[Group], min_boost: i64, max_boost: i64) -> i64 {
    if min_boost == max_boost {
        return min_boost;
    }
    let mid_boost = (min_boost + max_boost) / 2;
    let mut mid_boost_group = groups.to_vec();
    apply_boost(&mut mid_boost_group, mid_boost);
    mid_boost_group = fight_until_end(&mid_boost_group);
    let immune_won = mid_boost_group
        .into_iter()
        .all(|grp| grp.side == SideType::Immune);
    if immune_won {
        find_best_boost(groups, min_boost, mid_boost) // if mid - 1 it may skip the correct result
    } else {
        find_best_boost(groups, mid_boost + 1, max_boost)
    }
}

fn part2(groups: &[Group]) -> usize {
    let min_boost = 0;
    let max_boost = 0xffffffff;
    let boost = find_best_boost(groups, min_boost, max_boost);
    let mut groups_boost = groups.to_vec();
    apply_boost(&mut groups_boost, boost);
    groups_boost = fight_until_end(&groups_boost);
    let immune_won = groups_boost.iter().all(|grp| grp.side == SideType::Immune);
    assert!(immune_won);
    count_units(&groups_boost)
}

fn main() {
    let _default_file = Some("input/day24.txt");

    let reader = aoc_lib::create_reader(_default_file);
    let data = parse_data(reader);

    println!("Part1: {}", part1(&data));
    println!("Part2: {}", part2(&data));
}
