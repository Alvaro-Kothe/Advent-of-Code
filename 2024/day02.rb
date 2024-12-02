# frozen_string_literal: true

def inscreasing?(array)
  array.each_cons(2).all? { |a, b| a < b }
end

def decreasing?(array)
  array.each_cons(2).all? { |a, b| a > b }
end

def within_tol?(array, min_tol, max_tol)
  array.each_cons(2).all? { |a, b| (a - b).abs.between?(min_tol, max_tol) }
end

def safe?(array)
  (inscreasing?(array) or decreasing?(array)) and within_tol?(array, 1, 3)
end

def remove_element_by_index(array, index)
  array.dup.tap { |copy| copy.delete_at(index) }
end

def safe_removing?(array)
  array.each_index do |index|
    return true if safe?(remove_element_by_index(array, index))
  end
  false
end

p1 = 0
p2 = 0
ARGF.each do |line|
  next if line.strip.empty?

  numbers = line.split.map(&:to_i)
  if safe?(numbers)
    p1 += 1
    p2 += 1
  elsif safe_removing?(numbers)
    p2 += 1
  end
end

puts "Part1: #{p1}"
puts "Part2: #{p2}"
