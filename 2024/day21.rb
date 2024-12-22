# frozen_string_literal: true

NUMPAD = {
  '7' => 0 + 0i,
  '8' => 0 + 1i,
  '9' => 0 + 2i,
  '4' => 1 + 0i,
  '5' => 1 + 1i,
  '6' => 1 + 2i,
  '1' => 2 + 0i,
  '2' => 2 + 1i,
  '3' => 2 + 2i,
  '0' => 3 + 1i,
  'A' => 3 + 2i
}.freeze

DIRPAD = {
  '^' => 0 + 1i,
  'A' => 0 + 2i,
  '<' => 1 + 0i,
  'v' => 1 + 1i,
  '>' => 1 + 2i
}.freeze

DIR2MOVE = {
  '^' => -1 + 0i,
  '<' => 0 + -1i,
  'v' => 1 + 0i,
  '>' => 0 + 1i
}.freeze

def manhattan_distance(pos1, pos2)
  (pos1.real - pos2.real).abs + (pos1.imag - pos2.imag).abs
end

def commands_to_target(start, target, pad)
  pad_positions = pad.values.to_set
  queue = Queue.new
  queue << [start, []]
  until queue.empty?
    pos, commands = queue.pop
    if pos == target
      yield commands
      next
    end
    cur_dst = manhattan_distance(pos, target)

    DIR2MOVE.each do |command, d|
      nb = pos + d
      if pad_positions.include?(nb) && manhattan_distance(nb, target) < cur_dst
        queue << [nb, commands.dup.push(command)]
      end
    end
  end
end

# Get robot commands to press a single key into the numpad
def numpad_cmd(pos, target, nrobots, cache)
  mincmd_len = nil
  commands_to_target(pos, target, NUMPAD) do |cmd|
    cmd << 'A'
    robot_cmd_len = robot_cmd(cmd, nrobots, cache)
    mincmd_len = mincmd_len.nil? || robot_cmd_len < mincmd_len ? robot_cmd_len : mincmd_len
  end
  mincmd_len
end

def robot_cmd(commands, nrobots, cache)
  return commands.size if nrobots <= 0

  key = [commands, nrobots]
  return cache[key] if cache.key?(key)

  cmd_len = 0
  pos = DIRPAD['A']
  commands.each do |cmd|
    mincmd_len = nil
    next_pos = DIRPAD[cmd]
    commands_to_target(pos, next_pos, DIRPAD) do |cmd_seq|
      cmd_seq << 'A'
      robot_cmd_len = robot_cmd(cmd_seq, nrobots - 1, cache)
      mincmd_len = mincmd_len.nil? || robot_cmd_len < mincmd_len ? robot_cmd_len : mincmd_len
    end
    cmd_len += mincmd_len
    pos = next_pos
  end
  cache[key] = cmd_len
  cmd_len
end

cache = {}
p1 = p2 = 0
ARGF.each do |line|
  line.chomp!
  next if line.empty?

  pos = NUMPAD['A']
  numeric = line.scan(/^\d+/)[0].to_i
  complexity = comp2 = 0
  line.each_char do |numpad_button|
    next_pos = NUMPAD[numpad_button]
    complexity += numpad_cmd(pos, next_pos, 2, cache)
    comp2 += numpad_cmd(pos, next_pos, 25, cache)
    pos = next_pos
  end
  p1 += complexity * numeric
  p2 += comp2 * numeric
end

puts "Part1: #{p1}"
puts "Part2: #{p2}"
