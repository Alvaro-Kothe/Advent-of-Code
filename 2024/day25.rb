# frozen_string_literal: true

def parse_input
  locks = []
  keys = []
  STDIN.read.split("\n\n").each do |content|
    grid = content.split("\n")
    is_lock = grid[0] == '#####'
    heights = (0..4).map do |i|
      grid.count { |row| row[i] == '#' } - 1
    end
    if is_lock
      locks << heights
    else
      keys << heights
    end
  end
  [locks, keys]
end

locks, keys = parse_input

p1 = locks.sum do |lock|
  keys.count { |key| key.zip(lock).all? { |k, l| k + l < 6 } }
end

puts "Part1: #{p1}"
