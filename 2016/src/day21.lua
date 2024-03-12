local function permute(tbl)
  local function aux(arr, n)
    if n == 0 then
      coroutine.yield(arr)
    else
      for i = 1, n do
        arr[i], arr[n] = arr[n], arr[i]
        aux(arr, n - 1)
        arr[i], arr[n] = arr[n], arr[i]
      end
    end
  end

  return coroutine.wrap(function()
    aux(tbl, #tbl)
  end)
end

local function swap(tbl, x, y)
  tbl[x], tbl[y] = tbl[y], tbl[x]
end

local function swap_letter(tbl, x, y)
  for i, ch in ipairs(tbl) do
    if ch == x then
      tbl[i] = y
    elseif ch == y then
      tbl[i] = x
    end
  end
end

local function mod1(x, m)
  return (x - 1) % m + 1
end

local function rotate(tbl, x)
  local size = #tbl
  x = x % size
  if x == 0 then
    return
  end
  local tmp = {}
  for _, v in ipairs(tbl) do
    table.insert(tmp, v)
  end
  for i, v in ipairs(tmp) do
    tbl[mod1(i + x, size)] = v
  end
end

local function find(tbl, x)
  for i, v in ipairs(tbl) do
    if v == x then
      return i
    end
  end
  return -1
end

local function rotate_bop(tbl, x)
  local index = find(tbl, x) - 1
  local rotations = 1 + index + (index >= 4 and 1 or 0)
  return rotate(tbl, rotations)
end

local function reverse_window(tbl, x, y)
  while x < y do
    swap(tbl, x, y)
    x = x + 1
    y = y - 1
  end
end

local function move_pos(tbl, x, y)
  local value = table.remove(tbl, x)
  table.insert(tbl, y, value)
end

--- Parse the command and return a function that does the operation.
--- The functions take a table as input.
local function parse_command(str)
  local arg1, arg2
  arg1, arg2 = string.match(str, "^swap position (%d) with position (%d)")
  if arg1 then
    arg1 = tonumber(arg1)
    arg2 = tonumber(arg2)
    return function(tbl)
      swap(tbl, arg1 + 1, arg2 + 1)
    end
  end

  arg1, arg2 = string.match(str, "^swap letter (%a) with letter (%a)")
  if arg1 then
    return function(tbl)
      swap_letter(tbl, arg1, arg2)
    end
  end

  arg1, arg2 = string.match(str, "^rotate (%a+) (%d+) steps?")
  if arg1 then
    arg2 = tonumber(arg2)
    if arg1 == "left" then
      return function(tbl)
        rotate(tbl, -arg2)
      end
    else
      return function(tbl)
        rotate(tbl, arg2)
      end
    end
  end

  arg1 = string.match(str, "^rotate based on position of letter (%a)")
  if arg1 then
    return function(tbl)
      rotate_bop(tbl, arg1)
    end
  end

  arg1, arg2 = string.match(str, "^reverse positions (%d) through (%d)")
  if arg1 then
    arg1 = tonumber(arg1)
    arg2 = tonumber(arg2)
    return function(tbl)
      reverse_window(tbl, arg1 + 1, arg2 + 1)
    end
  end

  arg1, arg2 = string.match(str, "^move position (%d) to position (%d)")
  if arg1 then
    arg1 = tonumber(arg1)
    arg2 = tonumber(arg2)
    return function(tbl)
      move_pos(tbl, arg1 + 1, arg2 + 1)
    end
  end

  error("Fail to match " .. str)
end

local function part2(table_char, commands, target)
  for permutation in permute(table_char) do
    local starting_str = table.concat(permutation)

    for _, command in ipairs(commands) do
      command(permutation)
    end
    local scrambled_str = table.concat(permutation)
    if scrambled_str == target then
      return starting_str
    end
  end
  error("Not found")
end

local word = "abcdefgh"
local table_char = {}
for ch in word:gmatch(".") do
  table.insert(table_char, ch)
end

local commands = {}
for line in io.lines() do
  local command = parse_command(line)
  table.insert(commands, command)
  command(table_char)
end

print("Part1: " .. table.concat(table_char))
print("Part2: " .. part2(table_char, commands, "fbgdceah"))
