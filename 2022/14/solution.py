def create_sequence(coord1, coord2):
    if coord1[1] == coord2[1]:
        mini, maxi = sorted([coord1[0], coord2[0]])
        return [(i, coord1[1]) for i in range(mini, maxi + 1)]
    if coord1[0] == coord2[0]:
        mini, maxi = sorted([coord1[1], coord2[1]])
        return [(coord1[0], i) for i in range(mini, maxi + 1)]


def sand_fall(rocks_positions: set):
    sand_origin = (500, 0)
    sand_moves = [(0, 1), (-1, 1), (1, 1)]
    sand_rest_positions = set()
    sand_cur_position = sand_origin
    max_depth = max(rock[1] for rock in rocks_positions)

    while sand_cur_position[1] < max_depth:
        for move in sand_moves:
            next_pos = (sand_cur_position[0] + move[0], sand_cur_position[1] + move[1])
            if next_pos not in rocks_positions.union(sand_rest_positions):
                sand_cur_position = next_pos
                break
        else:
            sand_rest_positions.add(sand_cur_position)
            sand_cur_position = sand_origin

    return sand_rest_positions


def sand_fall_bottom(rocks_positions: set):
    sand_origin = (500, 0)
    sand_moves = [(0, 1), (-1, 1), (1, 1)]
    sand_rest_positions = set()
    sand_cur_position = sand_origin
    bottom_depth = max(rock[1] for rock in rocks_positions) + 2

    while sand_origin not in sand_rest_positions:
        for move in sand_moves:
            next_pos = (sand_cur_position[0] + move[0], sand_cur_position[1] + move[1])
            if (
                next_pos not in rocks_positions.union(sand_rest_positions)
                and next_pos[1] < bottom_depth
            ):
                sand_cur_position = next_pos
                break
        else:
            sand_rest_positions.add(sand_cur_position)
            print("current rested sands:", len(sand_rest_positions))
            sand_cur_position = sand_origin

    return sand_rest_positions


def parse_data():
    rock_coords = set()
    with open("input.txt") as file:
        for line in file:
            rock_edges = [
                tuple(map(int, coords.split(",")))
                for coords in line.rstrip().split(" -> ")
            ]
            for i in range(len(rock_edges) - 1):
                rock_coords.update(create_sequence(rock_edges[i], rock_edges[i + 1]))

    return rock_coords


def part1():
    data = parse_data()
    sand_positions = sand_fall(rocks_positions=data)
    return len(sand_positions)


def part2():
    data = parse_data()
    sand_positions = sand_fall_bottom(rocks_positions=data)
    return len(sand_positions)


if __name__ == "__main__":
    print(part1())
    print(part2())
