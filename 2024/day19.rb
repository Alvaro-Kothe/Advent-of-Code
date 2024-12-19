# frozen_string_literal: true

def parse_input
  available_arr, desired = ARGF.read.split("\n\n")
  available_patterns = available_arr.split(', ').to_set
  [available_patterns, desired.split("\n")]
end

def npossible(design, patterns, cache = {})
  return 1 if design.empty?
  return cache[design] if cache.key?(design)

  available_patterns = patterns.select { |prefix| design.start_with?(prefix) }

  counts = if available_patterns.empty?
             0
           else
             available_patterns.sum { |pat| npossible(design.delete_prefix(pat), patterns, cache) }
           end
  cache[design] = counts
  counts
end

available, desired = parse_input

cache = {}
p1 = desired.count { |design| npossible(design, available, cache).positive? }
p2 = desired.sum { |design| npossible(design, available, cache) }

puts "Part1: #{p1}"
puts "Part2: #{p2}"
