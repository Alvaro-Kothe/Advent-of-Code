from collections import deque

JITTERS = [(-1, 0, 0), (0, -1, 0), (0, 0, -1), (1, 0, 0), (0, 1, 0), (0, 0, 1)]

EXAMPLE_DATA = [(1, 1, 1), (2, 1, 1)]


def parse_data(filepath="example.txt"):
    with open(filepath) as file:
        out = set(tuple(map(int, line.split(","))) for line in file.readlines())
    return out


def add_jitter(x, y):
    return tuple(a + b for a, b in zip(x, y))


def create_jitter_set(pos: tuple[int]):
    return set(add_jitter(pos, jit) for jit in JITTERS)


def compute_surface_area(droplets):
    area = 0
    for droplet in droplets:
        for jit in JITTERS:
            if add_jitter(droplet, jit) not in droplets:
                area += 1

    return area


def get_fresh_air(droplets: set[tuple[int]]):
    min_face = (
        min([x[0] for x in droplets]) - 1,
        min([x[1] for x in droplets]) - 1,
        min([x[2] for x in droplets]) - 1,
    )
    max_face = (
        max([x[0] for x in droplets]) + 1,
        max([x[1] for x in droplets]) + 1,
        max([x[2] for x in droplets]) + 1,
    )
    seen = set(min_face)
    queue = deque([min_face])
    while queue:
        cur_pos = queue.popleft()

        candidate_positions = create_jitter_set(cur_pos).difference(seen, droplets)

        next_positions = [
            cp
            for cp in candidate_positions
            if all(a <= x <= b for a, x, b in zip(min_face, cp, max_face))
        ]
        queue.extend(next_positions)
        seen.update(next_positions)

    return seen


def part1():
    data = parse_data("input.txt")
    return compute_surface_area(data)


def part2():
    data = parse_data("input.txt")
    fresh_air_position = get_fresh_air(data)

    return sum(len(create_jitter_set(droplet) & fresh_air_position) for droplet in data)


def simplified_part1():
    data = parse_data("input.txt")
    return sum(len(create_jitter_set(droplet) - data) for droplet in data)


if __name__ == "__main__":
    print(part1())
    print(simplified_part1())
    print(part2())
