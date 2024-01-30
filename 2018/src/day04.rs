use std::{collections::HashMap, io::BufRead};

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
struct Timestamp {
    year: u32,
    month: u32,
    day: u32,
    hour: u32,
    minute: u32,
}

#[derive(Debug)]
struct Record {
    timestamp: Timestamp,
    record: String,
}

fn parse_record(str: String) -> Record {
    let (time, record) = str.split_once("] ").unwrap();
    let time_items: Vec<u32> = time
        .split(&['[', ' ', '-', ':'])
        .filter(|s| !s.is_empty())
        .map(|s| s.parse().unwrap())
        .collect();
    Record {
        timestamp: Timestamp {
            year: time_items[0],
            month: time_items[1],
            day: time_items[2],
            hour: time_items[3],
            minute: time_items[4],
        },
        record: record.to_string(),
    }
}

fn parse_data<R: BufRead>(reader: R) -> Vec<Record> {
    let mut records: Vec<Record> = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => records.push(parse_record(line_content)),

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    records.sort_by(|a, b| a.timestamp.cmp(&b.timestamp));
    records
}

fn get_guard_id(str: String) -> u32 {
    let gid: String = str.split(' ').filter(|s| s.starts_with('#')).collect();
    gid[1..gid.len()].parse().unwrap()
}

fn guard_sleep_times(records: Vec<Record>) -> (HashMap<u32, u32>, HashMap<u32, [u32; 60]>) {
    let mut guard_total_sleep_time: HashMap<u32, u32> = HashMap::new();
    let mut guard_minute_times: HashMap<u32, [u32; 60]> = HashMap::new();
    let mut guard_id = 0u32;
    let mut start_time = 0u32;

    for record in records.iter() {
        if record.record.starts_with("Guard #") {
            guard_id = get_guard_id(record.record.clone());
        } else if record.record.eq("falls asleep") {
            start_time = record.timestamp.minute;
        } else if record.record.eq("wakes up") {
            let guard_sleep_time = guard_total_sleep_time.entry(guard_id).or_insert(0);
            *guard_sleep_time += record.timestamp.minute - start_time;
            for minute in start_time..record.timestamp.minute {
                guard_minute_times
                    .entry(guard_id)
                    .and_modify(|v| v[minute as usize] += 1)
                    .or_insert([0; 60]);
            }
        }
    }
    (guard_total_sleep_time, guard_minute_times)
}

fn strategy1(guard_total: HashMap<u32, u32>, guard_minutes: HashMap<u32, [u32; 60]>) -> (u32, u32) {
    let best_guard = guard_total
        .iter()
        .max_by_key(|&(_, &v)| v)
        .map(|(k, _)| k)
        .unwrap();
    let best_guard_minutes = guard_minutes.get(&best_guard).unwrap();
    let best_minute = best_guard_minutes
        .iter()
        .enumerate()
        .max_by_key(|&(_, &v)| v)
        .map(|(idx, _)| idx)
        .unwrap();
    (*best_guard, best_minute.try_into().unwrap())
}

fn strategy2(guard_minutes: HashMap<u32, [u32; 60]>) -> (u32, u32) {
    let mut best_guard = 0u32;
    let mut best_minute = 0usize;
    let mut max_asleep = 0u32;
    for (guard, asleep_arr) in guard_minutes.iter() {
        for (minute, sleep_time) in asleep_arr.iter().enumerate() {
            if sleep_time > &max_asleep {
                max_asleep = *sleep_time;
                best_guard = *guard;
                best_minute = minute;
            }
        }
    }
    (best_guard, best_minute.try_into().unwrap())
}

fn main() {
    let _default_file = Some("input/day04.txt");

    let reader = aoc_lib::create_reader(_default_file);
    let data = parse_data(reader);

    let (total_sleep, minutes) = guard_sleep_times(data);
    let (st1_guard, st1_minute) = strategy1(total_sleep, minutes.clone());
    let (st2_guard, st2_minute) = strategy2(minutes);

    println!("Part1: {}", st1_guard * st1_minute);
    println!("Part2: {}", st2_guard * st2_minute);
}
