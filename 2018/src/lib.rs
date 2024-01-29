use std::io::{self, BufRead};
use std::{env, path};

pub fn create_reader(default_file: Option<&str>) -> Box<dyn BufRead> {
    let args: Vec<String> = env::args().collect();
    let filename = args
        .get(1)
        .map(String::as_str)
        .or_else(|| default_file.filter(|&file_path| path::Path::new(file_path).exists()));

    match filename {
        Some(file) => Box::new(std::io::BufReader::new(
            std::fs::File::open(file).expect("Failed to open file"),
        )),
        None => Box::new(std::io::BufReader::new(io::stdin())),
    }
}
