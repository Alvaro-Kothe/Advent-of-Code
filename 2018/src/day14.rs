use std::io::BufRead;

fn parse_data<R: BufRead>(reader: R) -> Result<Vec<usize>, &'static str> {
    for line in reader.lines() {
        if let Ok(line_content) = line {
            return Ok(str_to_digits(line_content));
        }
    }
    Err("Couldn't parse buffer")
}

fn str_to_digits(s: String) -> Vec<usize> {
    let mut out = Vec::new();
    for ch in s.chars() {
        out.push(ch.to_digit(10).unwrap() as usize);
    }
    out
}

fn vec_digits_to_number(digits: &Vec<usize>) -> usize {
    digits.iter().fold(0, |acc, &digit| acc * 10 + digit)
}

fn create_recipe(score1: usize, score2: usize) -> Vec<usize> {
    let mut out = Vec::new();
    let mut value = score1 + score2;
    if value == 0 {
        return vec![value];
    }

    while value > 0 {
        out.push(value % 10);
        value /= 10;
    }
    out.reverse();
    out
}

fn generate_new_recipe(recipes: &mut Vec<usize>, elf1: &mut usize, elf2: &mut usize) -> Vec<usize> {
    let rec1 = recipes[*elf1];
    let rec2 = recipes[*elf2];
    let new_scores = create_recipe(rec1, rec2);
    recipes.extend(new_scores.iter());
    let nrecipes = recipes.len();
    *elf1 = (*elf1 + rec1 + 1) % nrecipes;
    *elf2 = (*elf2 + rec2 + 1) % nrecipes;
    new_scores
}

fn extend_recipes(recipes: &mut Vec<usize>, elf1: &mut usize, elf2: &mut usize, amount: usize) {
    while recipes.len() < amount {
        generate_new_recipe(recipes, elf1, elf2);
    }
}

fn get_score(recipes: &Vec<usize>, after: usize, amount: usize) -> String {
    let mut score = String::new();
    for i in 0..amount {
        score.push_str(&recipes[after + i].to_string())
    }
    score
}

fn part1(scores_after: usize) -> String {
    let mut recipes = vec![3, 7];
    let mut elf1 = 0;
    let mut elf2 = 1;
    let amount = 10;
    extend_recipes(&mut recipes, &mut elf1, &mut elf2, scores_after + amount);
    get_score(&recipes, scores_after, amount)
}

fn is_sequence_present(current_sequence: &mut Vec<usize>, sequence: &Vec<usize>) -> bool {
    let cur_size = current_sequence.len();
    let compare_size = sequence.len();
    if cur_size < compare_size {
        return false;
    }
    let is_present = current_sequence
        .windows(compare_size)
        .any(|window| window == sequence);
    if !is_present {
        let size_diff = current_sequence.len() - sequence.len();
        *current_sequence = current_sequence.split_off(size_diff);
    }
    is_present
}

fn extend_recipes_until_appearance(
    recipes: &mut Vec<usize>,
    elf1: &mut usize,
    elf2: &mut usize,
    sequence: &Vec<usize>,
) -> usize {
    let mut cur_sequence = recipes.clone();
    while !is_sequence_present(&mut cur_sequence, sequence) {
        let extension = generate_new_recipe(recipes, elf1, elf2);
        cur_sequence.extend(extension.iter());
    }
    recipes
        .windows(sequence.len())
        .position(|window| window == sequence)
        .unwrap()
}

fn part2(sequence: &Vec<usize>) -> usize {
    let mut recipes = vec![3, 7];
    let mut elf1 = 0;
    let mut elf2 = 1;
    extend_recipes_until_appearance(&mut recipes, &mut elf1, &mut elf2, &sequence)
}

fn main() {
    let _default_input = Some("286051".to_string());

    let sequence = if let Some(inp) = _default_input {
        str_to_digits(inp)
    } else {
        let reader = aoc_lib::create_reader(None);
        parse_data(reader).unwrap()
    };

    let scores_after = vec_digits_to_number(&sequence);

    println!("Part1: {}", part1(scores_after));
    println!("Part2: {}", part2(&sequence));
}
