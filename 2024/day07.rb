# frozen_string_literal: true

def parse_line(str)
  lhs, rhs = str.split(': ')
  [lhs.to_i, rhs.split.map(&:to_i)]
end

# Return a boolean, indicating if the operation is valid, and the result from the operation, which is the new rhs
def verify_operator(operator, target, rhs)
  case operator
  when 1 # Sum
    [true, target - rhs]
  when 2 # Product
    q, r = target.divmod(rhs)
    [r.zero?, q]
  when 3 # Concatenation
    # Need to verify if the target ends with the rhs
    n = rhs.to_s.length
    target_str = target.to_s
    left = target_str[0...-n].to_i
    right = target_str[-n..].to_i
    [right == rhs, left]
  end
end

def valid_equation?(target, numbers, operators)
  *rest, tail = numbers
  return tail == target if rest.empty?

  operators.each do |op|
    valid, new_target = verify_operator(op, target, tail)
    return true if valid && valid_equation?(new_target, rest, operators)
  end
  false
end

p1 = 0
p2 = 0
ARGF.each do |line|
  line.chomp!
  break if line.empty?

  target, numbers = parse_line(line)
  if valid_equation?(target, numbers, [2, 1])
    p1 += target
    p2 += target
  elsif valid_equation?(target, numbers, [3, 2, 1])
    p2 += target
  end
end

puts "Part1: #{p1}"
puts "Part2: #{p2}"
