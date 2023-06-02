def parse_data(filepath: str = "example.txt"):
    with open(filepath) as file:
        return tuple(map(int, file.read().splitlines()))


def decrypt(encrypted_data: list[int], n_times=1) -> list[int]:
    indices_list = list(range(len(encrypted_data)))
    list_len = len(indices_list)

    for _ in range(n_times):
        for idx in range(list_len):
            indices_list.pop(cur_pos := indices_list.index(idx))
            shift_amount = encrypted_data[idx]
            next_pos = (cur_pos + shift_amount) % (list_len - 1)
            indices_list.insert(next_pos, idx)

    return [encrypted_data[idx] for idx in indices_list]


def part1():
    data = parse_data("input.txt")
    decrypted_data = decrypt(data)
    zero_pos = decrypted_data.index(0)
    return sum(
        decrypted_data[(zero_pos + after) % len(decrypted_data)]
        for after in (1000, 2000, 3000)
    )


def part2():
    data = parse_data("input.txt")
    key = 811589153
    data = [x * key for x in data]
    decrypted_data = decrypt(data, n_times=10)
    zero_pos = decrypted_data.index(0)
    return sum(
        decrypted_data[(zero_pos + after) % len(decrypted_data)]
        for after in (1000, 2000, 3000)
    )


if __name__ == "__main__":
    print(part1())
    print(part2())
