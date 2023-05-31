ROCKS = [
    [0, 1, 2, 3],
    [1, 1j, 1 + 1j, 2 + 1j, 1 + 2j],
    [0, 1, 2, 2 + 1j, 2 + 2j],
    [0, 1j, 2j, 3j],
    [0, 1, 1j, 1 + 1j],
]


def parse_data(filepath="input.txt"):
    with open(filepath) as file:
        return [1 if ch == ">" else -1 for ch in file.read()]


def simulate(n_rocks, hot_gas_data):
    ground_width = 7
    height = 0

    blocked_positions = {x + (height - 1) * 1j for x in range(ground_width)}

    cache = {}

    rock_idx = jet_idx = 0

    for i in range(n_rocks):
        rock = [x + 2 + (height + 3) * 1j for x in ROCKS[rock_idx]]
        rock_idx = (rock_idx + 1) % len(ROCKS)

        key = rock_idx, jet_idx
        if key in cache:
            cached_step, cached_height = cache[key]
            remaining_rocks = n_rocks - i
            steps_since_cache = i - cached_step

            div, rem = divmod(remaining_rocks, steps_since_cache)
            is_cycle = rem == 0
            if is_cycle:
                return int(height + (height - cached_height) * div)
        else:
            cache[key] = i, height

        while True:
            jet = hot_gas_data[jet_idx]
            jet_idx = (jet_idx + 1) % len(hot_gas_data)

            moved_rock = [x + jet for x in rock]
            if all(
                0 <= x.real < 7 for x in moved_rock
            ) and not blocked_positions.intersection(moved_rock):
                rock = moved_rock

            moved_rock = [x - 1j for x in rock]

            if not blocked_positions.intersection(moved_rock):
                rock = moved_rock
            else:
                height = max(height, max(rock, key=lambda x: x.imag).imag + 1)
                blocked_positions.update(rock)
                break

    return int(height)


def part1():
    data = parse_data("input.txt")
    return simulate(2022, data)


def part2():
    # Height increments constant between rock and jet cycles.
    data = parse_data("input.txt")
    n_sim = 1000000000000
    return simulate(n_sim, data)


if __name__ == "__main__":
    print(part1())
    print(part2())
