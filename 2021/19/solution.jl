coord_permutations = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 2, 1], [3, 1, 2]]
directions_permutations = [
    [1, 1, 1],
    [1, 1, -1],
    [1, -1, 1],
    [1, -1, -1],
    [-1, 1, 1],
    [-1, 1, -1],
    [-1, -1, 1],
    [-1, -1, -1],
]

ROTATIONS = Vector{Int}[]
for coord_per in coord_permutations, dir in directions_permutations
    # number or rotations (0 -> change nothing, 1 -> rotate 2 axis, 2 -> change all axis)
    n_changes = max(0, count(coord_per .!= [1, 2, 3]) - 1) + count(dir .!= [1, 1, 1])
    # To respect the right hand rule the number of rotations + number of inversions must be even
    n_changes % 2 == 0 && push!(ROTATIONS, coord_per .* dir)
end

@assert allunique(ROTATIONS) && length(ROTATIONS) == 24

function apply_rotation(pos, rotation)
    new_pos = pos[abs.(rotation)]
    return new_pos .* sign.(rotation)
end

function parse_data(filepath::String = joinpath(@__DIR__, "example.txt"))
    scanners = Dict{Int,Vector{Vector{Int}}}()
    scanners_strings = split(read(filepath, String), "\n\n")
    scanner_regex = r"scanner (\d+)"

    for scanner_string in scanners_strings
        b = split(scanner_string, "\n", keepempty = false)
        scanner_id = match(scanner_regex, popfirst!(b)).captures[1]
        positions = map(x -> parse.(Int, split(x, ',')), b)
        scanners[parse(Int, scanner_id)] = positions
    end
    return scanners
end

"Compute the distances between the beacons"
function generate_distances(beacons::AbstractArray)
    distance_array = Dict(
        (i, j) => (sum(abs2, beacons[i] .- beacons[j])) for i in eachindex(beacons) for
        j in eachindex(beacons) if i < j
    )

    return distance_array
end

findkeys(d::AbstractDict, value) = [k for (k, v) in d if v == value]

function find_common_beacons(beacons1, beacons2)
    first_beacon_distances = generate_distances(beacons1)
    second_beacon_distances = generate_distances(beacons2)

    common_distances =
        intersect(values(first_beacon_distances), values(second_beacon_distances))

    common1 = Vector{Int}[]
    common2 = Vector{Int}[]
    idx1 = Set{Int}()
    idx2 = Set{Int}()
    for dist in common_distances
        key1 = Iterators.flatten(findkeys(first_beacon_distances, dist))
        key2 = Iterators.flatten(findkeys(second_beacon_distances, dist))
        append!(common1, [beacons1[i] for i in key1 if i ∉ idx1])
        append!(common2, [beacons2[i] for i in key2 if i ∉ idx2])
        union!(idx1, key1)
        union!(idx2, key2)
    end
    return common1, common2
end

function get_scanner_position(common1::AbstractArray, common2::AbstractArray)
    for pos1 in common1, pos2 in common2, rot in ROTATIONS
        rot_p2 = apply_rotation(pos2, rot)
        scanner_position = pos1 - rot_p2
        common2_rotates = [apply_rotation(p2, rot) .+ scanner_position for p2 in common2]
        if length(intersect(common1, common2_rotates)) >= min(length(common1), 12)
            return (scanner_position, rot)
        end
    end
    return nothing, nothing
end

function get_beacons(scanners::AbstractDict; ref_scanner = 0)
    beacons_rel_ref = Set(scanners[ref_scanner])
    redudant_scanners = Set(ref_scanner)
    beacons_ref = [scanners[ref_scanner]]
    scanners_positions = Dict(ref_scanner => [0, 0, 0])

    while length(redudant_scanners) < length(scanners)
        for bref in beacons_ref, (scanner, beacons) in scanners
            scanner in redudant_scanners && continue

            cref, common = find_common_beacons(bref, beacons)

            scanner_position, rotation = get_scanner_position(cref, common)

            isnothing(scanner_position) && continue

            rotated_beacons =
                [apply_rotation(beacon, rotation) .+ scanner_position for beacon in beacons]
            union!(beacons_rel_ref, rotated_beacons)
            push!(beacons_ref, rotated_beacons)
            push!(redudant_scanners, scanner)
            scanners_positions[scanner] = scanner_position
        end
    end
    return beacons_rel_ref, scanners_positions
end

function part1(data)
    return length(get_beacons(data, ref_scanner = 0)[1])
end

function part2(data)
    _, scanners_positions = get_beacons(data, ref_scanner = 0)
    scanners_positions = collect(values(scanners_positions))

    return maximum([
        sum(abs, scanners_positions[i] - scanners_positions[j]) for
        i in eachindex(scanners_positions), j in eachindex(scanners_positions) if i < j
    ])
end

data = parse_data(joinpath(@__DIR__, "input.txt"))

@time println(part1(data))
@time println(part2(data))
