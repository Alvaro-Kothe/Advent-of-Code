# frozen_string_literal: true

def blink(stone, blinks, table)
  return 1 if blinks.zero?

  key = [stone, blinks]
  return table[key] if table.key?(key)

  nstones = 1
  if stone.zero?
    nstones = blink(1, blinks - 1, table)
  elsif (digits = Math.log10(stone).to_i + 1).even?
    div = 10**(digits / 2)
    lstone = stone / div
    rstone = stone % div
    nstones = blink(lstone, blinks - 1, table) + blink(rstone, blinks - 1, table)
  else
    nstones = blink(stone * 2024, blinks - 1, table)
  end
  table[key] = nstones
  nstones
end

def parse_input
  gets.chomp.split.map(&:to_i)
end

stone_numbers = parse_input

lookuptbl = {}

p1 = stone_numbers.each.sum { |stone| blink(stone, 25, lookuptbl) }

p2 = stone_numbers.each.sum { |stone| blink(stone, 75, lookuptbl) }

puts "Part1: #{p1}"
puts "Part2: #{p2}"
