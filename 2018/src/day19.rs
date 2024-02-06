use core::panic;
use std::io::BufRead;

#[derive(Debug)]
struct Instruction {
    op: String,
    a: usize,
    b: usize,
    c: usize,
}

const MAX_REPEAT: usize = 0xf;

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

fn run_program_until_reg4_loop(
    instructions: &[Instruction],
    ip_register: &usize,
    register: &mut [usize],
) {
    let mut counter = 0;
    let mut prev_reg4 = 0;
    while let Some(instruction) = register
        .get(*ip_register)
        .and_then(|ip| instructions.get(*ip))
    {
        apply_instruction(instruction, register);
        register[*ip_register] += 1;
        if prev_reg4 == register[4] {
            counter += 1;
            if counter > MAX_REPEAT {
                return;
            }
        } else {
            prev_reg4 = register[4];
            counter = 0;
        }
    }
}

fn div_sum(n: usize) -> usize {
    if n <= 1 {
        return n;
    }
    let mut result = 0;
    let nsqrt = (n as f64).sqrt() as usize;

    for i in 2..=nsqrt {
        if n % i == 0 {
            if i == (n / i) {
                result += i;
            } else {
                result += i + (n / i);
            }
        }
    }
    result + 1 + n
}

fn part1(instructions: &[Instruction], ip_register: &usize) -> usize {
    let mut register = [0; 6];
    run_program_until_reg4_loop(instructions, ip_register, &mut register);
    div_sum(register[4])
}

fn part2(instructions: &[Instruction], ip_register: &usize) -> usize {
    let mut register = [0; 6];
    register[0] = 1;
    run_program_until_reg4_loop(instructions, ip_register, &mut register);
    div_sum(register[4])
}

fn main() {
    let _default_file = Some("input/day00.txt");

    let reader = aoc_lib::create_reader(None);
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
