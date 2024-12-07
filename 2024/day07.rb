# frozen_string_literal: true

def parse_line(str)
  lhs, rhs = str.split(': ')
  [lhs.to_i, rhs.split.map(&:to_i)]
end

def valid_equation?(target, numbers, operators, operator, acc)
  first, *rest = numbers
  acc = apply_operator(operator, acc, first)
  return acc == target if rest.empty?
  return false if acc > target

  operators.each do |op|
    return true if valid_equation?(target, rest, operators, op, acc)
  end

  false
end

def apply_operator(operator, lhs, rhs)
  case operator
  when 1
    lhs + rhs
  when 2
    lhs * rhs
  when 3
    concatenate(lhs, rhs)
  end
end

def concatenate(lhs, rhs)
  (lhs.to_s + rhs.to_s).to_i
end

p1 = 0
p2 = 0
ARGF.each do |line|
  line.chomp!
  break if line.empty?

  target, numbers = parse_line(line)
  if valid_equation?(target, numbers, [2, 1], 1, 0)
    p1 += target
    p2 += target
  elsif valid_equation?(target, numbers, [3, 2, 1], 1, 0)
    p2 += target
  end
end

puts "Part1: #{p1}"
puts "Part2: #{p2}"
