import re


def parse_data():
    valve_network, valve_flow = {}, {}

    pattern = re.compile(r"Valve (\w{2}) has flow rate=(\d+);.* valves? ([A-Z, ]+)")
    with open("input.txt") as file:
        for line in file:
            valve_desc = pattern.match(line).groups()
            valve_network[valve_desc[0]] = valve_desc[2].split(", ")
            valve_flow[valve_desc[0]] = int(valve_desc[1])

    return valve_network, valve_flow


def open_valve(
    current: str,
    network: dict[list],
    flow: dict,
    open_valves: tuple[str],
    time_left: int,
    states: dict = {},
    n_elephants: int = 0,
):
    # Credit to Jonathan Paulson

    if time_left <= 0:
        if n_elephants > 0:
            return open_valve(
                "AA", network, flow, open_valves, 26, states, n_elephants - 1
            )
        else:
            return 0

    states_hash = (current, open_valves, time_left, n_elephants)

    if states_hash in states:
        return states[states_hash]

    released_flow = 0
    if current not in open_valves and flow[current] > 0:
        new_open = tuple(sorted(open_valves + (current,)))
        released_flow = max(
            released_flow,
            (time_left - 1) * flow[current]
            + open_valve(
                current=current,
                network=network,
                flow=flow,
                open_valves=new_open,
                time_left=time_left - 1,
                states=states,
                n_elephants=n_elephants,
            ),
        )
    for neighbor in network[current]:
        released_flow = max(
            released_flow,
            open_valve(
                current=neighbor,
                network=network,
                flow=flow,
                open_valves=open_valves,
                time_left=time_left - 1,
                states=states,
                n_elephants=n_elephants,
            ),
        )

    states[states_hash] = released_flow

    return released_flow


def part1():
    valve_network, valve_flow = parse_data()

    start_valve = "AA"
    minutes = 30
    states = {}
    open_valves = ()
    out = open_valve(
        start_valve, valve_network, valve_flow, open_valves, minutes, states
    )
    return out


def part2():
    valve_network, valve_flow = parse_data()

    start_valve = "AA"
    minutes = 26
    n_elephants = 1
    states = {}
    open_valves = ()
    out = open_valve(
        start_valve,
        valve_network,
        valve_flow,
        open_valves,
        minutes,
        states,
        n_elephants,
    )
    return out


if __name__ == "__main__":
    print(part1())
    print(part2())
