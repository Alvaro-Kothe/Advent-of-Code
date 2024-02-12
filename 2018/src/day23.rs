use std::{collections::BinaryHeap, io::BufRead};

type Position = (i32, i32, i32);

fn distance(point1: Position, point2: Position) -> u32 {
    point1.0.abs_diff(point2.0) + point1.1.abs_diff(point2.1) + point1.2.abs_diff(point2.2)
}

#[derive(Debug, Copy, Clone)]
struct Nanobot {
    pos: Position,
    signal_radius: u32,
}

fn parse_data<R: BufRead>(reader: R) -> Vec<Nanobot> {
    let mut bots = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                let parts = line_content
                    .split(&['<', '>', ',', '='])
                    .filter_map(|s| s.parse::<i32>().ok());
                let [x, y, z, r] = parts.collect::<Vec<_>>()[..] else {
                    panic!()
                };
                bots.push(Nanobot {
                    pos: (x, y, z),
                    signal_radius: r as u32,
                })
            }

            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    bots
}

fn find_strongest_nanobot(bots: &[Nanobot]) -> &Nanobot {
    bots.iter().max_by_key(|bot| bot.signal_radius).unwrap()
}

fn count_bot_bot_in_range(bot: &Nanobot, bots: &[Nanobot]) -> usize {
    bots.iter()
        .filter(|&other_bot| distance(bot.pos, other_bot.pos) <= bot.signal_radius)
        .count()
}

fn part1(bots: &[Nanobot]) -> usize {
    let strongest = find_strongest_nanobot(bots);
    count_bot_bot_in_range(strongest, bots)
}

fn part2(bots: &[Nanobot]) -> u32 {
    let ((min_x, min_y, min_z), (max_x, max_y, max_z)) = extrema(bots);
    let center = (
        (max_x + min_x) / 2,
        (max_y + min_y) / 2,
        (max_z + min_z) / 2,
    );
    let strongest = find_strongest_nanobot(bots);
    let highest_range = strongest.signal_radius;
    let largest_distance = (max_x - min_x + max_y - min_y + max_z - min_z) as u32;
    let initial_size = largest_distance + highest_range;
    let mut root = OctreeNode::new(center, initial_size);
    root.insert(bots);
    let best_pos = root.find_best_position(bots);
    distance(best_pos, (0, 0, 0))
}

fn extrema(bots: &[Nanobot]) -> (Position, Position) {
    let (mut min_x, mut min_y, mut min_z) = (i32::MAX, i32::MAX, i32::MAX);
    let (mut max_x, mut max_y, mut max_z) = (i32::MIN, i32::MIN, i32::MIN);
    for bot in bots {
        let (x, y, z) = bot.pos;
        min_x = min_x.min(x);
        min_y = min_y.min(y);
        min_z = min_z.min(z);

        max_x = max_x.max(x);
        max_y = max_y.max(y);
        max_z = max_z.max(z);
    }
    ((min_x, min_y, min_z), (max_x, max_y, max_z))
}

fn main() {
    let _default_file = Some("tst");

    let reader = aoc_lib::create_reader(_default_file);
    let data = parse_data(reader);

    println!("Part1: {}", part1(&data));
    println!("Part2: {}", part2(&data));
}

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
struct BoundBox {
    center: Position,
    half_size: u32,
}

impl BoundBox {
    /// Get closest point to box, if the point is inside the box, it is the point itself,
    /// otherwise it will be one of the edges.
    fn closest_point_to_box(&self, position: Position) -> Position {
        let (x, y, z) = position;
        let (bx, by, bz) = self.center;
        let pos_seq = &[x, y, z];
        let mut closest_coords =
            pos_seq
                .iter()
                .zip([bx, by, bz].into_iter())
                .map(|(&point_coord, box_coord)| {
                    point_coord
                        .max(box_coord - self.half_size as i32)
                        .min(box_coord + self.half_size as i32)
                });
        let cx = closest_coords.next().unwrap();
        let cy = closest_coords.next().unwrap();
        let cz = closest_coords.next().unwrap();
        (cx, cy, cz)
    }
    fn intersects(&self, position: Position, extra_radii: u32) -> bool {
        let closest_point = self.closest_point_to_box(position);
        distance(position, closest_point) <= extra_radii
    }
}

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
struct OctreeNode {
    count: usize,
    bound: BoundBox,
    children: [Option<Box<OctreeNode>>; 8],
}

impl OctreeNode {
    fn new(center: Position, half_size: u32) -> Self {
        Self {
            bound: BoundBox { center, half_size },
            count: 0,
            children: [None, None, None, None, None, None, None, None],
        }
    }

    /// Insert new position maximizing bots in range.
    fn insert(&mut self, bots: &[Nanobot]) {
        let bots_in_box_range = bots
            .iter()
            .filter(|&bot| self.bound.intersects(bot.pos, bot.signal_radius))
            .count();

        let mut best_count = 0;
        let mut queue = BinaryHeap::new();
        queue.push((bots_in_box_range, self));

        while let Some((candidate_count, node)) = queue.pop() {
            if candidate_count <= best_count {
                continue;
            }

            if node.bound.half_size == 0 {
                best_count = best_count.max(candidate_count);
                node.count = best_count;
                continue;
            }

            if node.children.iter().all(Option::is_none) {
                node.split();
            }

            for child_opt in node.children.iter_mut() {
                if let Some(child) = child_opt {
                    let bots_in_child_range = bots
                        .iter()
                        .filter(|&bot| child.bound.intersects(bot.pos, bot.signal_radius))
                        .count();
                    queue.push((bots_in_child_range, child));
                }
            }
        }
    }

    fn split(&mut self) {
        let offsets = [
            (-1, -1, -1),
            (-1, -1, 1),
            (-1, 1, -1),
            (-1, 1, 1),
            (1, -1, -1),
            (1, -1, 1),
            (1, 1, -1),
            (1, 1, 1),
        ];
        let (x, y, z) = self.bound.center;
        let quarter_size = (self.bound.half_size / 4) as i32;
        let new_size = if quarter_size < 1 {
            0
        } else {
            self.bound.half_size / 2
        };
        for ((dx, dy, dz), child) in offsets.into_iter().zip(self.children.iter_mut()) {
            let new_center = (
                x + dx * quarter_size,
                y + dy * quarter_size,
                z + dz * quarter_size,
            );
            *child = Some(Box::new(OctreeNode::new(new_center, new_size)));
            if quarter_size < 1 {
                break;
            }
        }
    }

    fn _find_best_position(
        &self,
        bots: &[Nanobot],
        mut max_count: usize,
        mut best_pos: Position,
    ) -> (usize, Position) {
        if self.count > max_count {
            max_count = self.count;
            best_pos = self.bound.center;
        }
        for child in &self.children {
            if let Some(child) = child {
                let (new_count, new_pos) = child._find_best_position(bots, max_count, best_pos);
                if new_count > max_count {
                    max_count = new_count;
                    best_pos = new_pos;
                }
            }
        }

        (max_count, best_pos)
    }

    fn find_best_position(&self, bots: &[Nanobot]) -> Position {
        let (count, best_pos) = self._find_best_position(bots, 0, (0, 0, 0));
        println!("count: {}", count);
        assert!(count > 0);
        best_pos
    }
}
