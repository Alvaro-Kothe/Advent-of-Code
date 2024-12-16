# frozen_string_literal: true

require_relative 'priority_queue'

# Store start position, end position and walls
def parse_grid
  walls = Set.new
  start = nil
  target = nil
  ARGF.each.with_index do |row, i|
    row.chomp!
    break if row.empty?

    row.each_char.with_index do |char, j|
      pos = Complex(i, j)
      case char
      when '#'
        walls << pos
      when 'S'
        start = pos
      when 'E'
        target = pos
      end
    end
  end
  [start, target, walls]
end

def get_neighbors(position, direction, walls)
  # Move
  next_pos = position + direction
  yield [next_pos, direction, 1] unless walls.include?(next_pos)
  # turn
  turn_directions = [-1i, 1i]
  turn_directions.each do |td|
    new_direction = direction * td
    yield [position, new_direction, 1000]
  end
end

def dijkstra(start, start_dir, target, walls)
  queue = PriorityQueue.new
  queue << [0, start, start_dir]
  distances = { [start, start_dir] => 0 }
  path = {}
  best = nil
  backtrack_queue = []

  until queue.empty?
    score, pos, dir = queue.pop
    cur_key = [pos, dir]

    next if !best.nil? && score > best

    if pos == target
      best = score
      backtrack_queue << cur_key
    end

    get_neighbors(pos, dir, walls) do |next_pos, next_direction, cost|
      key = [next_pos, next_direction]
      next_cost = cost + score
      if !distances.key?(key) || next_cost < distances[key]
        distances[key] = next_cost
        queue << [next_cost, next_pos, next_direction]
        path[key] = [cur_key] # Store path to traceback
      elsif next_cost == distances[key] # Equally good path
        path[key] << cur_key
      end
    end
  end
  visited = Set.new
  until backtrack_queue.empty?
    key = backtrack_queue.pop
    visited << key.first
    backtrack_queue.concat(path[key]) unless path[key].nil?
  end
  [best, visited.size]
end

start, target, walls = parse_grid

p1, p2 = dijkstra(start, 1i, target, walls)

puts "Part1: #{p1}"
puts "Part2: #{p2}"
