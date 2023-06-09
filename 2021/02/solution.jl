using DelimitedFiles

data = readdlm("input.txt")

function part1(data)
    depth = horizontal = 0
    for (command, value) in eachrow(data)
        if command == "forward"
            horizontal += value
        elseif command == "down"
            depth += value
        elseif command == "up"
            depth -= value
        end
    end
    return depth * horizontal
end

function part2(data)
    aim = depth = horizontal = 0
    for (command, value) in eachrow(data)
        if command == "forward"
            horizontal += value
            depth += aim * value
        elseif command == "down"
            aim += value
        elseif command == "up"
            aim -= value
        end
    end
    return depth * horizontal
end

println(part1(data))
println(part2(data))
