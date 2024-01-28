use std::io::{self, BufRead};
use std::{env, path};

pub fn create_reader(default_file: &str) -> Box<dyn BufRead> {
    let args: Vec<String> = env::args().collect();
    let filename = if args.len() > 1 {
        Some(args[1].as_str())
    } else if path::Path::new(default_file).exists() {
        Some(default_file)
    } else {
        None
    };

    match filename {
        Some(file) => Box::new(std::io::BufReader::new(
            std::fs::File::open(file).expect("Failed to open file"),
        )),
        None => Box::new(std::io::BufReader::new(io::stdin())),
    }
}
