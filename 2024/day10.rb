# frozen_string_literal: true

require 'set'

def parse_grid
  $stdin.read.split("\n").map { |line| line.chars.map(&:to_i) }
end

def get_height(grid, pos)
  return nil unless pos[0].between?(0, grid.size - 1) && pos[1].between?(0, grid[0].size - 1)

  grid[pos[0]][pos[1]]
end

def get_neighbors(grid, pos)
  movements = [[1, 0], [-1, 0], [0, 1], [0, -1]]
  cur_height = get_height(grid, pos)
  movements.each do |dx, dy|
    nx = pos[0] + dx
    ny = pos[1] + dy
    next_pos = [nx, ny]
    next_height = get_height(grid, next_pos)
    next if next_height.nil? || next_height - cur_height != 1

    yield next_pos
  end
end

def search_heights(grid, value)
  result = []
  grid.each.with_index do |row, i|
    row.each.with_index do |height, j|
      result << [i, j] if height == value
    end
  end
  result
end

def get_scores_from_zero(grid, rating)
  scores = {}
  queue = search_heights(grid, 0)
  result = queue.each.sum do |trailhead|
    _get_score(grid, trailhead, scores, rating)
  end
  [result, scores]
end

def _get_score(grid, pos, table, rating, visited = Set.new)
  if rating # Part 2
    return table[pos] if table.key?(pos)
  else # Part 1
    return 0 if visited.include?(pos)

    visited.add(pos)
  end

  return 1 if get_height(grid, pos) == 9

  score = 0
  get_neighbors(grid, pos) do |nb|
    score += _get_score(grid, nb, table, rating, visited)
  end
  table[pos] = score
  score
end

grid = parse_grid

p1, = get_scores_from_zero(grid, false)
p2, = get_scores_from_zero(grid, true)

puts "Part1: #{p1}"
puts "Part2: #{p2}"
