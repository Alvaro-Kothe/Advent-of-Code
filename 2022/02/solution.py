ENC_OP = {"A": 0, "B": 1, "C": 2}
ENC_ME = {"X": 0, "Y": 1, "Z": 2}
ENC_column2 = {"X": 2, "Y": 0, "Z": 1}


def compute_result2(op: str, me: str) -> int:
    op_enc = ENC_OP[op]
    me_enc = (op_enc + ENC_column2[me]) % 3

    return me_enc + 1 + get_result(op_enc, me_enc)


def get_result(op: int, me: int):
    if op == me:
        return 3
    if (op + 1) % 3 == me:
        return 6

    return 0


def compute_win(op: str, me: str) -> int:
    op_enc = ENC_OP[op]
    me_enc = ENC_ME[me]

    # draw
    if op_enc == me_enc:
        return 3

    # win
    if (op_enc + 1) % 3 == me_enc:
        return 6

    return 0


def solution2(filepath: str) -> dict:
    score = 0
    with open(filepath) as f:
        for line in f:
            oponent, me = line.split()
            score += compute_result2(oponent, me)

    return score


def solution1(filepath: str) -> int:
    score = 0

    with open(filepath) as f:
        for line in f:
            oponent, me = line.split()
            score += ENC_ME[me] + 1 + compute_win(oponent, me)

    return score


def main():
    score = solution1("input.txt")
    print(score)
    score = solution2("input.txt")
    print(score)


if __name__ == "__main__":
    main()
