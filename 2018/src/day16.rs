use std::{collections::HashSet, io::BufRead};

#[derive(Debug)]
struct Sample {
    before: Vec<usize>,
    instruction: Vec<usize>,
    after: Vec<usize>,
}
fn parse_data<R: BufRead>(mut reader: R) -> (Vec<Sample>, Vec<Vec<usize>>) {
    let mut samples = Vec::new();
    let mut tests = Vec::new();

    let mut buffer = String::new();
    let _ = reader.read_to_string(&mut buffer);
    if let Some((samples_str, tets_str)) = buffer.split_once("\n\n\n") {
        let samples_iter = samples_str.split("\n\n").map(|s| {
            s.split('\n').map(|values| {
                values
                    .split(&[',', ' ', '[', ']'])
                    .filter_map(|num| num.parse::<usize>().ok())
            })
        });
        for mut subsample in samples_iter {
            let before: Vec<_> = subsample.next().unwrap().collect();
            let instruction: Vec<_> = subsample.next().unwrap().collect();
            let after: Vec<_> = subsample.next().unwrap().collect();
            samples.push(Sample {
                before,
                instruction,
                after,
            })
        }

        tests = tets_str
            .trim()
            .split('\n')
            .map(|line| {
                line.trim()
                    .split_whitespace()
                    .filter_map(|v| v.parse().ok())
                    .collect()
            })
            .collect();
    }
    (samples, tests)
}

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy)]
enum Operations {
    Addr,
    Addi,
    Mulr,
    Muli,
    Banr,
    Bani,
    Borr,
    Bori,
    Setr,
    Seti,
    Gtir,
    Gtri,
    Gtrr,
    Eqir,
    Eqri,
    Eqrr,
}

const ALL_OPERATIONS: [Operations; 16] = [
    Operations::Addr,
    Operations::Addi,
    Operations::Mulr,
    Operations::Muli,
    Operations::Banr,
    Operations::Bani,
    Operations::Borr,
    Operations::Bori,
    Operations::Setr,
    Operations::Seti,
    Operations::Gtir,
    Operations::Gtri,
    Operations::Gtrr,
    Operations::Eqir,
    Operations::Eqri,
    Operations::Eqrr,
];

fn test_sample<'a, I>(
    before: &[usize],
    instruction: &[usize],
    after: &[usize],
    operations: I,
) -> Vec<Operations>
where
    I: Iterator<Item = &'a Operations>,
{
    let mut result = Vec::new();
    let a = instruction[1];
    let b = instruction[2];
    let c = instruction[3];
    for op in operations {
        let mut register = before.to_vec();
        match_function(*op, &mut register, a, b, c);
        if register == after {
            result.push(*op);
        }
    }
    result
}

fn part1(samples: &[Sample]) -> usize {
    let mut result = 0;
    for Sample {
        before,
        instruction,
        after,
    } in samples
    {
        if test_sample(before, instruction, after, ALL_OPERATIONS.iter()).len() >= 3 {
            result += 1;
        }
    }
    result
}

fn determine_opcodes(samples: &[Sample]) -> Result<Vec<Operations>, &str> {
    let mut opcode_map = Vec::new();
    let mut hashset_full: HashSet<Operations> = HashSet::new();
    for op in ALL_OPERATIONS {
        hashset_full.insert(op);
    }
    for _ in 0..ALL_OPERATIONS.len() {
        opcode_map.push(hashset_full.clone())
    }
    let mut found_idx = HashSet::new();

    for Sample {
        before,
        instruction,
        after,
    } in samples
    {
        if found_idx.len() == ALL_OPERATIONS.len() {
            break;
        }
        let opcode = instruction[0];
        if found_idx.contains(&opcode) {
            continue;
        }

        let possible_operations =
            test_sample(before, instruction, after, opcode_map[opcode].iter());
        opcode_map[opcode].retain(|op| possible_operations.contains(&op));

        if opcode_map[opcode].len() == 1 {
            mark_as_found(opcode, &mut opcode_map, &mut found_idx);
        }
    }
    if found_idx.len() == ALL_OPERATIONS.len() {
        Ok(opcode_map
            .into_iter()
            .flat_map(|set| set.into_iter())
            .collect())
    } else {
        Err("Could not determine opcode")
    }
}

fn mark_as_found(
    opcode: usize,
    opcode_map: &mut [HashSet<Operations>],
    found_idx: &mut HashSet<usize>,
) {
    let op_found = opcode_map[opcode].iter().next().unwrap().clone();
    found_idx.insert(opcode);

    for idx in 0..opcode_map.len() {
        if found_idx.contains(&idx) {
            continue;
        }
        opcode_map[idx].retain(|&op| op != op_found);
        if opcode_map[idx].len() == 1 {
            mark_as_found(idx, opcode_map, found_idx);
        }
    }
}

fn part2(samples: &[Sample], tests: &[Vec<usize>]) -> usize {
    let opcode_map = determine_opcodes(samples).unwrap();
    let mut register = [0; 4];
    for instruction in tests {
        let opcode = instruction[0];
        let a = instruction[1];
        let b = instruction[2];
        let c = instruction[3];
        let op = opcode_map[opcode];
        match_function(op, &mut register, a, b, c);
    }
    register[0]
}

fn main() {
    let _default_file = Some("input/day16.txt");

    let reader = aoc_lib::create_reader(_default_file);
    let (samples, tests) = parse_data(reader);

    println!("Part1: {}", part1(&samples));
    println!("Part2: {}", part2(&samples, &tests));
}

fn match_function(op: Operations, register: &mut [usize], a: usize, b: usize, c: usize) {
    match op {
        Operations::Addr => addr(register, a, b, c),
        Operations::Addi => addi(register, a, b, c),
        Operations::Mulr => mulr(register, a, b, c),
        Operations::Muli => muli(register, a, b, c),
        Operations::Banr => banr(register, a, b, c),
        Operations::Bani => bani(register, a, b, c),
        Operations::Borr => borr(register, a, b, c),
        Operations::Bori => bori(register, a, b, c),
        Operations::Setr => setr(register, a, b, c),
        Operations::Seti => seti(register, a, b, c),
        Operations::Gtir => gtir(register, a, b, c),
        Operations::Gtri => gtri(register, a, b, c),
        Operations::Gtrr => gtrr(register, a, b, c),
        Operations::Eqir => eqir(register, a, b, c),
        Operations::Eqri => eqri(register, a, b, c),
        Operations::Eqrr => eqrr(register, a, b, c),
    }
}

fn addr(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = register[a] + register[b]
}

fn addi(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = register[a] + b
}

fn mulr(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = register[a] * register[b]
}

fn muli(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = register[a] * b
}

fn banr(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = register[a] & register[b]
}

fn bani(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = register[a] & b
}

fn borr(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = register[a] | register[b]
}

fn bori(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = register[a] | b
}

fn setr(register: &mut [usize], a: usize, _b: usize, c: usize) {
    register[c] = register[a]
}

fn seti(register: &mut [usize], a: usize, _b: usize, c: usize) {
    register[c] = a
}

fn gtir(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = (a > register[b]) as usize
}

fn gtri(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = (register[a] > b) as usize
}

fn gtrr(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = (register[a] > register[b]) as usize
}

fn eqir(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = (a == register[b]) as usize
}

fn eqri(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = (register[a] == b) as usize
}

fn eqrr(register: &mut [usize], a: usize, b: usize, c: usize) {
    register[c] = (register[a] == register[b]) as usize
}
