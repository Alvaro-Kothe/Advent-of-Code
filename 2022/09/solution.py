from typing import List, Tuple

DIRECTIONS = {"R": (0, 1), "L": (0, -1), "U": (1, 0), "D": (-1, 0)}


def parse_input() -> List[Tuple[str, int]]:
    instructions = []
    with open("input.txt") as file:
        for line in file:
            direction, n_steps = line.split()
            instructions.append((direction, int(n_steps)))

    return instructions


def sign(x):
    if x > 0:
        return 1
    elif x < 0:
        return -1
    elif x == 0:
        return 0


class Rope:
    def __init__(self, n_knots=2):
        self.rope = {i: (0, 0) for i in range(n_knots)}
        self.tail_idx = n_knots - 1
        self.tail_positions = {self.rope[self.tail_idx]}

    def _move(self, direction):
        y, x = DIRECTIONS[direction]
        # move head
        self.rope[0] = (self.rope[0][0] + y, self.rope[0][1] + x)

        for knot in range(1, len(self.rope)):
            # distance to knkot ahead
            dist_y = self.rope[knot - 1][1] - self.rope[knot][1]
            dist_x = self.rope[knot - 1][0] - self.rope[knot][0]

            if abs(dist_y) == 2 or abs(dist_x) == 2:
                move_y = sign(dist_y)
                move_x = sign(dist_x)
                self.rope[knot] = (
                    self.rope[knot][0] + move_x,
                    self.rope[knot][1] + move_y,
                )

    def move(self, direction, n_times):
        for _ in range(n_times):
            self._move(direction)
            self.tail_positions.add(self.rope[self.tail_idx])

    def get_tail_positions(self):
        return len(self.tail_positions)


def part1():
    input_ = parse_input()
    rope = Rope()
    for direction, n_times in input_:
        rope.move(direction, n_times)

    return rope.get_tail_positions()


def part2():
    input_ = parse_input()
    rope = Rope(n_knots=10)
    for direction, n_times in input_:
        rope.move(direction, n_times)

    return rope.get_tail_positions()


if __name__ == "__main__":
    print(part1())
    print(part2())
