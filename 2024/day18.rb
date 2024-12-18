# frozen_string_literal: true

# GRID_SIZE = 6
GRID_SIZE = 70

def parse_input
  list = []

  ARGF.each do |str|
    str.chomp!
    break if str.empty?

    x, y = str.split(',').map(&:to_i)
    list << Complex(x, y)
  end
  list
end

def get_neighbors(pos, obstacles)
  movements = [1 + 0i, -1 + 0i, 0 + 1i, 0 - 1i]
  movements.each do |d|
    next_pos = pos + d
    yield next_pos if !obstacles.include?(next_pos) &&
                      next_pos.real.between?(0, GRID_SIZE) &&
                      next_pos.imag.between?(0, GRID_SIZE)
  end
end

def bfs(start, target, obstacles)
  queue = Queue.new
  queue << [start, 0]
  visited = Set[start]
  until queue.empty?
    pos, nsteps = queue.pop
    return nsteps if pos == target

    get_neighbors(pos, obstacles) do |nb|
      unless visited.include?(nb)
        visited << nb
        queue << [nb, nsteps + 1]
      end
    end
  end
  nil
end

# Binary search, the left represent an unblocked state, the right a blocked state
def search_block(nbytes_start, nbytes_block, start, target, byte_list)
  return nbytes_block if nbytes_block - nbytes_start <= 1

  half = (nbytes_start + nbytes_block).div(2)
  obstacles = byte_list.take(half).to_set
  is_blocked = bfs(start, target, obstacles).nil?
  if is_blocked
    search_block(nbytes_start, half, start, target, byte_list)
  else
    search_block(half, nbytes_block, start, target, byte_list)
  end
end

falling_bytes = parse_input

start = 0 + 0i
target = Complex(GRID_SIZE, GRID_SIZE)

p1 = bfs(start, target, falling_bytes.take(1024).to_set)
block_idx = search_block(1024, falling_bytes.size, start, target, falling_bytes) - 1
blocking_byte = falling_bytes[block_idx]
p2 = "#{blocking_byte.real},#{blocking_byte.imag}"

puts "Part1: #{p1}"
puts "Part2: #{p2}"
