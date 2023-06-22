COSTS = Dict('A' => 1, 'B' => 10, 'C' => 100, 'D' => 1000)
DESTINY = Dict('A' => 1, 'B' => 2, 'C' => 3, 'D' => 4)
TARGET = "ABCD"

function parse_data(
    filepath::String = joinpath(@__DIR__, "example.txt"),
)::Tuple{Vector{Char},Vector{Integer},Vector{Vector{Char}}}
    lines = readlines(filepath)
    hallway = [ch for ch in lines[2] if ch != '#']
    side_rooms = Vector{Char}[]
    room_entrances = Set{Int}()
    for line in lines[3:4]
        side_room_aux = Char[]
        for (i, ch) in enumerate(line)
            if ch ∉ " #"
                push!(side_room_aux, ch)
                push!(room_entrances, i - 1)  # Ignore first column as in hallway
            end
        end
        push!(side_rooms, side_room_aux)
    end
    side_rooms = reduce(hcat, side_rooms)
    return hallway, sort(collect(room_entrances)), eachrow(side_rooms)
end

function generate_next_states(
    hallway::T,
    rooms::K,
    entrances,
)::Vector{Tuple{Tuple{T,K},Integer}} where {T,K}
    next_states = Tuple{Tuple{T,K},Integer}[]
    # Move to hallway
    for (i, room) in enumerate(rooms)
        room_type = TARGET[i]
        all(room .== room_type) && continue
        room_entrance = entrances[i]
        next_room = copy(room)
        for (depth, ch) in enumerate(room)
            ch == '.' && continue
            next_room[depth] = '.'
            next_rooms = setindex!(copy(rooms), next_room, i)
            entrance_idx = DESTINY[ch]
            @assert entrance_idx in keys(entrances)
            target_door = entrances[entrance_idx]
            can_enter_target = all(x in ('.', ch) for x in rooms[entrance_idx])

            # Dont move if already in target and is valid
            can_enter_target && entrance_idx == i && continue

            entered_target = false
            candidate_steps = sign(target_door - room_entrance)
            dx = candidate_steps == 0 ? 1 : candidate_steps
            @assert dx != 0
            for dir in [dx, -dx]
                pos = room_entrance + dir
                steps = depth + 1
                while pos in keys(hallway) && hallway[pos] == '.' && !entered_target
                    if pos == target_door && can_enter_target
                        depth_join = findlast(x -> x == '.', rooms[entrance_idx])
                        target_room =
                            setindex!(copy(next_rooms[entrance_idx]), ch, depth_join)
                        next_rooms_updated =
                            setindex!(copy(next_rooms), target_room, entrance_idx)
                        push!(
                            next_states,
                            (
                                (hallway, next_rooms_updated),
                                (steps + depth_join) * COSTS[ch],
                            ),
                        )
                        entered_target = true
                    elseif pos ∉ entrances
                        next_hallway = setindex!(copy(hallway), ch, pos)
                        push!(next_states, ((next_hallway, next_rooms), steps * COSTS[ch]))
                    end
                    pos += dir
                    steps += 1
                end
            end
            break
        end
    end
    # Move from hallway to room
    for (pos, ch) in enumerate(hallway)
        ch == '.' && continue
        entrance_idx = DESTINY[ch]
        target_door = entrances[entrance_idx]
        can_enter_target = all(x in ('.', ch) for x in rooms[entrance_idx])

        !can_enter_target && continue

        dir = sign(target_door - pos)
        @assert dir != 0
        steps = 1
        cur_pos = pos + dir
        while hallway[cur_pos] == '.'
            if cur_pos == target_door
                next_hallway = setindex!(copy(hallway), '.', pos)
                depth_join = findlast(x -> x == '.', rooms[entrance_idx])
                target_room = setindex!(copy(rooms[entrance_idx]), ch, depth_join)
                next_rooms_updated = setindex!(copy(rooms), target_room, entrance_idx)
                push!(
                    next_states,
                    ((next_hallway, next_rooms_updated), (steps + depth_join) * COSTS[ch]),
                )
                break
            end
            cur_pos += dir
            steps += 1
        end
    end
    return next_states
end

function A_star(initial_state::T, goal_state::T, entrances_positions) where {T}
    queue = [(initial_state, 0)]
    g_score = Dict(initial_state => 0)
    while !isempty(queue)
        lowest_cost_idx = findmin(i -> queue[i][2], eachindex(queue))
        cur_state, cost = popat!(queue, lowest_cost_idx[2])

        cur_state == goal_state && return cost

        hallway, rooms = cur_state
        next_states = generate_next_states(hallway, rooms, entrances_positions)

        for (next_state, neighbor_cost) in next_states
            tentative_cost = cost + neighbor_cost
            if tentative_cost < get!(g_score, next_state, typemax(Int))
                g_score[next_state] = tentative_cost
                push!(queue, (next_state, tentative_cost))
            end
        end
    end
    display(g_score)
    throw(ErrorException("Unreachable"))
end

function part1(hallway, rooms, entrances_position)::Integer
    initial_state = (hallway, rooms)
    goal_hallway = repeat(['.'], length(hallway))
    goal_rooms = [repeat([ch], length(rooms[1])) for ch in TARGET]
    goal_state = (goal_hallway, goal_rooms)
    return A_star(initial_state, goal_state, entrances_position)
end

function part2(hallway, rooms, entrances_position)::Integer
    to_insert = [['D', 'D'], ['C', 'B'], ['B', 'A'], ['A', 'C']]
    new_rooms = [[x[1], y..., x[2]] for (x, y) in zip(rooms, to_insert)]
    initial_state = (hallway, new_rooms)
    goal_hallway = repeat(['.'], length(hallway))
    goal_rooms = [repeat([ch], length(new_rooms[1])) for ch in TARGET]
    goal_state = (goal_hallway, goal_rooms)
    return A_star(initial_state, goal_state, entrances_position)
end

hallway, entrances, rooms = parse_data(joinpath(@__DIR__, "input.txt"))
@time println(part1(hallway, rooms, entrances))
@time println(part2(hallway, rooms, entrances))
