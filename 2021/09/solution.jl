function parse_data(filepath = joinpath(@__DIR__, "example.txt"))
    a = [parse.(Int, split(line, "")) for line in eachline(filepath)]
    return transpose(reduce(hcat, a))
end

function part1(data)
    answer = 0
    nrow, ncol = size(data)

    for j in 1:ncol, i in 1:nrow
        cur_val = data[i, j]
        neighbours = [
            data[i+i_, j+j_] for i_ in -1:1, j_ in -1:1 if
            1 <= i + i_ <= nrow && 1 <= j + j_ <= ncol && abs(i_) != abs(j_)
        ]
        if cur_val < minimum(neighbours)
            answer += 1 + cur_val
        end
    end
    return answer
end

function part2(data)
    # https://julialang.org/blog/2016/02/iteration/
    matrix_indices = CartesianIndices(data)
    up = CartesianIndex(1, 0)
    right = CartesianIndex(0, 1)

    basin = CartesianIndex{2}[]

    for pos in matrix_indices
        neighbors_idx =
            filter(x -> x in matrix_indices, [pos + up, pos - up, pos + right, pos - right])
        if data[pos] < minimum(idx_nei -> data[idx_nei], neighbors_idx)
            push!(basin, pos)
        end
    end

    basin_sizes = Int64[]
    for pos in basin
        seen = Set{CartesianIndex{2}}()
        queue = [pos]

        size = 0
        while !isempty(queue)
            cur_pos = popfirst!(queue)

            if cur_pos ∈ seen
                continue
            end

            push!(seen, cur_pos)
            size += 1

            next_idx = filter(
                x -> x in matrix_indices && data[x] < 9,
                [cur_pos + up, cur_pos - up, cur_pos + right, cur_pos - right],
            )
            append!(queue, next_idx)
        end

        push!(basin_sizes, size)
    end
    return partialsort(basin_sizes, 1:3, rev = true) |> prod
end

data = parse_data(joinpath(@__DIR__, "input.txt"))

println(part1(data))
println(part2(data))
