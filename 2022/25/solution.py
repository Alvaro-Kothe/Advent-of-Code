SNAFU = {"2": 2, "1": 1, "0": 0, "-": -1, "=": -2}
SNAFU_STR = "=-012"


def to_decimal(s: str):
    out = 0
    for i, ch in enumerate(reversed(s)):
        out += (5**i) * SNAFU[ch]

    return out


def to_snafu(number: int):
    quo, rem = divmod(number + 2, 5)
    if quo == 0:
        return SNAFU_STR[rem]
    return to_snafu(quo) + SNAFU_STR[rem]


def parse_data(filepath="example.txt"):
    with open(filepath) as file:
        return file.read().splitlines()


def part1():
    data = parse_data("input.txt")

    sum_decimal = sum(to_decimal(s) for s in data)
    return to_snafu(sum_decimal)


if __name__ == "__main__":
    print(part1())
