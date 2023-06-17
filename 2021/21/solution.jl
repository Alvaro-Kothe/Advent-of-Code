function parse_data(filepath::String = joinpath(@__DIR__, "example.txt"))
    pattern = r"Player (\d+) starting position: (\d+)"
    d = Dict{Int,Vector{Int}}()
    for line in eachline(filepath)
        m = match(pattern, line)
        d[parse(Int, m[1])] = [parse(Int, m[2]), 0]
    end
    return d
end

function part1(data)
    nrols = 0
    data = copy(data)
    while true
        for player in 1:2
            roll = 3 * nrols + 6
            nrols += 3
            data[player][1] = pos = mod1(data[player][1] + roll, 10)
            score = data[player][2] += pos

            if score >= 1000
                losing_player = mod1(player + 1, 2)
                return data[losing_player][2] * nrols
            end
        end
    end
end

cache = Dict{NTuple{4,Int},Vector{Int}}()
function count_wins(
    pos1::T,
    pos2::T;
    score1::T = 0,
    score2::T = 0,
)::AbstractVector{T} where {T<:Integer}
    score2 >= 21 && return [0, 1]

    cur_state = (pos1, pos2, score1, score2)
    if haskey(cache, cur_state)
        return cache[cur_state]
    end
    wins = zeros(T, 2)
    for r1 in 1:3, r2 in 1:3, r3 in 1:3
        new_pos = mod1(pos1 + r1 + r2 + r3, 10)
        new_score = score1 + new_pos
        wins += count_wins(pos2, new_pos, score1 = score2, score2 = new_score) |> reverse
    end
    cache[cur_state] = wins
    return wins
end

function part2(data)::Integer
    wins = count_wins(data[1][1], data[2][1])
    return maximum(wins)
end

data = parse_data(joinpath(@__DIR__, "input.txt"))
println(part1(data))
@time println(part2(data))
