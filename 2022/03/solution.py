import string
from typing import Tuple

priorities = {c: i + 1 for i, c in enumerate(string.ascii_letters)}


def split_compartments(s: str) -> Tuple[str, str]:
    half = len(s) // 2
    compart1 = s[:half]
    compart2 = s[half:]

    return compart1, compart2


def get_common_elements(x, y):
    x = set(x)
    y = set(y)

    return x.intersection(y)


def compartment_score(x):
    priority = [priorities[s] for s in x]
    return sum(priority)


def solution2(filepath: str) -> dict:
    score = 0

    with open(filepath) as f:
        for i, line in enumerate(f):
            if i % 3 == 0:
                compartments = []
            compartments.append(set(line.rstrip()))
            if len(compartments) == 3:
                badge = set.intersection(*compartments)
                score += sum(map(priorities.get, badge))

    return score


def solution1(filepath: str) -> dict:
    score = 0

    with open(filepath) as f:
        for line in f:
            compartment_commmon_elements = get_common_elements(
                *split_compartments(line)
            )
            score += compartment_score(compartment_commmon_elements)

    return score


def main():
    score = solution2("input.txt")
    print(score)


if __name__ == "__main__":
    main()
