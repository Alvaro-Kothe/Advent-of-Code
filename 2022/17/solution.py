ROCKS = [
    [0, 1, 2, 3],
    [1, 1j, 1 + 1j, 2 + 1j, 1 + 2j],
    [0, 1, 2, 2 + 1j, 2 + 2j],
    [0, 1j, 2j, 3j],
    [0, 1, 1j, 1 + 1j],
]


def parse_data(filepath="input.txt"):
    with open(filepath) as file:
        return [1 if ch == ">" else -1 for ch in file.read().rstrip()]


def simulate(n_rocks, hot_gas_data):
    ground_width = 7
    height = 0

    rock_idx = 0
    jet_idx = 0
    blocked_positions = set()
    cache = dict()

    def is_available(pos: complex):
        return (
            0 <= pos.real < ground_width
            and pos.imag > 0
            and pos not in blocked_positions
        )

    def valid_move(pos: complex, dir: complex, rock):
        return all(is_available(pos + dir + x) for x in rock)

    for i in range(n_rocks):
        pos = 2 + (height + 4) * 1j
        rock = ROCKS[rock_idx]
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
            if valid_move(pos, jet, rock):
                pos += jet
            if valid_move(pos, -1j, rock):
                pos += -1j
            else:
                break
        blocked_positions.update(pos + x for x in rock)
        height = max(x.imag for x in blocked_positions)

    return int(height)


def part1():
    data = parse_data("input.txt")
    return simulate(2022, data)


def part2():
    data = parse_data("input.txt")
    return simulate(1000000000000, data)


if __name__ == "__main__":
    print(part1())
    print(part2())
