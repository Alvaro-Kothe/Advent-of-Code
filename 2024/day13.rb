# frozen_string_literal: true

# Read the button info
def parse_buttons
  result = []
  x = []
  y = []
  prize = []

  $stdin.each do |line|
    numbers = line.scan(/[-+]?\d+/).map(&:to_i)
    case line
    when /Button A:/
      # Put quantity on idx 0
      x = [numbers[0], 0]
      y = [numbers[1], 0]
      prize = [0, 0]
    when /Button B:/
      # put quantity on idx 1
      x[1] = numbers[0]
      y[1] = numbers[1]
    when /Prize:/
      # Put solution
      prize = numbers
    else
      result << [x, y, prize]
    end
  end
  result
end

# Solve the linear system for how many button presses is needed
def button_solution(costx, costy, prize)
  a = [costx.map(&:to_f), costy.map(&:to_f)] # 2x2
  b = prize.map(&:to_f) # 1x2
  fct = a[1][0] / a[0][0]
  a[1].each_index do |i|
    a[1][i] -= a[0][i] * fct
  end
  b[1] -= b[0] * fct
  npresses = [nil, b[1] / a[1][1]]
  npresses[0] = (b[0] - a[0][1] * npresses[1]) / a[0][0]
  npresses.map(&:round)
end

def solution_correct?(movex, movey, solution, target)
  pos = [nil, nil]
  pos[0] = movex[0] * solution[0] + movex[1] * solution[1]
  pos[1] = movey[0] * solution[0] + movey[1] * solution[1]
  pos == target
end

def tokens_needed(pressa, pressb)
  3 * pressa + pressb
end

buttons = parse_buttons

p1 = 0
p2 = 0
buttons.each do |button|
  sol1 = button_solution(*button)
  p1 += tokens_needed(*sol1) if sol1.all? { |tokens| tokens.between?(0, 100) } &&
                                solution_correct?(button[0], button[1], sol1, button[2])
  prize_distant = button[2].map { |el| el + 10_000_000_000_000 }
  sol2 = button_solution(button[0], button[1], prize_distant)
  p2 += tokens_needed(*sol2) if solution_correct?(button[0], button[1], sol2, prize_distant)
end

puts "Part 1: #{p1}"
puts "Part 2: #{p2}"
