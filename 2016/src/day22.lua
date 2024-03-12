local function parse_node(str)
  local x, y, size, used, avail, use_per = str:match(
    "^/dev/grid/node%-x(%d+)%-y(%d+)%s+(%d+)T%s+(%d+)T%s+(%d+)T%s+(%d+)%%"
  )
  return tonumber(x),
    tonumber(y),
    tonumber(size),
    tonumber(used),
    tonumber(avail),
    tonumber(use_per)
end

local function get_neighbors(x, y)
  local neighbors = {}
  local directions = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }

  for _, dir in ipairs(directions) do
    local nx, ny = x + dir[1], y + dir[2]
    table.insert(neighbors, nx, ny)
  end

  return neighbors
end

-- Apparently, its only viable if b.used is 0
local function is_viable_pair(a, b)
  return a.used ~= 0 and (a.x ~= b.x or a.y ~= b.y) and a.used <= b.avail
end

local function count_viable_pairs(node_list)
  local result = 0
  for _, node_a in ipairs(node_list) do
    for _, node_b in ipairs(node_list) do
      if is_viable_pair(node_a, node_b) then
        result = result + 1
      end
    end
  end
  return result
end

local max_x = 0
local node_map = {}
local node_list = {}
for line in io.lines() do
  local x, y, size, used, avail, use_per = parse_node(line)
  if x then
    max_x = math.max(max_x, x)
    local node = {
      x = x,
      y = y,
      size = size,
      used = used,
      avail = avail,
      use_per = use_per,
    }
    node_map[x] = node_map[x] or {}
    node_map[x][y] = node
    table.insert(node_list, node)
  end
end

local p1 = count_viable_pairs(node_list)

print("Part1: " .. p1)

-- Part 2

local function move_data(src, dst)
  assert(is_viable_pair(src, dst))
  dst.used = dst.used + src.used
  src.avail = src.avail + src.used
  src.used = 0
end
