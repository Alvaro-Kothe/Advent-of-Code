# frozen_string_literal: true

require 'set'

def parse_input
  wires = {}
  gates = {}
  ARGF.each do |line|
    line.chomp!
    next if line.empty?

    if line.include?(':')
      wire, value = line.split(': ')
      wires[wire] = value.to_i
    elsif line.include?('->')
      commands, target = line.split(' -> ')
      lhs, op, rhs = commands.split
      raise 'collision' if gates.key?(target)

      gates[target] = [op, lhs, rhs]
    end
  end
  [wires, gates]
end

def operation(op, lhs, rhs)
  case op
  when 'AND'
    lhs & rhs
  when 'OR'
    lhs | rhs
  when 'XOR'
    lhs ^ rhs
  end
end

def get_wire_value(wire, wires, gates)
  return wires[wire] if wires.key?(wire)

  op, lhs, rhs = gates[wire]
  lhs = get_wire_value(lhs, wires, gates)
  rhs = get_wire_value(rhs, wires, gates)
  value = operation(op, lhs, rhs)
  wires[wire] = value
  value
end

def decimal_starting_with(str, wires)
  wires.select { |k,| k.start_with?(str) }.sort.reverse.map { |_, v| v }.join.to_i(2)
end

wires, gates = parse_input

gates.keys.select { |s| s.start_with?('z') }.each { |wire| get_wire_value(wire, wires, gates) }

p1 = decimal_starting_with('z', wires)
puts "Part1: #{p1}"

highest_zkey = gates.keys.select { |s| s.start_with?('z') }.max

wrong = Set.new
gates.each do |target, op|
  o, a, b = op
  wrong << target  if target.start_with?('z') && o != "XOR" && target != highest_zkey
  wrong << target  if o == "XOR" && ! [a, b, target].any? {|s| s =~ /^[xyz]/ }
  if o == "AND" && a != "x00" && b != "x00"
    gates.each_value do |o2, a2, b2|
      wrong << target if o2 != "OR" && (target == a2 || target == b2)
    end
  end
  if o == "XOR"
    gates.each_value do |o2, a2, b2|
      wrong << target if o2 == "OR" && (target == a2 || target == b2)
    end
  end
end

p2 = wrong.sort.join(",")

puts "Part2: #{p2}"
