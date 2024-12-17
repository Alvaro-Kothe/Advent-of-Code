# frozen_string_literal: true

def parse_input
  registers = {}
  program = []

  ARGF.each do |line|
    line.chomp!
    next if line.strip.empty?

    if line =~ /Register (\w): (\d+)/
      registers[Regexp.last_match(1)] = Regexp.last_match(2).to_i
    elsif line =~ /Program: (.+)/
      program = Regexp.last_match(1).split(',').map(&:to_i)
    end
  end

  [registers, program]
end

def run_program(registers, program, verify_copy = false)
  inst_ptr = 0
  out = []

  while inst_ptr < program.size
    opcode = program[inst_ptr]
    literal_operand = program[inst_ptr + 1]

    case opcode
    when 0
      registers['A'] = registers['A'].div(1 << get_combo(registers, literal_operand))
    when 1
      registers['B'] ^= literal_operand
    when 2
      registers['B'] = get_combo(registers, literal_operand) % 8
    when 3
      if registers['A'] != 0
        inst_ptr = literal_operand
        next
      end
    when 4
      registers['B'] ^= registers['C']
    when 5
      out << get_combo(registers, literal_operand) % 8
      if verify_copy
        k = out.size - 1
        return out if out[k] != program[k]
      end
    when 6
      registers['B'] = registers['A'].div(1 << get_combo(registers, literal_operand))
    when 7
      registers['C'] = registers['A'].div(1 << get_combo(registers, literal_operand))
    end

    inst_ptr += 2
  end
  out
end

def get_combo(registers, operand)
  case operand
  when 0..3
    operand
  when 4
    registers['A']
  when 5
    registers['B']
  when 6
    registers['C']
  else
    raise "Invalid operand #{operand.inspect}"
  end
end

registers, program = parse_input

output = run_program(registers, program)

p1 = output.join(',')

puts "Part1: #{p1}"
p2 = -1

best_record = 0
best_step = 0

# Find pattern in the output, insert most common digits and find a good step
a = 0o53701236017
loop do
  registers = { 'A' => a, 'B' => 0, 'C' => 0 }
  output = run_program(registers, program, true)
  nsimilar = 0
  nsimilar += 1 while nsimilar < program.size && output[nsimilar] == program[nsimilar]
  if output == program
    p output
    p2 = a
    break
  elsif nsimilar > best_record
    p [a.to_s(8), (a - best_step).to_s(8), best_record, nsimilar, program.size]
    best_record = nsimilar
    best_step = a
  end
  a += 0o10_000_000_000
end

puts "Part2: #{p2}"
