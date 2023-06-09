function parse_data(filepath::String = joinpath(@__DIR__, "example.txt"))
    file = readlines(filepath)
    lines = split.(file, "")
    lines_int = map(x -> parse.(Int, x), lines)
    return mapreduce(permutedims, vcat, lines_int)
end

function part1(data)::Int
    data_indexes = CartesianIndices(data)
    up, right = CartesianIndex(1, 0), CartesianIndex(0, 1)
    topright, topleft = CartesianIndex(1, 1), CartesianIndex(1, -1)

    answer = 0

    for _ in 1:100
        data .+= 1
        queue = findall(>(9), data)
        seen = Set{CartesianIndex{2}}()

        while !isempty(queue)
            cur_idx = popfirst!(queue)
            if cur_idx in seen
                continue
            end
            push!(seen, cur_idx)
            neighbors = filter(
                x -> x in data_indexes && x ∉ seen,
                [
                    cur_idx + up,
                    cur_idx - up,
                    cur_idx + right,
                    cur_idx - right,
                    cur_idx + topright,
                    cur_idx - topright,
                    cur_idx + topleft,
                    cur_idx - topleft,
                ],
            )
            data[neighbors] .+= 1

            next_idx = [x for x in neighbors if data[x] > 9]
            append!(queue, next_idx)
        end
        mask = data .> 9
        answer += count(mask)
        data[mask] .= 0
    end
    return answer
end

function part2(data)::Int
    data_indexes = CartesianIndices(data)
    up, right = CartesianIndex(1, 0), CartesianIndex(0, 1)
    topright, topleft = CartesianIndex(1, 1), CartesianIndex(1, -1)

    answer = 0
    while !all(i -> i == 0, data)
        answer += 1
        data .+= 1
        queue = findall(>(9), data)
        seen = Set{CartesianIndex{2}}()

        while !isempty(queue)
            cur_idx = popfirst!(queue)
            if cur_idx in seen
                continue
            end
            push!(seen, cur_idx)
            neighbors = filter(
                x -> x in data_indexes && x ∉ seen,
                [
                    cur_idx + up,
                    cur_idx - up,
                    cur_idx + right,
                    cur_idx - right,
                    cur_idx + topright,
                    cur_idx - topright,
                    cur_idx + topleft,
                    cur_idx - topleft,
                ],
            )
            data[neighbors] .+= 1

            next_idx = [x for x in neighbors if data[x] > 9]
            append!(queue, next_idx)
        end
        mask = data .> 9
        data[mask] .= 0
    end
    return answer
end

data = parse_data(joinpath(@__DIR__, "input.txt"))
println(part1(copy(data)))
println(part2(copy(data)))
