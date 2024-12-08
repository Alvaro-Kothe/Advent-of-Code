# frozen_string_literal: true

require 'set'

def parse_grid
  antennas = Hash.new { |hash, key| hash[key] = [] }
  nrow = 0
  ncol = 0
  ARGF.each.with_index do |str, row|
    str.chomp!
    break if str.empty?

    ncol = str.size if row.zero?
    str.each_char.with_index do |char, col|
      antennas[char] << [row, col] unless char == '.'
    end
    nrow += 1
  end
  [antennas, nrow - 1, ncol - 1]
end

def get_antinodes(antennas, nrow, ncol, many)
  antinodes = Set.new
  antennas.each_value do |positions|
    positions.each.with_index do |pos1, i|
      positions.drop(i + 1).each do |pos2|
        antinodes.merge(antinode_positions(pos1, pos2, nrow, ncol, many))
      end
    end
  end
  antinodes
end

def antinode_positions(pos1, pos2, nrow, ncol, many)
  x1, y1 = pos1
  x2, y2 = pos2
  dx = x1 - x2
  dy = y1 - y2
  nx1 = x1 + dx
  ny1 = y1 + dy
  antinodes = many ? [[x1, y1], [x2, y2]] : []
  while nx1.between?(0, nrow) && ny1.between?(0, ncol)
    antinodes << [nx1, ny1]
    nx1 += dx
    ny1 += dy
    break unless many
  end
  nx2 = x2 - dx
  ny2 = y2 - dy
  while nx2.between?(0, nrow) && ny2.between?(0, ncol)
    antinodes << [nx2, ny2]
    nx2 -= dx
    ny2 -= dy
    break unless many
  end
  antinodes
end

antennas, nrow, ncol = parse_grid
antinodes = get_antinodes(antennas, nrow, ncol, false)
antinodes2 = get_antinodes(antennas, nrow, ncol, true)

p1 = antinodes.size
p2 = antinodes2.size

puts "Part1: #{p1}"
puts "Part2: #{p2}"
