use std::io::BufRead;

const MAX_HEIGHT: i32 = 15;
const MAX_WIDTH: i32 = 80;
const MAX_ITERATIONS: usize = 0xffff;

struct Particle {
    position: (i32, i32),
    velocity: (i32, i32),
}

fn get_position_at(particle: &Particle, t: i32) -> (i32, i32) {
    (
        particle.position.0 + particle.velocity.0 * t,
        particle.position.1 + particle.velocity.1 * t,
    )
}

fn parse_data<R: BufRead>(reader: R) -> Vec<Particle> {
    let mut points = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line_content) => {
                let parts: Vec<_> = line_content
                    .trim()
                    .split(&['>', '<', ' ', ','])
                    .filter_map(|s| s.parse().ok())
                    .collect();
                if parts.len() < 4 {
                    continue;
                }
                points.push(Particle {
                    position: (parts[0], parts[1]),
                    velocity: (parts[2], parts[3]),
                });
            }
            Err(err) => eprintln!("Error reading line: {}", err),
        }
    }
    points
}

fn get_readable_particles_time(particles: &Vec<Particle>) -> Option<usize> {
    for t in 0..MAX_ITERATIONS {
        let mut minx = i32::MAX;
        let mut maxx = i32::MIN;
        let mut miny = i32::MAX;
        let mut maxy = i32::MIN;

        for particle in particles.iter() {
            let new_pos = get_position_at(particle, t.try_into().unwrap());
            minx = minx.min(new_pos.0);
            maxx = maxx.max(new_pos.0);
            miny = miny.min(new_pos.1);
            maxy = maxy.max(new_pos.1);
        }

        if (maxx - minx) <= MAX_WIDTH && (maxy - miny) <= MAX_HEIGHT {
            return Some(t);
        }
    }
    None
}

fn display_particles(particles: &Vec<Particle>, second: i32) {
    let positions = particles.iter().map(|part| get_position_at(part, second));

    let (xmin, xmax, ymin, ymax) = positions.clone().fold(
        (i32::MAX, i32::MIN, i32::MAX, i32::MIN),
        |(xmin, xmax, ymin, ymax), (x, y)| (xmin.min(x), xmax.max(x), ymin.min(y), ymax.max(y)),
    );

    let width = (xmax - xmin + 1) as usize;
    let height = (ymax - ymin + 1) as usize;

    let mut grid = vec![vec![' '; width]; height];
    for (x, y) in positions {
        let grid_x = (x - xmin) as usize;
        let grid_y = (y - ymin) as usize;
        grid[grid_y][grid_x] = '#';
    }

    for row in grid {
        for ch in row {
            print!("{}", ch);
        }
        println!();
    }
}

fn main() {
    let reader = aoc_lib::create_reader(None);
    let data = parse_data(reader);
    let time = get_readable_particles_time(&data).unwrap();

    println!("Part1:");
    display_particles(&data, time as i32);
    println!("Part2: {}", time);
}
