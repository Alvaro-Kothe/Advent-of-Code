# frozen_string_literal: true

def parse_input
  result = Hash.new { |hash, key| hash[key] = Set.new }
  ARGF.each do |line|
    line.chomp!
    next if line.empty?

    a, b = line.split('-')
    result[a] << b
    result[b] << a
  end
  result
end

def bron_kerbosch(clique, candidates, processed, graph, cliques = [])
  if candidates.empty? && processed.empty?
    cliques << clique
    return
  end

  pivot = (candidates | processed).max_by(&:size)
  (candidates - graph[pivot]).each do |node|
    bron_kerbosch(clique | [node], candidates & graph[node], processed & graph[node], graph, cliques)
    candidates.delete(node)
    processed << node
  end
  cliques
end

graph = parse_input

visited = Set.new
p1 = graph.keys.select { |s| s.start_with?('t') }.sum do |a|
  visited << a
  connections = graph[a]
  connections.to_a.combination(2).count { |b, c| graph[b].include?(c) && !visited.include?(b) && !visited.include?(c) }
end

puts "Part1: #{p1}"

p2 = bron_kerbosch([], graph.keys.to_set, Set.new, graph).max_by(&:size).sort.join(',')
puts "Part2: #{p2}"
