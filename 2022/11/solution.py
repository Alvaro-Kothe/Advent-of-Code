import math
import re


def parse_operation(operation_string: str):
    _, rhs = operation_string.split("=")
    match rhs.split():
        case ["old", "+", "old"]:
            return lambda x: x + x
        case ["old", "*", "old"]:
            return lambda x: x * x
        case ["old", "+", number]:
            number = int(number)
            return lambda x: x + number
        case ["old", "*", number]:
            number = int(number)
            return lambda x: x * number
        case _:
            return


def parse_monkey(monkey_data: str) -> dict:
    monkey = {}
    monkey_instructions = monkey_data.splitlines()
    monkey_idx = int(re.search(r"\d+", monkey_instructions[0]).group())
    monkey["id"] = monkey_idx
    monkey["items"] = list(map(int, re.findall(r"\d+", monkey_instructions[1])))
    monkey["operation"] = parse_operation(monkey_instructions[2])
    divisible_number = int(re.search(r"\d+", monkey_instructions[3]).group())
    monkey["divisible_number"] = divisible_number
    monkey["test"] = lambda x: x % divisible_number == 0
    monkey["test_target"] = {
        True: int(re.search(r"\d+", monkey_instructions[4]).group()),
        False: int(re.search(r"\d+", monkey_instructions[5]).group()),
    }

    return monkey


def round(
    monkeys: dict, items_inspected_counter: dict, stress_ctrl_fun=lambda x: x // 3
):
    for monkey_idx, monkey in monkeys.items():
        while monkey["items"]:
            inspected_item = monkey["items"].pop(0)
            worry_level = monkey["operation"](inspected_item)
            items_inspected_counter[monkey_idx] += 1
            worry_level = stress_ctrl_fun(worry_level)
            test_result = monkey["test"](worry_level)
            target_monkey = monkey["test_target"][test_result]
            monkeys[target_monkey]["items"].append(worry_level)


def simulate(monkeys: dict, times: int, stress_ctrl_fun=lambda x: x // 3):
    items_inspected_counter = {monkey: 0 for monkey in monkeys}
    for _ in range(times):
        round(monkeys, items_inspected_counter, stress_ctrl_fun=stress_ctrl_fun)

    return items_inspected_counter


def parse_data():
    with open("input.txt") as file:
        text = file.read()
        monkey_operations = text.split("\n\n")

    monkeys = {}
    for monkey_operation in monkey_operations:
        monkey_dict = parse_monkey(monkey_operation)
        monkeys[monkey_dict["id"]] = monkey_dict

    return monkeys


def dict_top_n_values(d: dict, n: int) -> list:
    sorted_dict = dict(sorted(d.items(), key=lambda x: x[1], reverse=True))
    return list(sorted_dict.values())[:n]


def productory(lst):
    prod = 1
    for x in lst:
        prod *= x
    return prod


def part1():
    monkeys = parse_data()
    times_inspected = simulate(monkeys, 20)
    top_2 = dict_top_n_values(times_inspected, 2)
    return productory(top_2)


def part2():
    monkeys = parse_data()
    monkey_divisions = [monkey["divisible_number"] for monkey in monkeys.values()]

    def stress_ctrl_fun(x):
        return int(x % math.lcm(*monkey_divisions))

    times_inspected = simulate(monkeys, 10_000, stress_ctrl_fun=stress_ctrl_fun)
    top_2 = dict_top_n_values(times_inspected, 2)
    return productory(top_2)


if __name__ == "__main__":
    print(part1())
    print(part2())
