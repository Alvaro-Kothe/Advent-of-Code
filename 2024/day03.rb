# frozen_string_literal: true

mul_regex = /mul\((\d{1,3}),(\d{1,3})\)/
string = STDIN.read

match = string.scan(mul_regex)
p1 = match.sum { |a, b| a.to_i * b.to_i }
puts "Part1: #{p1}"

def validchar?(char, enabled)
  enabled ? "do()don'tmul0123456789,".include?(char) : 'do()'.include?(char)
end

stack = ''
num = 0
enabled = true
capture_number = false
result = 0

string.each_char do |c|
  unless validchar?(c, enabled)
    stack.clear
    capture_number = false
    next
  end

  # Mul instruction
  if capture_number
    if c == ',' && stack.length.between?(1, 3)
      num = stack.to_i
      stack.clear
    elsif c == ')' && stack.length.between?(1, 3)
      result += num * stack.to_i
      capture_number = false
      stack.clear
    elsif c.match?(/[[:digit:]]/)
      stack += c
    else
      stack.clear
      capture_number = false
    end
  else
    if c.match?(/[[:digit:]]/)
      stack.clear
      next
    end
    stack += c
    if stack.end_with? 'do()'
      enabled = true
      stack.clear
    elsif stack.end_with? "don't()"
      enabled = false
      stack.clear
    elsif stack.end_with? 'mul('
      capture_number = true
      stack.clear
    end
  end
end

puts "Part2: #{result}"
