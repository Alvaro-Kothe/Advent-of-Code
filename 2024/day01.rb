# frozen_string_literal: true

left_list = []
right_list = []
count = Hash.new(0)

ARGF.each do |line|
  next if line.strip.empty?

  numbers = line.split.map(&:to_i)
  left_list << numbers[0]
  right_list << numbers[1]
  count[numbers[1]] += 1
end

sort_left = left_list.sort
sort_right = right_list.sort

p1 = sort_left.zip(sort_right).sum { |l, r| (l - r).abs }
p2 = left_list.sum { |v| v * count[v] }

puts "Part1: #{p1}"
puts "Part2: #{p2}"
