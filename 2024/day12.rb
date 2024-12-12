# frozen_string_literal: true

def parse_grid
  result = {}
  ARGF.each.with_index do |line, row|
    line.chomp.each_char.with_index do |char, col|
      result[Complex(row, col)] = char
    end
  end
  result
end

def get_neighbors(pos)
  movements = [1, -1, 0 + 1i, 0 - 1i]
  move_types = %i[vertical vertical horizontal horizontal]
  movements.zip(move_types).each do |move, move_type|
    next_pos = pos + move
    yield [next_pos, move_type]
  end
end

def create_or_merge_line(pos, original_pos, move_type, lines)
  case move_type
  when :vertical
    line_key = [pos.real, nil, original_pos.real]
    line_range_value = pos.imag
  when :horizontal
    line_key = [nil, pos.imag, original_pos.imag]
    line_range_value = pos.real
  end

  unless lines.key?(line_key)
    lines[line_key] = [[line_range_value, line_range_value]]
    return
  end
  # Check all the known sides in a row/column
  lines[line_key].each do |range|
    range_l, range_r = range
    # Extend if it's adjacent
    if range_l - 1 == line_range_value
      range[0] = line_range_value
      return
    elsif range_r + 1 == line_range_value
      range[1] = line_range_value
      return
    end
  end
  lines[line_key] << [line_range_value, line_range_value]
  nil
end

def intersect_ranges(ranges)
  sorted_ranges = ranges.sort_by { |range| range[0] }
  merged = []

  sorted_ranges.each do |current_range|
    if merged.empty? || current_range[0] > merged.last[1] + 1
      merged << current_range
    else
      merged.last[1] = [merged.last[1], current_range[1]].max
    end
  end

  merged
end

def get_area_info(startpos, grid)
  area = 0
  perimiter = 0
  visited = Set[startpos]
  queue = [startpos]
  type = grid[startpos]
  # hashmap containing all ranges in a row/column
  sides = {}

  until queue.empty?
    cur_pos = queue.pop
    visited << cur_pos
    area += 1
    get_neighbors(cur_pos) do |next_pos, move_type|
      next_type = grid[next_pos]
      if next_type.nil? || next_type != type
        perimiter += 1
        # extend side
        create_or_merge_line(next_pos, cur_pos, move_type, sides)
      elsif !visited.include?(next_pos)
        visited << next_pos
        queue << next_pos
      end
    end
  end
  # fix bad ranges because of bad order from bfs.
  sides.transform_values! { |ranges| intersect_ranges(ranges) }
  [area, perimiter, type, visited, sides]
end

grid = parse_grid
to_visit = grid.keys.to_set

p1 = 0
p2 = 0
until to_visit.empty?
  to_explore = to_visit.take(1)[0]
  area, per, _type, visited, sides = get_area_info(to_explore, grid)
  to_visit.subtract(visited)
  p1 += area * per
  nsides = sides.values.sum(&:size)
  p2 += area * nsides
end

puts "Part1: #{p1}"
puts "Part2: #{p2}"
