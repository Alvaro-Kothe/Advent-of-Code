from collections import defaultdict, deque

MOVES = [-1j, 1j, -1, 1]
AROUND = [
    complex(x, y) for x in range(-1, 2) for y in range(-1, 2) if not (x == y and x == 0)
]
LOOKUP = {
    1j: [-1 + 1j, 1j, 1 + 1j],
    -1j: [-1 - 1j, -1j, 1 - 1j],
    1: [1 + 1j, 1, 1 - 1j],
    -1: [-1 + 1j, -1, -1 - 1j],
}


def parse_data(filepath="example.txt"):
    with open(filepath) as file:
        elfs_positions = {
            complex(x, y)
            for y, row in enumerate(file)
            for x, ch in enumerate(row)
            if ch == "#"
        }

    return elfs_positions


def move(elfs_positions: set[complex], rounds=10):
    set_len = len(elfs_positions)
    round_moves = deque(MOVES)
    round = 0
    while round < rounds:
        round += 1
        assert len(elfs_positions) == set_len

        candidate_positions = defaultdict(list)
        for elf in elfs_positions:
            elf_neighbors = {elf + x for x in AROUND}
            if not elf_neighbors & elfs_positions:
                continue
            for move in round_moves:
                lookup = {elf + x for x in LOOKUP[move]}
                if not lookup & elfs_positions:
                    candidate_positions[elf + move].append(elf)
                    break

        if not candidate_positions:
            break
        for next_pos, elves in candidate_positions.items():
            if len(elves) == 1:
                elfs_positions.remove(elves[0])
                elfs_positions.add(next_pos)

        round_moves.rotate(-1)

    return elfs_positions, round


def compute_coverage_area(elfs_positions):
    x = [elf.real for elf in elfs_positions]
    y = [elf.imag for elf in elfs_positions]

    return (max(x) - min(x) + 1) * (max(y) - min(y) + 1) - len(elfs_positions)


def part1():
    data = parse_data("input.txt")
    elfs_positions = move(data)[0]
    return compute_coverage_area(elfs_positions)


def part2():
    data = parse_data("input.txt")
    _, rounds = move(data, float("inf"))
    return rounds


if __name__ == "__main__":
    print(part1())
    print(part2())
