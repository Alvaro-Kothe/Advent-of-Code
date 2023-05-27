from typing import List, Tuple


def parse_input() -> List[Tuple[int, int]]:
    instructions = []
    with open("input.txt") as file:
        for line in file:
            split_line = line.rstrip().split()
            if split_line[0] == "noop":
                instructions.append((1, 0))
            elif split_line[0] == "addx":
                instructions.append((2, int(split_line[1])))

    return instructions


class Clock_Circuit:
    def __init__(self) -> None:
        self.circuit = [1]  # register after cycle `index`
        self.current_register = self.circuit[0]

    def add_cycles(self, cycle, add_register):
        while cycle > 0:
            cycle -= 1
            if cycle == 0:
                self.circuit.append(self.circuit[-1] + add_register)
                return self
            self.circuit.append(self.circuit[-1])


def part1():
    inp = parse_input()
    clock = Clock_Circuit()
    for cycles, add_register in inp:
        clock.add_cycles(cycles, add_register)
    cycles_look = range(20, 220 + 1, 40)
    signal_strength = 0
    for cycle in cycles_look:
        register_during_cycle = clock.circuit[cycle - 1]
        signal_strength += cycle * register_during_cycle

    return signal_strength


def part2():
    inp = parse_input()
    clock = Clock_Circuit()
    for cycles, add_register in inp:
        clock.add_cycles(cycles, add_register)

    crt_oneline = []
    # Sprite size = 3
    # register shows the sprite position

    for cycle in range(240):
        position = cycle % 40
        sprite_pos = tuple(clock.circuit[cycle] + i for i in (-1, 0, 1))
        crt_pixel = "#" if position in sprite_pos else "."
        crt_oneline.append(crt_pixel)

    crt = ["".join(crt_oneline[i:i+40]) for i in range(0, 240, 40)]

    return "\n".join(crt)


if __name__ == "__main__":
    print(part1())
    print(part2())
