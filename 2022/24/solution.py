from collections import defaultdict, deque
from itertools import chain

DIR = {"<": -1, ">": 1, "^": -1j, "v": 1j, " ": 0}


def parse_data(filepath="example.txt"):
    blizzards = defaultdict(set)
    # There is blizzards next to every wall
    with open(filepath) as file:
        grid = file.read().splitlines()
        data_height = len(grid) - 2
        data_width = len(grid[0]) - 2
        for row, line in enumerate(grid[1:]):
            for col, ch in enumerate(line[1:]):
                if ch in "<>^v":
                    blizzards[ch].add(complex(col, row))

    return blizzards, data_height, data_width


def wrap(pos: complex, height, width):
    return complex(pos.real % width, pos.imag % height)


def bfs(blizzards: dict[str, set], initial_pos: complex, goal, height, width):
    bliz = blizzards.copy()
    queue = deque([(initial_pos, 0, bliz)])

    seen = set()

    while queue:
        cur_pos, time, bliz = queue.popleft()
        if cur_pos == goal:
            return time, bliz
        if (cur_pos, time) in seen:
            continue
        seen.add((cur_pos, time))

        bliz = {
            dir: {
                wrap(bliz_pos + DIR[dir], height=height, width=width)
                for bliz_pos in positions
            }
            for dir, positions in bliz.items()
        }
        blizzard_positions = set(chain.from_iterable(bliz.values()))
        candidate_pos = {cur_pos + x for x in DIR.values()}
        for next_pos in candidate_pos - blizzard_positions:
            if next_pos in (initial_pos, goal) or (
                0 <= next_pos.real < width and 0 <= next_pos.imag < height
            ):
                queue.append((next_pos, time + 1, bliz))


def part1():
    data, height, width = parse_data("input.txt")
    initial_pos = complex(0, -1)
    goal_pos = complex(width - 1, height)
    return bfs(data, initial_pos, goal_pos, height, width)[0]


def part2():
    data, height, width = parse_data("input.txt")
    initial_pos = complex(0, -1)
    goal_pos = complex(width - 1, height)
    time1, blizzard1 = bfs(data, initial_pos, goal_pos, height, width)
    time2, blizzard2 = bfs(blizzard1, goal_pos, initial_pos, height, width)
    time3, _ = bfs(blizzard2, initial_pos, goal_pos, height, width)

    return sum([time1, time2, time3])


if __name__ == "__main__":
    print(part1())
    print(part2())
