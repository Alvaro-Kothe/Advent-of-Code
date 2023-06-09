function parse_data(filepath::String = joinpath(@__DIR__, "example.txt"))
    fish_timers = parse.(Int, split(readline(filepath), ","))
    return fish_timers
end

function simulate_lanternfish(start_timers, days)
    cycle_counter = [count(==(n), start_timers) for n in 0:8]
    for _ in 1:days
        n_new_fish = popfirst!(cycle_counter)
        cycle_counter[7] += n_new_fish
        push!(cycle_counter, n_new_fish)
    end
    return cycle_counter
end

function part1()
    data = parse_data(joinpath(@__DIR__, "input.txt"))
    return sum(simulate_lanternfish(data, 80))
end

function part2()
    data = parse_data(joinpath(@__DIR__, "input.txt"))
    return sum(simulate_lanternfish(data, 256))
end

println(part1())
println(part2())
