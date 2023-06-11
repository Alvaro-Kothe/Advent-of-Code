function parse_data(filepath = joinpath(@__DIR__, "example.txt"))
    rows = map(x -> parse.(Int, split(x, "")), readlines(filepath))
    return transpose(reduce(hcat, rows))
end

function dijkstra(grid)
    indices = CartesianIndices(grid)
    start = CartesianIndex(1, 1)
    destiny = maximum(indices)
    up, right = CartesianIndex(1, 0), CartesianIndex(0, 1)

    queue = [tuple(start, 0)]
    seen = Set{CartesianIndex{2}}()
    costs = Dict(start => 0)

    while !isempty(queue)
        lowest_cost_idx = findmin(i -> queue[i][2], eachindex(queue))
        pos, cost = popat!(queue, lowest_cost_idx[2])

        if pos == destiny
            return cost
        end
        push!(seen, pos)

        neighbors = filter(
            x -> x in indices && x ∉ seen,
            [pos + up, pos - up, pos + right, pos - right],
        )
        for nb in neighbors
            new_cost = cost + grid[nb]
            if new_cost < get!(costs, nb, typemax(Int))
                costs[nb] = new_cost
                push!(queue, (nb, new_cost))
            end
        end
    end
end

function extend_grid(grid)
    extended_cols = reduce(hcat, [grid .+ i for i in 0:4])
    extended_rows = reduce(vcat, [extended_cols .+ i for i in 0:4])
    return mod1.(extended_rows, 9)
end

data = parse_data(joinpath(@__DIR__, "input.txt"))
@time println(dijkstra(data))

part2_data = extend_grid(data)
@time println(dijkstra(part2_data))
