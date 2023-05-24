def mark_sop(s: str, n_dif=4):
    for i in range(len(s) - n_dif + 1):
        packet = s[i : i + n_dif]
        if len(packet) == len(set(packet)):
            return i + n_dif


def test_examples():
    example1 = "mjqjpqmgbljsphdztnvjfqwrcgsmlb"
    example2 = "bvwbjplbgvbhsrlpgdmjqwftvncz"
    example3 = "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"
    example4 = "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"
    print(mark_sop(example1))
    print(mark_sop(example2))
    print(mark_sop(example3))
    print(mark_sop(example4))


def part1():
    with open("input.txt") as file:
        input_ = file.read()
    return mark_sop(input_)


def part2():
    with open("input.txt") as file:
        input_ = file.read()
    return mark_sop(input_, n_dif=14)


if __name__ == "__main__":
    print(part1())
    print(part2())
