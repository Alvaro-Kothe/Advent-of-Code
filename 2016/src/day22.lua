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
    table.insert(neighbors, { nx, ny })
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

local function move_empty(start, node_map, cond)
  assert(start)
  local queue = { start }
  local distances = { [start.x] = { [start.y] = 0 } }

  while #queue > 0 do
    local cur_node = table.remove(queue, 1)
    if cond(cur_node) then
      return cur_node, distances[cur_node.x][cur_node.y]
    end

    local neighbors = get_neighbors(cur_node.x, cur_node.y)
    for _, nei_pos in ipairs(neighbors) do
      local nx, ny = nei_pos[1], nei_pos[2]
      if
        node_map[nx]
        and node_map[nx][ny]
        and not (distances[nx] and distances[nx][ny])
        and node_map[nx][ny].used <= cur_node.size
      then
        distances[nx] = distances[nx] or {}
        distances[nx][ny] = distances[cur_node.x][cur_node.y] + 1
        table.insert(queue, node_map[nx][ny])
      end
    end
  end
end

local function find(node_map, cond)
  for _, row in pairs(node_map) do
    for _, node in pairs(row) do
      if cond(node) then
        return node
      end
    end
  end
end

local function part2(node_map, target_x)
  local empty_node = find(node_map, function(node)
    return node.used == 0
  end)

  local empty_node_top, steps = move_empty(empty_node, node_map, function(node)
    return node.x ~= target_x and node.y == 0
  end)

  -- Each time takes 4 steps to move the empty space to the front of the node
  -- so takes 5 steps to move the target to the left.
  -- The target must go to the left (target_x - 2) times.
  -- The first time it goes to the left is when the empty node is at the top,
  -- which takes target_x - empty_node_x_pos steps
  return steps + (5 * (target_x - 1)) + (target_x - empty_node_top.x)
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

local p2 = part2(node_map, max_x)
print("Part2: " .. p2)
