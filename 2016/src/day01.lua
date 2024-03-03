local function manhattan_distance(x, y)
  return math.abs(x) + math.abs(y)
end

local turn = {
  ["R"] = function(dx, dy)
    return dy, -dx
  end,
  ["L"] = function(dx, dy)
    return -dy, dx
  end,
}

local instructions = io.read()

local x = 0
local y = 0
local dx = -1
local dy = 0

local p2 = -1
local visited = {}

for word in string.gmatch(instructions, "[^, ]+") do
  local turn_dir, moves = word:match("([LR])(%d+)")
  moves = tonumber(moves)
  dx, dy = turn[turn_dir](dx, dy)
  for _ = 1, moves do
    x = x + dx
    y = y + dy
    if p2 < 0 then
      local key = x .. "," .. y
      if visited[key] then
        p2 = manhattan_distance(x, y)
      else
        visited[key] = true
      end
    end
  end
end

print("Part1: " .. manhattan_distance(x, y))
print("Part2: " .. p2)
