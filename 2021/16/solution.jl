@kwdef struct Packet
    version::Int
    id::Int
    value::Union{Int,Nothing} = nothing
    subpackets::Vector{Packet} = Packet[]
end

function parse_data(filepath::String = joinpath(@__DIR__, "input.txt"))::String
    return rstrip(read(filepath, String))
end

function hex2bin(data::String)
    d = Dict(
        '0' => "0000",
        '1' => "0001",
        '2' => "0010",
        '3' => "0011",
        '4' => "0100",
        '5' => "0101",
        '6' => "0110",
        '7' => "0111",
        '8' => "1000",
        '9' => "1001",
        'A' => "1010",
        'B' => "1011",
        'C' => "1100",
        'D' => "1101",
        'E' => "1110",
        'F' => "1111",
    )
    return map(x -> d[x], collect(data)) |> join
end

function get_value(id::Int, subpackets::AbstractArray{<:Packet})::Int
    if id == 0
        return sum(x -> x.value, subpackets)
    elseif id == 1
        return prod(x -> x.value, subpackets)
    elseif id == 2
        return minimum(x -> x.value, subpackets)
    elseif id == 3
        return maximum(x -> x.value, subpackets)
    elseif id == 5
        return subpackets[1].value > subpackets[2].value
    elseif id == 6
        return subpackets[1].value < subpackets[2].value
    elseif id == 7
        return subpackets[1].value == subpackets[2].value
    end
end

function parse_packets(bin::String)
    ver = parse(Int, bin[1:3], base = 2)
    id = parse(Int, bin[4:6], base = 2)
    bin = bin[7:end]

    if id == 4
        literal = ""
        while true
            next_five = bin[1:5]
            literal = literal * next_five[2:5]
            bin = bin[6:end]
            if next_five[1] == '0'
                break
            end
        end
        packet = Packet(version = ver, id = id, value = parse(Int, literal, base = 2))

        return bin, packet
    else
        len_typeid = bin[1]
        bin = bin[2:end]
        if len_typeid == '0'
            sub_len = parse(Int, bin[1:15], base = 2)
            bin = bin[16:end]
            subpacket_bin = bin[1:sub_len]
            subpackets = Packet[]

            while !isempty(subpacket_bin)
                subpacket_bin, subpacket = parse_packets(subpacket_bin)
                push!(subpackets, subpacket)
            end
            packet = Packet(
                version = ver,
                id = id,
                subpackets = subpackets,
                value = get_value(id, subpackets),
            )
            bin = bin[sub_len+1:end]
            return bin, packet
        elseif len_typeid == '1'
            n_sub = parse(Int, bin[1:11], base = 2)
            bin = bin[12:end]
            subpackets = Packet[]
            while length(subpackets) < n_sub
                bin, subpacket = parse_packets(bin)
                push!(subpackets, subpacket)
            end
            packet = Packet(
                version = ver,
                id = id,
                subpackets = subpackets,
                value = get_value(id, subpackets),
            )
            return bin, packet
        end
    end
    return bin, nothing
end

function sum_version(packet::Packet)::Int
    if isempty(packet.subpackets)
        return packet.version
    end
    return packet.version + sum(sum_version, packet.subpackets)
end

function part1(hex::String)::Int
    bin = hex2bin(hex)
    _, packets = parse_packets(bin)
    return sum_version(packets)
end

function part2(hex::String)::Int
    bin = hex2bin(hex)
    _, packets = parse_packets(bin)
    return packets.value
end

data = parse_data()
@time println(part1(data))

@time println(part2(data))
