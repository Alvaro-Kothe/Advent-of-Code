use std::{
    cmp::Reverse,
    collections::{BinaryHeap, HashMap, HashSet},
    io::BufRead,
};

fn parse_data<R: BufRead>(
    reader: R,
) -> (HashMap<char, HashSet<char>>, HashMap<char, HashSet<char>>) {
    let mut precedences = HashMap::new();
    let mut dependencies = HashMap::new();
    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                let origin = line_content.chars().nth(5).unwrap();
                let target = line_content.chars().nth(36).unwrap();
                let char_vec = precedences.entry(origin).or_insert(HashSet::new());
                char_vec.insert(target);
                let char_vec_dep = dependencies.entry(target).or_insert(HashSet::new());
                char_vec_dep.insert(origin);
            }
            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    (precedences, dependencies)
}

fn get_unlocks<'a>(
    ch: char,
    precedences: &'a HashMap<char, HashSet<char>>,
    requirements: &'a HashMap<char, HashSet<char>>,
    satisfied: &'a HashSet<char>,
) -> Option<impl Iterator<Item = char> + 'a> {
    match precedences.get(&ch) {
        Some(possible_unlocks) => Some(possible_unlocks.iter().filter_map(move |&ch_unlock| {
            if requirements.get(&ch_unlock).unwrap().is_subset(&satisfied) {
                Some(ch_unlock)
            } else {
                None
            }
        })),
        None => None,
    }
}

fn determine_order(
    precedences: &HashMap<char, HashSet<char>>,
    requirements: &HashMap<char, HashSet<char>>,
) -> String {
    let prec_keys: HashSet<_> = precedences.keys().collect();
    let dep_keys: HashSet<_> = requirements.keys().collect();
    let no_dep = prec_keys.difference(&dep_keys);
    let mut que = BinaryHeap::new(); // min-heap
    for &&origin in no_dep {
        que.push(Reverse(origin));
    }
    let mut result = String::new();
    let mut satisfied = HashSet::new();

    while let Some(Reverse(ch)) = que.pop() {
        result.push(ch);
        satisfied.insert(ch);
        if let Some(unlocks) = get_unlocks(ch, precedences, requirements, &satisfied) {
            for unlock in unlocks {
                que.push(Reverse(unlock))
            }
        }
    }
    result
}

#[derive(Debug, Ord, PartialOrd, PartialEq, Eq)]
struct Worker {
    remaining_time: u32,
    task: char,
}

fn task_time(task: char, extra_time: u32) -> u32 {
    1 + extra_time + (task as u8 - b'A') as u32
}

fn free_worker(workers: &mut BinaryHeap<Reverse<Worker>>) -> (char, u32) {
    let Reverse(Worker {
        task,
        remaining_time,
    }) = workers.pop().unwrap();

    let mut tmp = BinaryHeap::new();

    for Reverse(mut worker) in workers.drain() {
        worker.remaining_time -= remaining_time;
        tmp.push(Reverse(worker))
    }

    *workers = tmp;

    (task, remaining_time)
}

fn assign_task(
    task_queue: &mut BinaryHeap<Reverse<char>>,
    workers: &mut BinaryHeap<Reverse<Worker>>,
    nworkers: usize,
    extra_time: u32,
) -> (Option<char>, u32) {
    if let Some(Reverse(top_task)) = task_queue.pop() {
        // there is a task and idle workers
        if workers.len() < nworkers {
            workers.push(Reverse(Worker {
                remaining_time: task_time(top_task, extra_time),
                task: top_task,
            }));
            return (None, 0);
        } else {
            // finish work and assign task
            let (completed_task, time) = free_worker(workers);
            workers.push(Reverse(Worker {
                remaining_time: task_time(top_task, extra_time),
                task: top_task,
            }));
            return (Some(completed_task), time);
        }
    } else {
        // no task remaining, just finish work
        let (completed_task, time) = free_worker(workers);
        return (Some(completed_task), time);
    }
}

fn construction(
    precedences: &HashMap<char, HashSet<char>>,
    requirements: &HashMap<char, HashSet<char>>,
    nworkers: usize,
    extra_time: u32,
) -> u32 {
    let mut workers = BinaryHeap::new();
    let prec_keys: HashSet<_> = precedences.keys().collect();
    let dep_keys: HashSet<_> = requirements.keys().collect();
    let total_tasks = prec_keys.union(&dep_keys).count();
    let mut satisfied = HashSet::new();
    let no_dep = prec_keys.difference(&dep_keys);
    let mut que = BinaryHeap::new(); // min-heap
    for &&origin in no_dep {
        que.push(Reverse(origin));
    }
    let mut time = 0;

    while satisfied.len() < total_tasks {
        let (completed_task, task_time) = assign_task(&mut que, &mut workers, nworkers, extra_time);
        if let Some(finished_task) = completed_task {
            satisfied.insert(finished_task);
            time += task_time;
            if let Some(unlocks) = get_unlocks(finished_task, precedences, requirements, &satisfied)
            {
                for unlock in unlocks {
                    que.push(Reverse(unlock))
                }
            }
        };
    }
    time
}

fn main() {
    let _default_file = Some("input/day00.txt");

    let reader = aoc_lib::create_reader(None);
    let (precedences, requirements) = parse_data(reader);
    let p1 = determine_order(&precedences, &requirements);

    println!("Part1: {}", p1);
    println!(
        "Part2: {}",
        construction(&precedences, &requirements, 5, 60)
    );
}
