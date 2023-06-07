function count_overlap(
    filepath::String = joinpath(@__DIR__, "input.txt");
    use_diagonal::Bool = false,
)
    counter = Dict{Tuple{Int,Int},Int}()
    for line in eachline(filepath)
        x1, y1, x2, y2 = parse.(Int64, split(line, r",| -> "))
        dx, dy = sign.([x2 - x1, y2 - y1])
        if !use_diagonal && abs(dx) + abs(dy) > 1
            continue
        end

        while (x1, y1) != (x2 + dx, y2 + dy)
            counter[(x1, y1)] = get!(counter, (x1, y1), 0) + 1
            x1 += dx
            y1 += dy
        end
    end
    return sum(values(counter) .> 1)
end

part1() = count_overlap()
part2() = count_overlap(use_diagonal = true)

println(part1())
println(part2())
