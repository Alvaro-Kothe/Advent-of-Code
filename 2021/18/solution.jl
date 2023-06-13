import JSON

function parse_data(filepath::String = joinpath(@__DIR__, "example.txt"))
    return [JSON.parse(line) for line in eachline(filepath)]
end

function addition(a, b)
    return _reduce([a, b])
end

function _reduce(pair)
    while true
        change, _, pair, _ = explode(pair)
        if change
            continue
        end

        change, pair = split_(pair)

        if !change
            break
        end
    end
    return pair
end

function split_(pair)
    if isa(pair, Integer)
        if pair >= 10
            d2 = pair / 2
            return true, [floor(Int, d2), ceil(Int, d2)]
        end
        return false, pair
    end
    left, right = pair
    change, left = split_(left)
    if change
        return true, [left, right]
    end
    change, right = split_(right)
    return change, [left, right]
end

function explode(pair, depth::Integer = 0)
    if isa(pair, Integer)
        return false, nothing, pair, nothing
    end
    left, right = pair
    if depth == 4
        return true, left, 0, right
    end
    explode_left, a, left, b = explode(left, depth + 1)
    if explode_left
        return true, a, [left, addleft(right, b)], nothing
    end
    explode_right, a, right, b = explode(right, depth + 1)
    if explode_right
        return true, nothing, [addright(left, a), right], b
    end

    return false, nothing, [left, right], nothing
end

function addright(pair, n)
    if isa(n, Nothing)
        return pair
    elseif isa(pair, Integer)
        return pair + n
    end
    return [pair[1], addright(pair[2], n)]
end
function addleft(pair, n)
    if isa(n, Nothing)
        return pair
    elseif isa(pair, Integer)
        return pair + n
    end
    return [addleft(pair[1], n), pair[2]]
end

function magnitude(pair)::Integer
    if isa(pair, Integer)
        return pair
    end
    left, right = pair
    return 3 * magnitude(left) + 2 * magnitude(right)
end
function part1(data)
    final_list = reduce(addition, data)
    return magnitude(final_list)
end

function part2(data)::Integer
    ans = 0
    for i in eachindex(data), j in eachindex(data)
        if i == j
            continue
        end
        ans = max(
            ans,
            magnitude(addition(data[i], data[j])),
            magnitude(addition(data[j], data[i])),
        )
    end
    return ans
end

data = parse_data(joinpath(@__DIR__, "input.txt"))

println(part1(data))
println(part2(data))
