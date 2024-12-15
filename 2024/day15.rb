# frozen_string_literal: true

def parse_input
  walls = Set.new
  boxes = Set.new
  cursor = nil

  walls2 = Set.new
  boxes2 = {}
  cursor2 = nil

  movements_queue = []
  get_queue = false
  ARGF.each.with_index do |row, i|
    row.chomp!
    if row.empty?
      get_queue = true
      next
    end

    row.each_char.with_index do |char, j|
      if get_queue
        move_dir = get_move_dir(char)
        movements_queue << move_dir unless move_dir.nil?
      else
        pos = Complex(i, j)
        pos2 = [Complex(i, 2 * j), Complex(i, 2 * j + 1)]
        case char
        when '#'
          walls << pos
          walls2.merge(pos2)
        when 'O'
          boxes << pos
          boxes2[pos2[0]] = :boxL
          boxes2[pos2[1]] = :boxR
        when '@'
          cursor = pos
          cursor2 = pos2[0]
        end
      end
    end
  end
  [walls, boxes, cursor, movements_queue, [walls2, boxes2, cursor2]]
end

def get_move_dir(char)
  case char
  when '^'
    Complex(-1, 0)
  when 'v'
    Complex(1, 0)
  when '<'
    Complex(0, -1)
  when '>'
    Complex(0, 1)
  end
end

def move(cursor, direction, boxes, walls)
  cursor_next_pos = cursor + direction
  final_moved_pos = cursor + direction
  # Get final position of the last box
  final_moved_pos += direction while boxes.include?(final_moved_pos)
  # return the current cursor position if can't move because of wall
  return cursor if walls.include?(final_moved_pos)

  # update boxes positions
  boxes.add(final_moved_pos) if boxes.delete?(cursor_next_pos)
  cursor_next_pos
end

def simulate_movement(cursor, movement_queue, walls, boxes)
  movement_queue.each do |move_dir|
    cursor = move(cursor, move_dir, boxes, walls)
  end
  cursor
end

def gps_coordinate(pos)
  100 * pos.real + pos.imag
end

walls, boxes, cursor, move_dir_q, doubled_grid = parse_input

simulate_movement(cursor, move_dir_q, walls, boxes)

p1 = boxes.sum { |pos| gps_coordinate(pos) }
puts "Part1: #{p1}"

def can_move?(pos, direction, boxes, walls)
  next_pos = pos + direction
  return false if walls.include?(next_pos)

  next_box_type = boxes[next_pos]
  return true if next_box_type.nil?

  adj_box = next_pos + (next_box_type == :boxL ? 1i : -1i)

  horizontal_movement = direction.real.zero?
  if horizontal_movement
    can_move?(adj_box, direction, boxes, walls)
  else
    can_move?(adj_box, direction, boxes, walls) && can_move?(next_pos, direction, boxes, walls)
  end
end

def move_box_side(oldpos, newpos, boxes)
  old_side = boxes.delete(oldpos)
  return if old_side.nil?

  # p ['moving', oldpos, 'to', newpos]
  boxes[newpos] = old_side
end

def move2(pos, direction, boxes, walls)
  next_pos = pos + direction
  raise "You shouldn't find a wall" if walls.include?(next_pos)

  if boxes.key?(next_pos)
    adj_box = next_pos + (boxes[next_pos] == :boxL ? 1i : -1i)
    horizontal_movement = direction.real.zero?
    if horizontal_movement
      move2(adj_box, direction, boxes, walls)
      move_box_side(next_pos, adj_box, boxes)
      move_box_side(pos, next_pos, boxes)
    else
      move2(adj_box, direction, boxes, walls)
      move2(next_pos, direction, boxes, walls)
      move_box_side(pos, next_pos, boxes)
    end
  else
    move_box_side(pos, next_pos, boxes)
  end
  next_pos
end

def simulate_movement_doubled(cursor, movement_queue, walls, boxes)
  movement_queue.each do |move_dir|
    cursor = move2(cursor, move_dir, boxes, walls) if can_move?(cursor, move_dir, boxes, walls)
  end
  cursor
end

walls2, boxes2, cursor2 = doubled_grid

simulate_movement_doubled(cursor2, move_dir_q, walls2, boxes2)
p2 = boxes2.each.sum { |pos, val| val == :boxL ? gps_coordinate(pos) : 0 }

puts "Part2: #{p2}"
