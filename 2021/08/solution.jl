function part1(filepath = joinpath(@__DIR__, "example.txt"))::Int
    answer = 0
    len_lookup = [2, 4, 3, 7]
    for line in eachline(filepath)
        _, output = split(line, " | ")
        length_outputs = map(length, split(output))
        answer += sum([count(==(i), length_outputs) for i in len_lookup])
    end
    return answer
end

function decode(output, wire)::Char
    simple = Dict(2 => '1', 4 => '4', 3 => '7', 7 => '8')
    len_out = length(output)

    if len_out in keys(simple)
        return simple[len_out]
    end

    if len_out == 5
        if length(wire[4] ∩ output) == 2
            return '2'
        elseif wire[2] ⊆ output
            return '3'
        end
        return '5'
    end

    if len_out == 6
        if wire[4] ⊆ output
            return '9'
        elseif wire[2] ⊆ output
            return '0'
        end
        return '6'
    end
end

function part2(filepath = joinpath(@__DIR__, "example.txt"))::Int
    answer = 0
    for line in eachline(filepath)
        wire, output = split(line, " | ")
        wire = Dict(length(s) => Set(s) for s in split(wire))

        numeric_string = map(x -> decode(x, wire), split(output)) |> join
        answer += parse(Int, numeric_string)
    end
    return answer
end

println(part1(joinpath(@__DIR__, "input.txt")))
println(part2(joinpath(@__DIR__, "input.txt")))
