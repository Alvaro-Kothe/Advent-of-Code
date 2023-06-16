function parse_data(filepath = joinpath(@__DIR__, "example.txt"))
    im_en_al, input_image = split(read(filepath, String), "\n\n")

    iea = Dict(i - 1 => v for (i, v) in enumerate(split(im_en_al, "") .== "#"))
    @assert length(iea) == 512

    image = map(x -> split(x, "") .== "#", split(input_image, "\n", keepempty = false))

    return transpose(reduce(hcat, image)), iea
end

function convolve2d(
    input::AbstractMatrix,
    kernel::AbstractMatrix,
    padding::Integer = 0;
    fillvalue = zero(eltype(input)),
)
    if padding > 0
        input_padded = fill(fillvalue, size(input) .+ padding * 2)
        offset = CartesianIndex(padding, padding)
        for idx in CartesianIndices(input)
            input_padded[idx+offset] = input[idx]
        end
        input = input_padded
    end

    out = zeros(eltype(kernel), size(input) .- size(kernel) .+ 1)

    offset = CartesianIndex(-1, -1)
    for idx in CartesianIndices(out), keridx in CartesianIndices(kernel)
        out[idx] += input[idx+keridx+offset] * kernel[keridx]
    end
    return out
end

function apply_algorithim(input::AbstractMatrix, alg::AbstractDict)::AbstractMatrix
    out = similar(input, Bool)
    for I in CartesianIndices(input)
        out[I] = alg[input[I]]
    end
    return out
end

function enhance(image, alg; times = 2)
    kernel = transpose(reshape(2 .^ collect(8:-1:0), 3, 3))

    fillvalue = false
    for _ in 1:times
        convolved_image = convolve2d(image, kernel, 2, fillvalue = fillvalue)

        image = apply_algorithim(convolved_image, alg)
        fillvalue = alg[fillvalue ? 511 : 0]
    end
    return count(image)
end

image, alg = parse_data(joinpath(@__DIR__, "input.txt"))
@time println(enhance(image, alg, times = 2))
@time println(enhance(image, alg, times = 50))
