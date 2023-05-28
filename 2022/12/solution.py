from typing import List
import string
from collections import deque

ELEVATION = {ch: i for i, ch in enumerate(string.ascii_lowercase)}
ELEVATION["S"] = 0
ELEVATION["E"] = 25
MOVES = [(-1, 0), (1, 0), (0, -1), (0, 1)]


def parse_input() -> List[List[str]]:
    with open("input.txt") as file:
        grid = file.read().splitlines()

    return grid


def get_start_target_coords(grid: List[List[str]]):
    start_pos, target_pos = None, None
    for i, row in enumerate(grid):
        if "S" in row:
            start_pos = (i, row.index("S"))
        if "E" in row:
            target_pos = (i, row.index("E"))

        if start_pos is not None and target_pos is not None:
            break

    return start_pos, target_pos


def make_map(grid):
    return [[ELEVATION[ch] for ch in row] for row in grid]


def valid_move(map, x, y, next_x, next_y) -> bool:
    go_outside = not 0 <= next_x < len(map) or not 0 <= next_y < len(map[0])
    if go_outside:
        return False
    return map[next_x][next_y] - map[x][y] <= 1


def BFS(map, start, target):
    # https://www.wikiwand.com/en/Breadth-first_search
    queue = deque([(start, 0)])
    seen = {start}

    while queue:
        position, distance = queue.popleft()  # First in first out

        if position == target:
            return distance

        for i, j in MOVES:
            next_x = position[0] + i
            next_y = position[1] + j
            if (
                not valid_move(map, *position, next_x, next_y)
                or (next_x, next_y) in seen
            ):
                continue

            seen.add((next_x, next_y))
            queue.append(((next_x, next_y), distance + 1))

    return float("inf")


def part1():
    grid = parse_input()
    start_pos, target_pos = get_start_target_coords(grid)
    map = make_map(grid)
    return BFS(map, start_pos, target_pos)


def part2():
    grid = parse_input()
    _, target_pos = get_start_target_coords(grid)
    map = make_map(grid)
    starts = [
        (row, col)
        for row in range(len(map))
        for col in range(len(map[0]))
        if map[row][col] == 0
    ]

    return min(BFS(map, start_pos, target_pos) for start_pos in starts)


if __name__ == "__main__":
    print(part1())
    print(part2())
