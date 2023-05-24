import re

crates_every = 4


def remove_empty(lst):
    return [x for x in lst if x != " "]


def move(columns, how_many, from_, to):
    for _ in range(how_many):
        columns[to].append(columns[from_].pop())


def move2(columns, how_many, from_, to):
    stack = columns[from_][-how_many:]
    del columns[from_][-how_many:]
    columns[to].extend(stack)


def parse_instructions(s):
    how_many, from_, to = map(int, re.findall(r"\d+", s))
    return how_many, from_, to


def main1():
    container = []
    with open("input.txt") as f:
        for line in f:
            if line == "\n":
                # Columns in a dictionary with elements on top in the last index of list
                columns = {
                    i + 1: remove_empty(reversed(column))
                    for i, column in enumerate(zip(*container))
                }
            elif line[0] in ("\n", "[", " ") and line[1] != "1":
                container.append(list(line[1::crates_every]))
            elif line[:2] == "mo":
                move(columns, *parse_instructions(line))

    return [column[-1] for column in columns.values()]


def main2():
    container = []
    with open("input.txt") as f:
        for line in f:
            if line == "\n":
                # Columns in a dictionary with elements on top in the last index of list
                columns = {
                    i + 1: remove_empty(reversed(column))
                    for i, column in enumerate(zip(*container))
                }
            elif line[0] in ("\n", "[", " ") and line[1] != "1":
                container.append(list(line[1::crates_every]))
            elif line[:2] == "mo":
                move2(columns, *parse_instructions(line))

    return [column[-1] for column in columns.values()]


if __name__ == "__main__":
    print("".join(main1()))
    print("".join(main2()))
