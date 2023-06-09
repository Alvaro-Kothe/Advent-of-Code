using Statistics: median

function part1(filepath = joinpath(@__DIR__, "example.txt"))::Int
    scores = Dict(')' => 3, ']' => 57, '}' => 1197, '>' => 25137)
    openers = Dict('(' => ')', '[' => ']', '{' => '}', '<' => '>')
    answer = 0
    for line in eachline(filepath)
        queue = Char[]  # Queue first in last out
        for ch in line
            if ch in keys(openers)
                push!(queue, openers[ch])
            else
                expected_char = pop!(queue)
                if ch != expected_char
                    answer += scores[ch]
                    break
                end
            end
        end
    end
    return answer
end

function part2(filepath = joinpath(@__DIR__, "example.txt"))::Int
    scores = Dict(')' => 1, ']' => 2, '}' => 3, '>' => 4)
    openers = Dict('(' => ')', '[' => ']', '{' => '}', '<' => '>')
    line_scores = Int64[]
    for line in eachline(filepath)
        queue = Char[]  # Queue first in last out
        corrupt = false
        line_score = 0
        for ch in line
            if ch in keys(openers)
                push!(queue, openers[ch])
            else
                expected_char = pop!(queue)
                if ch != expected_char
                    corrupt = true
                    break
                end
            end
        end
        if !corrupt
            for ch in reverse(queue)
                line_score = line_score * 5 + scores[ch]
            end
            push!(line_scores, line_score)
        end
    end
    return median(line_scores)
end

println(part1(joinpath(@__DIR__, "input.txt")))
println(part2(joinpath(@__DIR__, "input.txt")))
