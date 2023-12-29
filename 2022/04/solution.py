def main1():
    n_contained = 0
    with open("input.txt") as f:
        for line in f:
            range1, range2 = line.split(",")
            range1 = tuple(map(int, range1.split("-")))
            range2 = tuple(map(int, range2.split("-")))

            n_contained += (range1[0] - range2[0]) * (range1[1] - range2[1]) <= 0

    return n_contained


def main2():
    n_contained = 0
    with open("input.txt") as f:
        for line in f:
            range1, range2 = line.split(",")
            range1 = tuple(map(int, range1.split("-")))
            range2 = tuple(map(int, range2.split("-")))

            n_contained += range1[0] <= range2[1] and range1[1] >= range2[0]

    return n_contained


if __name__ == "__main__":
    print(main1())
    print(main2())
