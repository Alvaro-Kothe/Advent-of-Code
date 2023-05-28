import json
from typing import List, Tuple
from functools import cmp_to_key


def parse_data(tuples=True) -> List[Tuple[List, List]]:
    out = []
    with open("input.txt") as file:
        packet_pairs = file.read().split("\n\n")
        for packets in packet_pairs:
            pairs = packets.splitlines()
            pair = tuple(json.loads(packet) for packet in pairs)
            if tuples:
                out.append(pair)
            else:
                out.extend(pair)

    return out


def compare(left, right):
    if type(left) != type(right):
        if isinstance(left, int):
            left = [left]
        else:
            right = [right]

    if isinstance(left, int) and isinstance(right, int):
        if left < right:
            return True
        elif left > right:
            return False
        elif left == right:
            return

    if isinstance(left, list) and isinstance(right, list):
        max_range = max(len(left), len(right))
        for i in range(max_range):
            if i >= len(right):
                # right side ran out of items
                return False
            if i >= len(left):
                return True
            comparison = compare(left[i], right[i])

            if comparison is None and i == len(left) - 1:
                # left side ran out of item
                return True
            if comparison is None:
                continue
            else:
                return comparison


def part1():
    data = parse_data()
    comparisons = []
    for left, right in data:
        comparisons.append(compare(left, right))
    return sum(i + 1 for i in range(len(comparisons)) if comparisons[i])


def part2():
    data = parse_data(tuples=False) + [[[2]], [[6]]]

    def int_compare(x, y):
        compare_result = compare(x, y)
        if compare_result:
            return -1
        else:
            return 1

    data.sort(key=cmp_to_key(int_compare))
    return (data.index([[2]]) + 1) * (data.index([[6]]) + 1)


if __name__ == "__main__":
    print(part1())
    print(part2())
