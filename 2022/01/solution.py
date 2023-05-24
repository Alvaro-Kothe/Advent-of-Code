from collections import defaultdict


def read_data(filepath: str) -> dict:
    elves_food = defaultdict(list)
    elv_idx = 1

    with open(filepath) as f:
        for line in f:
            line_number = line.rstrip()
            if not line_number:
                elv_idx += 1
                continue
            elves_food[elv_idx].append(int(line_number))

    return elves_food


def compute_calories(elves_food: dict) -> dict:
    total_calories = {elv: sum(calories) for elv, calories in elves_food.items()}
    return total_calories


def dict_top_n_values(d: dict, n: int) -> list:
    sorted_dict = dict(sorted(d.items(), key=lambda x: x[1], reverse=True))
    return list(sorted_dict.values())[:n]


def dict_argmax(d: dict) -> list:
    v = list(d.values())
    k = list(d.keys())
    return k[v.index(max(v))]


def main():
    data = read_data("input.txt")
    total_calories = compute_calories(data)
    most_calories = dict_argmax(total_calories)
    print(
        f"Elf with most calories: {most_calories} with {total_calories[most_calories]}"
    )
    top_three_calories = dict_top_n_values(total_calories, n=3)
    print(f"Top 3 elves total calories: {sum(top_three_calories)}")


if __name__ == "__main__":
    main()
