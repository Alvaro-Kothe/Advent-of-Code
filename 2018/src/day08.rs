use std::io::BufRead;

fn parse_data<R: BufRead>(reader: R) -> Vec<i32> {
    let mut numbers: Vec<i32> = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                let line_values = line_content
                    .split_whitespace()
                    .map(|s| s.parse::<i32>().unwrap());
                numbers.extend(line_values);
            }

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    numbers
}

struct Node {
    header: (usize, usize),
    child: Vec<Node>,
    metadata: Vec<i32>,
}

fn create_tree<I>(iter: &mut I) -> Node
where
    I: Iterator<Item = i32>,
{
    if let Some(nchild) = iter.next() {
        let nmetadata = iter.next().unwrap();
        let mut child = Vec::new();
        let mut metadata = Vec::new();

        for _ in 0..nchild {
            child.push(create_tree(iter));
        }
        for _ in 0..nmetadata {
            metadata.push(iter.next().unwrap())
        }

        Node {
            header: (nchild as usize, nmetadata as usize),
            child,
            metadata,
        }
    } else {
        // recursion base case
        Node {
            header: (0, 0),
            child: vec![],
            metadata: vec![],
        }
    }
}

fn sum_metadata(node: &Node) -> i32 {
    let this_metadata: i32 = node.metadata.iter().sum();
    let child_metadata = node
        .child
        .iter()
        .fold(0, |acc, child| acc + sum_metadata(child));
    this_metadata + child_metadata
}

fn sum_metadata2(node: &Node) -> i32 {
    let nchild = node.header.0;
    if nchild == 0 {
        return node.metadata.iter().sum();
    }
    let mut result = 0;
    for child_idxp1 in node.metadata.iter() {
        let child_idx = (child_idxp1 - 1) as usize;
        if child_idx < nchild {
            result += sum_metadata2(&node.child[child_idx]);
        }
    }
    result
}

fn main() {
    let _default_file = Some("input/day00.txt");

    let reader = aoc_lib::create_reader(None);
    let data = parse_data(reader);
    let mut data_iterator = data.into_iter();
    let root = create_tree(&mut data_iterator);

    println!("Part1: {}", sum_metadata(&root));
    println!("Part2: {}", sum_metadata2(&root));
}
