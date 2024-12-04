# frozen_string_literal: true

WORD = %w[X M A S].freeze

DIRECTIONS = [[0, 1], [0, -1], [1, 0], [-1, 0], [1, 1], [-1, -1], [1, -1], [-1, 1]].freeze

def position_exists?(grid, row, col)
  row.between?(0, grid.size - 1) && col.between?(0, grid[0].size - 1)
end

def has_word?(idx, word, row, col, dir, grid)
  return false unless position_exists?(grid, row, col) && word[idx] == grid[row][col]
  return true if idx == word.size - 1

  has_word?(idx + 1, word, row + dir[0], col + dir[1], dir, grid)
end

def count_word(grid, word)
  grid.each_with_index.sum do |row, row_idx|
    row.each_with_index.sum do |char, col_idx|
      next 0 unless char == word[0]

      DIRECTIONS.count { |dir| has_word?(0, word, row_idx, col_idx, dir, grid) }
    end
  end
end

def count_cross_pattern(grid, row, col, vertical)
  delta_row, delta_col = vertical ? [1, 0] : [0, 1]
  return 0 unless grid[row + delta_row * 2][col + delta_col * 2] == 'M'

  this_dir = [[1, 1], vertical ? [1, -1] : [-1, 1]]
  other_dir = [vertical ? [-1, 1] : [1, -1], [-1, -1]]
  this_dir.zip(other_dir).count do |td, od|
    has_word?(0, 'MAS', row, col, td, grid) && has_word?(0, 'MAS', row + 2 * delta_row, col + 2 * delta_col, od, grid)
  end
end

def count_mas(grid)
  grid.each_with_index.sum do |row, row_idx|
    row.each_with_index.sum do |char, col_idx|
      next 0 unless char == 'M'

      result = 0
      result += count_cross_pattern(grid, row_idx, col_idx, false) if position_exists?(grid, row_idx, col_idx + 2)
      result += count_cross_pattern(grid, row_idx, col_idx, true) if position_exists?(grid, row_idx + 2, col_idx)
      result
    end
  end
end

grid = []
while (line = gets)
  grid << line.chomp.chars
end

p1 = count_word(grid, WORD)
puts "Part1: #{p1}"
p2 = count_mas(grid)
puts "Part2: #{p2}"
