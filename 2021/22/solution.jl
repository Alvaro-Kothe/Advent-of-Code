function parse_data(filepath::String = joinpath(@__DIR__, "example.txt"))
    reboot_steps = Tuple{Bool,Vector{UnitRange}}[]
    for line in eachline(filepath)
        instr, ranges_raw = split(line)
        ranges = UnitRange[]
        for ran in split(ranges_raw, ",")
            x1, x2 = parse.(Int, split(ran[3:end], ".."))
            push!(ranges, x1:x2)
        end
        push!(reboot_steps, (instr == "on", ranges))
    end
    return reboot_steps
end

function part1(data)
    extremities = 1:101
    cube = falses(101, 101, 101)
    for (turnon, ranges) in data
        new_idx = map(x -> intersect(x .+ 51, extremities), ranges)
        cube[new_idx...] .= turnon
    end
    return count(cube)
end

struct Cuboid
    xrange::Tuple{Int,Int}
    yrange::Tuple{Int,Int}
    zrange::Tuple{Int,Int}
end

"Generate new cuboids from this where it doesnt intersect with other"
function difference(this::Cuboid, other::Cuboid)::Union{Vector{Cuboid},Nothing}
    xrange = intersect(UnitRange(this.xrange...), UnitRange(other.xrange...))
    yrange = intersect(UnitRange(this.yrange...), UnitRange(other.yrange...))
    zrange = intersect(UnitRange(this.zrange...), UnitRange(other.zrange...))

    ranges = [xrange, yrange, zrange]
    any(ran.start > ran.stop for ran in ranges) && return nothing

    xrange = extrema(xrange)
    yrange = extrema(yrange)
    zrange = extrema(zrange)

    cuboids = Cuboid[]
    push!(cuboids, Cuboid((this.xrange[1], other.xrange[1] - 1), this.yrange, this.zrange))
    push!(cuboids, Cuboid((xrange[2] + 1, this.xrange[2]), this.yrange, this.zrange))

    push!(cuboids, Cuboid(xrange, (this.yrange[1], yrange[1] - 1), this.zrange))
    push!(cuboids, Cuboid(xrange, (yrange[2] + 1, this.yrange[2]), this.zrange))

    push!(cuboids, Cuboid(xrange, yrange, (this.zrange[1], zrange[1] - 1)))
    push!(cuboids, Cuboid(xrange, yrange, (zrange[2] + 1, this.zrange[2])))

    filter!(valid_cube, cuboids)
    return cuboids
end

function valid_cube(cube::Cuboid)::Bool
    return all(x[1] <= x[2] for x in [cube.xrange, cube.yrange, cube.zrange])
end

function volume(cube::Cuboid)
    return (cube.xrange[2] - cube.xrange[1] + 1) *
           (cube.yrange[2] - cube.yrange[1] + 1) *
           (cube.zrange[2] - cube.zrange[1] + 1)
end

function part2(data)
    cubes = Cuboid[]
    i = 0
    for (turnon, ranges) in data
        i += 1
        new_cube = Cuboid(extrema.(ranges)...)
        for i in reverse(eachindex(cubes))
            cube = cubes[i]
            new_splits = difference(cube, new_cube)
            if !isnothing(new_splits)
                deleteat!(cubes, i)
                append!(cubes, new_splits)
            end
        end
        if turnon
            push!(cubes, new_cube)
        end
    end
    return sum(volume, cubes)
end

data = parse_data(joinpath(@__DIR__, "input.txt"))
println(part1(data))
println(part2(data))
