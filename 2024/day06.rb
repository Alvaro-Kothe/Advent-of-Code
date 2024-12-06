# frozen_string_literal: true

require 'set'

class Guard
  attr_accessor :pos, :dir

  def initialize(pos, dir = [-1, 0])
    @pos = pos
    @dir = dir
  end

  def follow_protocol(obstacles, nrow, ncol)
    next_pos = [@pos[0] + @dir[0], @pos[1] + @dir[1]]
    return :out unless next_pos[0].between?(0, nrow) && next_pos[1].between?(0, ncol)

    obstacles.include?(next_pos) ? :turn : :move
  end

  def move
    @pos = [@pos[0] + @dir[0], @pos[1] + @dir[1]]
  end

  def turn_right
    @dir = [@dir[1], -@dir[0]]
  end
end

def parse_grid
  nrow = 0
  ncol = 0
  obstacles = Set.new
  guard_pos = nil

  ARGF.each do |line|
    line.chomp!
    break if line.empty?

    ncol = line.size if nrow.zero?
    line.each_char.with_index do |char, col|
      obstacles.add([nrow, col]) if char == '#'
      guard_pos = [nrow, col] if char == '^'
    end
    nrow += 1
  end
  [nrow - 1, ncol - 1, obstacles, Guard.new(guard_pos)]
end

def display_grid(nrow, ncol, obstacles, visited)
  (0..nrow).each do |row|
    (0..ncol).each do |col|
      if obstacles.include?([row, col])
        print '#'
      elsif visited.include?([row, col])
        print 'X'
      else
        print '.'
      end
    end
    puts
  end
end

nrow, ncol, obstacles, guard_original = parse_grid

guard = guard_original.dup

distinct_positions = Set.new
loop do
  distinct_positions << guard.pos
  case guard.follow_protocol(obstacles, nrow, ncol)
  when :out
    break
  when :turn
    guard.turn_right
  when :move
    guard.move
  end
end

puts "Part1: #{distinct_positions.size}"

def loop?(nrow, ncol, obstacles, guard)
  distinct_states = Set.new
  loop do
    case guard.follow_protocol(obstacles, nrow, ncol)
    when :out
      return false
    when :turn
      guard.turn_right
      return true if distinct_states.add?([guard.pos, guard.dir]).nil?
    when :move
      guard.move
      return true if distinct_states.add?([guard.pos, guard.dir]).nil?
    end
  end
end

p2 = distinct_positions.count { |new_obstacle| loop?(nrow, ncol, obstacles | [new_obstacle], guard_original.dup) }

puts "Part2: #{p2}"
