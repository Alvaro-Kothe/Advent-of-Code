function parse_data(filepath = joinpath(@__DIR__, "example.txt"))::Matrix{Char}
    lines = [map(only, split(line, "")) for line in eachline(filepath)]
    return mapreduce(permutedims, vcat, lines)
end

function wrap_position(pos::CartesianIndex, dimsizes)
    out = (mod1(p, d) for (p, d) in zip(Tuple(pos), dimsizes))
    return CartesianIndex(out...)
end
function part1(data::AbstractMatrix{Char})::Integer
    nsteps = 0
    changed = true
    move_direction = Dict('>' => CartesianIndex(0, 1), 'v' => CartesianIndex(1, 0))
    dim_sizes = size(data)
    while changed
        changed = false
        for ch in ">v"
            move_dir = move_direction[ch]
            to_move = findall(==(ch), data)
            filter!(x -> data[wrap_position(x + move_dir, dim_sizes)] == '.', to_move)

            !isempty(to_move) && (changed = true)
            for to_move_idx in to_move
                data[to_move_idx] = '.'
                data[wrap_position(to_move_idx + move_dir, dim_sizes)] = ch
            end
        end
        nsteps += 1
    end
    return nsteps
end

data = parse_data(joinpath(@__DIR__, "input.txt"))
println(part1(data))
