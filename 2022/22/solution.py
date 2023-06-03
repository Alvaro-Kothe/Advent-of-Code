import re

DIR_DICT = {
    1j: 0,
    1: 1,
    -1j: 2,
    -1: 3,
}


def parse_data(filepath="example.txt"):
    with open(filepath) as file:
        map_, instructions = file.read().split("\n\n")

    grid = map_.splitlines()
    parsed_instructions = []
    for steps, dir_ in re.findall(r"(\d+)([LR]?)", instructions):
        parsed_instructions.append(int(steps))
        if dir_:
            parsed_instructions.append(dir_)

    grid_hashmap = {
        complex(x, y): symbol
        for x, row_str in enumerate(grid)
        for y, symbol in enumerate(row_str)
        if symbol in ".#"
    }
    start_pos = complex(0, grid[0].index("."))

    return start_pos, grid_hashmap, parsed_instructions


def wrap(
    grid: dict[complex, str],
    pos: complex,
    dir: complex,
) -> tuple[complex, complex]:
    x, y = pos.real, pos.imag
    if dir == 1j:
        return (
            min(
                (grid_pos for grid_pos in grid if grid_pos.real == x),
                key=lambda x: x.imag,
            ),
            dir,
        )
    if dir == -1j:
        return (
            max(
                (grid_pos for grid_pos in grid if grid_pos.real == x),
                key=lambda x: x.imag,
            ),
            dir,
        )
    if dir == 1:
        return (
            min(
                (grid_pos for grid_pos in grid if grid_pos.imag == y),
                key=lambda x: x.real,
            ),
            dir,
        )
    if dir == -1:
        return (
            max(
                (grid_pos for grid_pos in grid if grid_pos.imag == y),
                key=lambda x: x.real,
            ),
            dir,
        )


def wrap_cube(pos: complex, dir: complex, **kwargs) -> tuple[complex, complex]:
    edge_size = 50
    x, y = pos.real, pos.imag
    match dir, x // edge_size, y // edge_size:
        case 1j, 0, _:
            return complex(149 - x, 99), -1j
        case 1j, 1, _:
            return complex(49, x + 50), -1
        case 1j, 2, _:
            return complex(149 - x, 149), -1j
        case 1j, 3, _:
            return complex(149, x - 100), -1
        case -1j, 0, _:
            return complex(149 - x, 0), 1j
        case -1j, 1, _:
            return complex(100, x - 50), 1
        case -1j, 2, _:
            return complex(149 - x, 50), 1j
        case -1j, 3, _:
            return complex(0, x - 100), 1
        case 1, _, 0:
            return complex(0, y + 100), 1
        case 1, _, 1:
            return complex(100 + y, 49), -1j
        case 1, _, 2:
            return complex(-50 + y, 99), -1j
        case -1, _, 0:
            return complex(50 + y, 50), 1j
        case -1, _, 1:
            return complex(100 + y, 0), 1j
        case -1, _, 2:
            return complex(199, y - 100), -1


def move(
    grid: dict[complex, str],
    pos: complex,
    dir: complex,
    instructions: list[str | int],
    wrap_fn=wrap,
):
    for move in instructions:
        match move:
            case "R":
                dir *= -1j
            case "L":
                dir *= 1j
            case n_moves:
                for _ in range(n_moves):
                    next_pos = pos + dir
                    next_dir = dir

                    if next_pos not in grid:
                        next_pos, next_dir = wrap_fn(grid=grid, pos=next_pos, dir=dir)
                    if grid[next_pos] == ".":
                        pos = next_pos
                        dir = next_dir
                    elif grid[next_pos] == "#":
                        break

    return pos, dir


def part1():
    start_pos, grid, instructions = parse_data("input.txt")
    pos, dir = move(grid, start_pos, 1j, instructions)
    password = 1000 * (pos.real + 1) + 4 * (pos.imag + 1) + DIR_DICT[dir]
    return password


def part2():
    start_pos, grid, instructions = parse_data("input.txt")
    pos, dir = move(grid, start_pos, 1j, instructions, wrap_fn=wrap_cube)
    password = 1000 * (pos.real + 1) + 4 * (pos.imag + 1) + DIR_DICT[dir]
    return password


if __name__ == "__main__":
    print(part1())
    print(part2())
