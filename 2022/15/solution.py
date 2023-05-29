from itertools import pairwise
from collections import defaultdict
import re
from typing import List, Tuple


def parse_data() -> List[Tuple[Tuple[int, int]]]:
    out = []
    pattern = re.compile(r"=(-?\d+)")
    with open("input.txt") as file:
        for line in file:
            sx, sy, bx, by = map(int, pattern.findall(line))
            out.append(((sx, sy), (bx, by)))

    return out


def not_beacon_row(sensor_beacon_list: List[Tuple], row: int):
    beacon_positions_in_row = set(x[1][0] for x in sensor_beacon_list if x[1][1] == row)
    not_possible = set()
    for (sx, sy), (bx, by) in sensor_beacon_list:
        distance_beacon = abs(sx - bx) + abs(sy - by)
        # Polygon: abs(sx - x) + abs(sy - y) <= distance_beacon
        # Verify on row of interest:
        #   abs(sx - x) <= distance_beacon - abs(sy - row)
        # a = distance_beacon - abs(sy - row)
        # -a <= (sx - x) <= a
        # a>= x - sx >= -a
        # a + sx >= x >= sx - a
        # sx - a <= x <= a + sx
        distance_to_row = distance_beacon - abs(sy - row)
        if distance_to_row > 0:
            not_possible.update(range(sx - distance_to_row, sx + distance_to_row + 1))

    return not_possible - beacon_positions_in_row


def part1():
    data = parse_data()
    not_possible_row = not_beacon_row(data, 2000000)
    return len(not_possible_row)


def interval_union(lst_intervals):
    sorted_list = sorted(lst_intervals)
    union_result = []
    for lower, upper in sorted_list:
        if not union_result:
            union_result.append([lower, upper])
            union_upper = upper
            continue
        if lower <= union_upper + 1:
            union_result[-1][1] = upper
        else:
            union_result.append([lower, upper])
        union_upper = max(upper, union_upper)

    return union_result


def find_beacon(sensor_beacon_list: List[Tuple], box_range: int):
    row_sensor_coverage = defaultdict(list)
    for row in range(box_range + 1):
        for (sx, sy), (bx, by) in sensor_beacon_list:
            distance_beacon = abs(sx - bx) + abs(sy - by)
            distance_to_row = distance_beacon - abs(sy - row)
            if distance_to_row > 0:
                row_sensor_coverage[row].append(
                    [sx - distance_to_row, sx + distance_to_row]
                )
    row_coverage_intervals = {
        row: interval_union(intervals) for row, intervals in row_sensor_coverage.items()
    }
    missing_beacon_locations = set()
    for row, interval in row_coverage_intervals.items():
        if len(interval) < 2:
            continue
        for (_, upper1), (lower2, _) in pairwise(interval):
            missing_beacon_locations.update((i, row) for i in range(upper1 + 1, lower2))

    return missing_beacon_locations


def part2():
    data = parse_data()
    missing_beacon_location = list(find_beacon(data, 4000000))[0]
    return missing_beacon_location[0] * 4000000 + missing_beacon_location[1]


if __name__ == "__main__":
    print(part1())
    print(part2())
