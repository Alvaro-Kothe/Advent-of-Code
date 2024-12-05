# frozen_string_literal: true

require 'set'

# Rules will be a hashmap that stores a set.
# The key will come before its values
rules = Hash.new { |hash, key| hash[key] = Set.new }

ARGF.each do |line|
  break if line.strip.empty? # End of rules

  lhs, rhs = line.strip.split('|').map(&:to_i)
  rules[lhs] << rhs
end

def cmp_rule(lhs, rhs, rules)
  return -1 if rules[lhs].include?(rhs) # a should come before
  return 1 if rules[rhs].include?(lhs) # b should come before

  0 # no rule
end

p1 = 0
p2 = 0
# Read page order
ARGF.each do |line|
  next if line.strip.empty?

  pages = line.strip.split(',').map(&:to_i)
  sorted_pages = pages.sort { |a, b| cmp_rule(a, b, rules) }
  middle_page = sorted_pages[sorted_pages.length / 2]
  is_ordered = pages == sorted_pages
  if is_ordered
    p1 += middle_page
  else
    p2 += middle_page
  end
end

puts "Part1: #{p1}"
puts "Part2: #{p2}"
