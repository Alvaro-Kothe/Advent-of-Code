import re
from collections import deque
from os import listdir


def parse_data(filepath="example.txt"):
    pattern = re.compile(
        (
            r"Blueprint (\d+): Each ore robot costs (\d+) ore."
            r" Each clay robot costs (\d+) ore."
            r" Each obsidian robot costs (\d+) ore and (\d+) clay."
            r" Each geode robot costs (\d+) ore and (\d+) obsidian."
        )
    )

    with open(filepath) as file:
        blueprints = [
            tuple(map(int, pattern.match(line).groups()))
            for line in file.read().splitlines()
        ]
    # blueprint id, ore_cost_ore, clay_cost_ore, obsidian_cost_ore,
    # obsidian_cost_clay, geode_cost_ore, geode_cost_obsidian
    return blueprints


def increase_ores(state: tuple[int]) -> list[int]:
    state_copy = list(state)
    for i in range(4):
        state_copy[i] += state_copy[i + 4]
    state_copy[-1] -= 1  # pass time
    return state_copy


def bfs(
    ore_cost_ore,
    clay_cost_ore,
    obsidian_cost_ore,
    obsidian_cost_clay,
    geode_cost_ore,
    geode_cost_obsidian,
    time=24,
):
    ore_cap = max([ore_cost_ore, clay_cost_ore, obsidian_cost_ore, geode_cost_ore])
    clay_cap = obsidian_cost_clay
    obsidian_cap = geode_cost_obsidian
    caps = (ore_cap, clay_cap, obsidian_cap)

    # production state (n_{ore,clay,obsidian,geode},
    #                   n_robots_{ore,clay,obsidian,geode}, time_left)
    initial_state = (0, 0, 0, 0, 1, 0, 0, 0, time)
    max_geodes = initial_state[3]
    queue: list[tuple[int]] = deque([initial_state])
    seen = set()

    while queue:
        cur_state = queue.popleft()

        max_geodes = max(max_geodes, cur_state[3])

        rem_time = cur_state[-1]
        if rem_time == 0:
            continue

        # Cap number of robots and resources

        if any(
            n_robots > cap  # cap number of robots
            for n_robots, cap in zip(cur_state[4:7], caps)
        ):
            continue

        cur_state = list(cur_state)
        for i in range(len(caps)):
            cur_state[i] = min(
                cur_state[i], caps[i] * rem_time - cur_state[i + 4] * (rem_time - 1)
            )

        cur_state = tuple(cur_state)

        if cur_state in seen:
            continue
        seen.add(cur_state)

        # if len(seen) % 1_000_00 == 0:
        #     print(rem_time, max_geodes, len(seen))

        next_state = increase_ores(state=cur_state)
        queue.append(tuple(next_state))

        if cur_state[0] >= ore_cost_ore:
            next_state = increase_ores(state=cur_state)
            next_state[0] -= ore_cost_ore
            next_state[4] += 1
            queue.append(tuple(next_state))
        if cur_state[0] >= clay_cost_ore:
            next_state = increase_ores(state=cur_state)
            next_state[0] -= clay_cost_ore
            next_state[5] += 1
            queue.append(tuple(next_state))
        if cur_state[0] >= obsidian_cost_ore and cur_state[1] >= obsidian_cost_clay:
            next_state = increase_ores(state=cur_state)
            next_state[0] -= obsidian_cost_ore
            next_state[1] -= obsidian_cost_clay
            next_state[6] += 1
            queue.append(tuple(next_state))
        if cur_state[0] >= geode_cost_ore and cur_state[2] >= geode_cost_obsidian:
            next_state = increase_ores(state=cur_state)
            next_state[0] -= geode_cost_ore
            next_state[2] -= geode_cost_obsidian
            next_state[7] += 1
            queue.append(tuple(next_state))
    return max_geodes


def part1():
    data = parse_data("input.txt")
    bp_quality = (bp[0] * bfs(*bp[1:], time=24) for bp in data)
    return sum(bp_quality)


def part2():
    data = parse_data("input.txt")
    k = min(3, len(data))
    firsts_n_geodes = [bfs(*bp[1:], time=32) for bp in data[:k]]
    out = 1
    for x in firsts_n_geodes:
        out *= x
    return out


if __name__ == "__main__":
    print(part1())
    print(part2())
