# Part 1
open("input.txt") do io
    increase = 0
    prev = Inf
    while !eof(io)
        s = parse(Int64, readline(io))
        increase += s > prev
        prev = s
    end
    println(increase)
end

# Part 2
open("input.txt") do io
    sum_ = 0
    lines_read = 0
    a = Int64[]

    while !eof(io)
        s = parse(Int64, readline(io))
        push!(a, s)
    end
    group_sum = Int64[]
    for i = 1:(length(a)-2)
        push!(group_sum, sum(a[i:i+2]))
    end
    diffs = diff(group_sum)

    println(sum(map(x -> x > 0, diffs)))
end
