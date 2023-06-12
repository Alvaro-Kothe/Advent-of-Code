function parse_data(filepath = joinpath(@__DIR__, "example.txt"))
    file = read(filepath, String)
    pattern = r"=(-?\d+)..(-?\d+)"
    m = eachmatch(pattern, file)
    (x1, x2), (y1, y2) = m
    return parse.(Int, [x1, x2, y1, y2])
end

function part1(x1, x2, y1, y2)::Int
    m = min(y1, y2)
    return m * (m + 1) / 2
end

function pos_land(x1, x2, y1, y2; x = 0, y = 0, vx, vy)
    if x > max(x1, x2) || y < min(y1, y2)
        return 0
    elseif x1 <= x <= x2 && y1 <= y <= y2
        return 1
    end

    return pos_land(x1, x2, y1, y2, x = x + vx, y = y + vy, vx = vx - (vx > 0), vy = vy - 1)
end

function part2(x1, x2, y1, y2)::Int
    mx = max(x1, x2)
    my = abs(min(y1, y2))
    return sum([pos_land(x1, x2, y1, y2, vx = vx, vy = vy) for vx in 1:mx for vy in -my:my])
end

data = parse_data(joinpath(@__DIR__, "input.txt"))
println(part1(data...))
println(part2(data...))
