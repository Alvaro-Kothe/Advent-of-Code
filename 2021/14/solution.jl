function parse_data(filepath::String = joinpath(@__DIR__, "example.txt"))
    template, pair_insertion_list = split(read(filepath, String), "\n\n")
    pair_insertion = Dict{String,Char}()
    for line in split(pair_insertion_list, "\n", keepempty = false)
        pair, ch = split(line, " -> ")
        pair_insertion[pair] = only(ch)
    end
    return template, pair_insertion
end

function simulate(template, pair_insertion; times = 10)::Int
    char_counter = Dict{Char,Int}()
    pair_counter = Dict{String,Int}()

    char_counter[template[1]] = 1
    for (ch1, ch2) in zip(template, template[2:end])
        char_counter[ch2] = get!(char_counter, ch2, 0) + 1
        pair_counter[ch1*ch2] = get!(pair_counter, ch1 * ch2, 0) + 1
    end

    for _ in 1:times
        for ((ch1, ch2), count) in pairs(copy(pair_counter))
            cur_pair = ch1 * ch2
            created_element = pair_insertion[cur_pair]

            pair_counter[cur_pair] -= count
            pair_counter[created_element*ch2] =
                get!(pair_counter, created_element * ch2, 0) + count
            pair_counter[ch1*created_element] =
                get!(pair_counter, ch1 * created_element, 0) + count
            char_counter[created_element] = get!(char_counter, created_element, 0) + count
        end
    end
    count_min, count_max = extrema(values(char_counter))
    return count_max - count_min
end

data = parse_data(joinpath(@__DIR__, "input.txt"))
@time println(simulate(data...))
@time println(simulate(data..., times = 40))
