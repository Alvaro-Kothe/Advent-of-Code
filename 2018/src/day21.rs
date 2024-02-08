use std::{collections::HashSet, io::BufRead};

#[derive(Debug)]
struct Instruction {
    op: String,
    a: usize,
    b: usize,
    c: usize,
}

fn parse_data<R: BufRead>(reader: R) -> (usize, Vec<Instruction>) {
    let mut ip_reg = 0;
    let mut instructions = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                if line_content.starts_with('#') {
                    ip_reg = line_content
                        .split_whitespace()
                        .find_map(|s| s.parse().ok())
                        .unwrap();
                } else {
                    let mut lc_iter = line_content.split_whitespace();
                    let op = lc_iter.next().unwrap().to_string();
                    let [a, b, c] = lc_iter.map(|s| s.parse().unwrap()).collect::<Vec<_>>()[..]
                    else {
                        panic!()
                    };
                    instructions.push(Instruction { op, a, b, c })
                }
            }

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    (ip_reg, instructions)
}

fn apply_instruction(instruction: &Instruction, register: &mut [usize]) {
    let Instruction { op, a, b, c } = instruction;
    match_function(&op, register, *a, *b, *c);
}

fn solve_part1(instructions: &[Instruction], ip_register: &usize, register: &mut [usize]) -> usize {
    // Unique line in input that uses register 0:
    // eqrr 3 0 5
    // addr 5 2 2
    // if value at register 0 is equal to value at register 3 set register 5 to 1.
    // then increment the ip and execute addr
    // (29 + 1) + 1 = 31 -> oob -> halts
    loop {
        let ip = register[*ip_register];
        let Instruction { op, a, b, .. } = &instructions[ip];
        if op.ends_with("rr") && (*a == 0 || *b == 0) {
            return if *a == 0 { register[*b] } else { register[*a] };
        }
        apply_instruction(&instructions[ip], register);
        register[*ip_register] += 1;
    }
}

fn part1(instructions: &[Instruction], ip_register: &usize) -> usize {
    let mut register = [0; 6];
    solve_part1(instructions, ip_register, &mut register)
}

fn part2(instructions: &[Instruction], ip_register: &usize) -> usize {
    let mut register = [0; 6];
    let mut seen = HashSet::new();
    let mut last = 0;
    while register[*ip_register] < instructions.len() {
        let ip = register[*ip_register];
        let Instruction { op, a, b, .. } = &instructions[ip];
        if op.ends_with("rr") && (*a == 0 || *b == 0) {
            let non_zero_reg_val = if *a == 0 { register[*b] } else { register[*a] };
            if seen.insert(non_zero_reg_val) {
                last = non_zero_reg_val;
            } else {
                return last;
            }
        }

        apply_instruction(&instructions[ip], &mut register);
        register[*ip_register] += 1;
    }
    last
}

fn main() {
    let _default_file = Some("input/day21.txt");

    let reader = aoc_lib::create_reader(_default_file);
    let (ip_reg, instructions) = parse_data(reader);

    println!("Part1: {}", part1(&instructions, &ip_reg));
    println!("Part2: {}", part2(&instructions, &ip_reg));
}

fn match_function(op: &str, register: &mut [usize], a: usize, b: usize, c: usize) {
    match op {
        "addr" => addr(register, a, b, c),
        "addi" => addi(register, a, b, c),
        "mulr" => mulr(register, a, b, c),
        "muli" => muli(register, a, b, c),
        "banr" => banr(register, a, b, c),
        "bani" => bani(register, a, b, c),
        "borr" => borr(register, a, b, c),
        "bori" => bori(register, a, b, c),
        "setr" => setr(register, a, b, c),
        "seti" => seti(register, a, b, c),
        "gtir" => gtir(register, a, b, c),
        "gtri" => gtri(register, a, b, c),
        "gtrr" => gtrr(register, a, b, c),
        "eqir" => eqir(register, a, b, c),
        "eqri" => eqri(register, a, b, c),
        "eqrr" => eqrr(register, a, b, c),
        _ => panic!(),
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

fn _run_program(instructions: &[Instruction], ip_register: &usize, register: &mut [usize]) {
    while let Some(instruction) = register
        .get(*ip_register)
        .and_then(|ip| instructions.get(*ip))
    {
        apply_instruction(instruction, register);
        register[*ip_register] += 1;
    }
}
