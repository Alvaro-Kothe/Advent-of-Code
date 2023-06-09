function parse_matrix(matrix)
    rows_int = [parse.(Int, split(row)) for row in split(matrix, "\n") if !isempty(row)]
    return mapreduce(permutedims, vcat, rows_int)
end

function parse_data(filepath::String = joinpath(@__DIR__, "example.txt"))
    number_draw, cards... = split(read(filepath, String), "\n\n")
    number_draw = parse.(Int, split(number_draw, ","))
    cards_matrix = map(parse_matrix, cards)

    return number_draw, cards_matrix
end

function is_bingo(board)
    for dim in 1:2
        if any(all(i -> i == -1, board, dims = dim))
            return true
        end
    end
    return false
end

mark_number!(board, number) = board[board.==number] .= -1

function part1()
    numbers, boards = parse_data("input.txt")
    bingo = false
    while !bingo
        number_pulled = popfirst!(numbers)
        mark_number!.(boards, number_pulled)

        for bingo_board in boards
            if is_bingo(bingo_board)
                return number_pulled * sum(bingo_board[bingo_board.>0])
            end
        end
    end
end

function part2()
    numbers, boards = parse_data("input.txt")
    for _ in 1:length(numbers)
        number_pulled = popfirst!(numbers)
        mark_number!.(boards, number_pulled)

        not_winners = filter(!is_bingo, boards)
        if length(not_winners) == 1
            last_winner = not_winners[1]
            while !is_bingo(last_winner)
                number_pulled = popfirst!(numbers)
                mark_number!(last_winner, number_pulled)
            end
            return number_pulled * sum(last_winner[last_winner.>0])
        end
    end
end

println(part1())
println(part2())
