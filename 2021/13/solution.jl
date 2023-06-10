function parse_data(filepath::String = joinpath(@__DIR__, "example.txt"))
    coords, instr = split(read(filepath, String), "\n\n")

    instr_regex = r"(?<axis>[xy])=(?<coord>\d+)"
    instructions = [
        tuple(m["axis"], parse(Int, m["coord"]) + 1) for m in eachmatch(instr_regex, instr)
    ]

    dots = CartesianIndex{2}[]
    for pos in split.(split(coords, "\n"), ",")
        x, y = parse.(Int, pos) .+ 1
        push!(dots, CartesianIndex(y, x))
    end

    max_ = Tuple(maximum(dots))
    grid = falses(max_...)
    grid[dots] .= true

    return grid, instructions
end

function fold(grid::BitMatrix, instructions::Vector)::BitMatrix
    for (axis, pos) in instructions
        nrow, ncol = size(grid)
        if axis == "x"
            left = grid[:, 1:pos-1]
            right_rot = BitMatrix
            try
                right_rot = grid[:, 2*pos-1:-1:pos+1]
            catch
                right_rot = hcat(falses(nrow, 2 * pos - 1 - ncol), grid[:, end:-1:pos+1])
            end
            grid = left .| right_rot
        elseif axis == "y"
            up = grid[1:pos-1, :]
            down_rot = BitMatrix
            try
                down_rot = grid[2*pos-1:-1:pos+1, :]
            catch
                down_rot = vcat(falses(2 * pos - 1 - nrow, ncol), grid[end:-1:pos+1, :])
            end
            grid = up .| down_rot
        end
    end
    return grid
end

function display_grid(grid::BitMatrix)
    plot_grid = fill(' ', size(grid))
    plot_grid[grid] .= '#'

    map(x -> println(join(x)), eachrow(plot_grid))
end

grid, instructions = parse_data(joinpath(@__DIR__, "input.txt"))

println(count(fold(grid, instructions[begin:1])))
final_grid = fold(grid, instructions)
display_grid(final_grid)
