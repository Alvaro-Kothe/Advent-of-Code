is_str_number(str::AbstractString) = all(x -> isdigit(x) || x == '-', str)

function parse_data(filepath = joinpath(@__DIR__, "input.txt"))
    instructions = Tuple[]
    for line in eachline(filepath)
        op, rhs... = split(line)
        if op == "inp"
            push!(instructions, (op, rhs))
        else
            var, var2 = rhs
            is_str_number(var2) && (var2 = parse(Int, var2))
            push!(instructions, (op, only(var), var2))
        end
    end
    return instructions
end

function part1(instructions)
    serial_number = parse(Int, '9'^14)
    stack = []
    for i in 0:13
        addx_value = instructions[18*i+6][3]
        addy_value = instructions[18*i+16][3]

        addx_value > 0 && (push!(stack, (i, addy_value)); continue)

        j, prev_addy = pop!(stack)
        idx = addx_value > -prev_addy ? j : i
        serial_number -= abs((addx_value + prev_addy) * 10^(13 - idx))
    end
    return serial_number
end

function part2(instructions)
    serial_number = parse(Int, '1'^14)
    stack = []
    for i in 0:13
        addx_value = instructions[18*i+6][3]
        addy_value = instructions[18*i+16][3]

        addx_value > 0 && (push!(stack, (i, addy_value)); continue)

        j, prev_addy = pop!(stack)
        idx = addx_value < -prev_addy ? j : i
        serial_number += abs((addx_value + prev_addy) * 10^(13 - idx))
    end
    return serial_number
end

data = parse_data()

println(part1(data))
println(part2(data))
