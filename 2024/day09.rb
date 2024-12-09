# frozen_string_literal: true

def append(arr, what, times)
  times.times { arr << what }
end

def parse_line
  id = 0
  file = true
  result = []
  $stdin.each_char do |char|
    n = char.to_i
    if file
      append(result, id, n)
      id += 1
    else
      append(result, nil, n)
    end
    file = !file
  end
  result
end

def move_and_checksum(arr)
  start = 0
  finish = arr.size - 1
  checksum = 0
  while start < finish
    if arr[start].nil?
      finish -= 1 while arr[finish].nil? && finish > start
      arr[start] = arr[finish]
      arr[finish] = nil
    end
    fileid = arr[start]
    checksum += start * fileid
    start += 1
  end
  checksum
end

# Find start available block
def lookahead_freespace(arr, idx, limit, size)
  starti = nil
  (idx..limit).each do |i|
    starti = i if arr[i].nil? && starti.nil?
    starti = nil unless arr[i].nil?
    next if starti.nil?
    return starti if i - starti >= size
  end
  nil
end

# Look for a file block that fit on the size
# Returns the [start, end] indexes to be moved (inclusive)
# If didn't find any, return nil
def lookbehind_fileblock(arr, idx, finish)
  return if idx.negative?

  nxt_idx = idx - 1
  return lookbehind_fileblock(arr, nxt_idx, nxt_idx) if arr[idx].nil?

  return [idx, finish] if arr[nxt_idx] != arr[finish]

  lookbehind_fileblock(arr, nxt_idx, finish)
end

def find_first_freespace(arr, idx)
  (idx..(arr.size - 1)).each do |i|
    return i if arr[i].nil?
  end
end

def move_blocks(arr)
  finish = arr.size - 1
  can_move_start = 0
  while finish >= 0
    move_start, move_end = lookbehind_fileblock(arr, finish, finish)
    break if move_start.nil?

    move_size = move_end - move_start
    finish = move_start - 1
    free_space_idx = lookahead_freespace(arr, can_move_start, finish, move_size)
    next if free_space_idx.nil?

    (0..move_size).each do |i|
      arr[free_space_idx + i] = arr[move_start + i]
      arr[move_start + i] = nil
    end
    can_move_start = find_first_freespace(arr, can_move_start)
  end
end

def checksum(arr)
  arr.each.with_index.sum do |val, i|
    next 0 if val.nil?

    i * val
  end
end

disk_map = parse_line

p1 = move_and_checksum(disk_map.dup)
move_blocks(disk_map)
p2 = checksum(disk_map)

puts "Part1: #{p1}"
puts "Part2: #{p2}"
