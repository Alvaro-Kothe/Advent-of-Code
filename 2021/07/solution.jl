function parse_data(filepath::String = joinpath(@__DIR__, "input.txt"))
    return parse.(Int, split(readline(filepath), ","))
end

function get_middle_point(x)
    sorted_array = sort(x)
    middle_point = div(length(sorted_array), 2)
    return sorted_array[middle_point]
end

function part1(data)::Int
    median_like = get_middle_point(data)
    return sum(abs, data .- median_like)


end

function part2(data)::Int
    mean = (sum(data) / length(data))
    search_space = floor(mean - 0.5):ceil(mean + 0.5)
    return minimum([
        sum(x -> div(x^2 + abs(x), 2), data .- theta) for theta in search_space
    ])
end

data = parse_data()
println(part1(data))
println(part2(data))
