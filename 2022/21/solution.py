from typing import Any, Dict


OPERATIONS = {
    "+": lambda x, y: x + y,
    "-": lambda x, y: x - y,
    "*": lambda x, y: x * y,
    "/": lambda x, y: x / y,
}
R_INVERSE = {
    "+": lambda x, y: x - y,
    "-": lambda x, y: y - x,
    "*": lambda x, y: x / y,
    "/": lambda x, y: y / x,
}
L_INVERSE = {
    "+": lambda x, y: x - y,
    "-": lambda x, y: x + y,
    "*": lambda x, y: x / y,
    "/": lambda x, y: x * y,
}


def parse_data(filepath="example.txt"):
    out = {}
    with open(filepath) as file:
        for line in file:
            monkey, operation = line.strip().split(": ")
            if operation.isdigit():
                out[monkey] = int(operation)
            else:
                out[monkey] = operation

    return out


def get_monkey_numbers(monkey_operations: Dict[str, Any]):
    monkey_numbers = {
        monkey: number
        for monkey, number in monkey_operations.items()
        if isinstance(number, int)
    }
    return monkey_numbers


def find_root_number(
    monkey_operations: Dict[str, Any], monkey_numbers: Dict[str, Any], target="root"
):
    assert target in monkey_operations

    while target not in monkey_numbers:
        for monkey, operation in monkey_operations.items():
            if monkey in monkey_numbers:
                continue
            monkey1, operator, monkey2 = operation.split()
            if monkey_numbers.keys() >= {monkey1, monkey2}:
                monkey_numbers[monkey] = OPERATIONS[operator](
                    monkey_numbers[monkey1], monkey_numbers[monkey2]
                )

    return monkey_numbers[target]


def get_child_operations(
    monkey_operations: Dict[str, Any], target: str, values_dict: Dict[str, any]
):
    while target not in values_dict:
        for monkey, operation in monkey_operations.items():
            if monkey in values_dict:
                continue
            monkey1, operator, monkey2 = operation.split()
            if values_dict.keys() >= {monkey1, monkey2}:
                value_monkey1 = values_dict[monkey1]
                value_monkey2 = values_dict[monkey2]

                if value_monkey1 is None or value_monkey2 is None:
                    values_dict[monkey] = None
                else:
                    values_dict[monkey] = OPERATIONS[operator](
                        values_dict[monkey1], values_dict[monkey2]
                    )
    return values_dict


def part1():
    data = parse_data("input.txt")
    monkey_numbers = get_monkey_numbers(data)
    return find_root_number(data, monkey_numbers=monkey_numbers)


def part2():
    data = parse_data("input.txt")
    root_op = data["root"]
    root_child1, _, root_child2 = root_op.split()
    monkey_numbers = get_monkey_numbers(data)
    monkey_numbers["humn"] = None
    get_child_operations(data, root_child1, monkey_numbers)
    get_child_operations(data, root_child2, monkey_numbers)

    if monkey_numbers[root_child1] is None:
        target = root_child1
        monkey_numbers[root_child1] = target_value = monkey_numbers[root_child2]
    else:
        target = root_child2
        monkey_numbers[root_child2] = target_value = monkey_numbers[root_child1]

    while monkey_numbers["humn"] is None:
        target_child1, operator, target_child2 = data[target].split()
        if monkey_numbers[target_child1] is None:
            monkey_numbers[target_child1] = target_value = L_INVERSE[operator](
                target_value, monkey_numbers[target_child2]
            )
            target = target_child1
        if monkey_numbers[target_child2] is None:
            monkey_numbers[target_child2] = target_value = R_INVERSE[operator](
                 target_value, monkey_numbers[target_child1]
            )
            target = target_child2

    return monkey_numbers["humn"]


if __name__ == "__main__":
    print(part1())
    print(part2())
