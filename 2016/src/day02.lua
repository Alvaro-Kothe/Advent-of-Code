local keypad1 = {
  { 1, 2, 3 },
  { 4, 5, 6 },
  { 7, 8, 9 },
}
local keypad2 = {
  { nil, nil, "1", nil, nil },
  { nil, "2", "3", "4", nil },
  { "5", "6", "7", "8", "9" },
  { nil, "A", "B", "C", nil },
  { nil, nil, "D", nil, nil },
}

local function is_valid(keypad, x, y)
  return keypad[x] ~= nil and keypad[x][y] ~= nil
end

local movements = {
  ["U"] = function(x, y)
    return (x - 1), y
  end,
  ["D"] = function(x, y)
    return (x + 1), y
  end,
  ["R"] = function(x, y)
    return x, (y + 1)
  end,
  ["L"] = function(x, y)
    return x, (y - 1)
  end,
}

local function apply_instruction(instruction, keypad, x, y)
  for ch in instruction:gmatch(".") do
    local nx, ny = movements[ch](x, y)
    if is_valid(keypad, nx, ny) then
      x, y = nx, ny
    end
  end
  return keypad[x][y], x, y
end

local p1 = ""
local x, y = 2, 2

local p2 = ""
local x2, y2 = 3, 1

local instructions = io.read()
repeat
  local code
  code, x, y = apply_instruction(instructions, keypad1, x, y)
  p1 = p1 .. code
  code, x2, y2 = apply_instruction(instructions, keypad2, x2, y2)
  p2 = p2 .. code
  instructions = io.read()
until instructions == nil

print("Part1: " .. p1)
print("Part2: " .. p2)
