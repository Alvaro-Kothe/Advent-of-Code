function parse_data(filepath::String = joinpath(@__DIR__, "input.txt"))::Dict
    graph = Dict{String,Vector{<:String}}()
    for line in eachline(filepath)
        node1, node2 = split(line, '-')
        push!(get!(graph, node1, String[]), node2)
        push!(get!(graph, node2, String[]), node1)
    end
    return graph
end

function dfs(
    data::Dict;
    visited = Set(),
    current_node = "start",
    revisit_small = false,
)::Integer
    if current_node == "end"
        return 1
    elseif all(islowercase, current_node) && current_node in visited
        if current_node == "start" || !revisit_small
            return 0
        else
            revisit_small = false
        end
    end

    return sum(
        nd -> dfs(
            data,
            visited = union(visited, [current_node]),
            current_node = nd,
            revisit_small = revisit_small,
        ),
        data[current_node],
    )
end

data = parse_data(joinpath(@__DIR__, "input.txt"))

@time println(dfs(data))
@time println(dfs(data, revisit_small = true))
