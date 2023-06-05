function parse_data(filepath::String = joinpath(@__DIR__, "example.txt"))
    file = readlines(filepath)
    lines = split.(file, "")
    lines_int = map(x -> parse.(Int8, x), lines)
    return mapreduce(permutedims, vcat, lines_int)
end

data = parse_data("input.txt")

function part1(data)
    most_common = mapslices(x -> (sum(x) / length(x) > 0.5) * 1, data, dims = 1)
    gamma = parse(UInt, join(most_common), base = 2)
    epsilon = parse(UInt, join(1 .- most_common), base = 2)
    return gamma * epsilon
end


function rating(data, index = 1; get_most_common = true)
    n_rows, n_cols = size(data)
    if index > n_cols || n_rows == 1
        return parse(UInt, join(data), base = 2)
    end
    col = data[:, index]
    most_common = (sum(col) / n_rows >= 0.5) * 1
    mask = get_most_common ? col .== most_common : col .!= most_common
    subset = data[mask, :]
    return rating(subset, index + 1, get_most_common = get_most_common)
end

function part2(data)
    or = rating(data)
    co2 = rating(data, get_most_common = false)
    return or * co2
end


println(part1(data))
println(part2(data))
