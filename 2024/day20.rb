# frozen_string_literal: true

def parse_input
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
  [walls, start, target]
end

def get_neighbors(pos, walls)
  movements = [1, -1, 0 + 1i, 0 - 1i]
  movements.each do |dpos|
    next_pos = pos + dpos
    yield next_pos unless walls.include?(next_pos)
  end
end

# Get shortest path without cheating
def get_shortest_path(start, target, walls)
  queue = Queue.new
  queue << [start, 0]
  distances = { start => 0 }
  parent_node = {}
  until queue.empty?
    pos, distance = queue.pop
    break if pos == target

    next_distance = distance + 1
    get_neighbors(pos, walls) do |next_pos|
      unless distances.key?(next_pos)
        distances[next_pos] = next_distance
        queue << [next_pos, next_distance]
        parent_node[next_pos] = pos
      end
    end
  end
  path = {}
  backtrack = target
  until backtrack.nil?
    path[backtrack] = distances[backtrack]
    backtrack = parent_node[backtrack]
  end
  path
end

def manhattan_distance(pos1, pos2)
  (pos1.real - pos2.real).abs + (pos1.imag - pos2.imag).abs
end

# Get all jumps with a specific distance
def jumps_with_distance(distance)
  (-distance..distance).each do |x|
    y = distance - x.abs
    yield Complex(x, y)
    yield Complex(x, -y) unless y.zero?
  end
end

def get_time_saved(path, jump_distances = 2..2)
  path.each do |pos, time|
    jump_distances.each do |dst|
      jumps_with_distance(dst) do |dpos|
        next_pos = pos + dpos
        unless (time_next = path[next_pos]).nil?
          time_save = time_next - time - dst
          yield time_save if time_save.positive?
        end
      end
    end
  end
end

walls, start, target = parse_input
path = get_shortest_path(start, target, walls)

p1 = p2 = 0
get_time_saved(path) { |ts| p1 += 1 if ts >= 100 }
get_time_saved(path, 2...21) { |ts| p2 += 1 if ts >= 100 }
puts "Part1: #{p1}"
puts "Part2: #{p2}"
