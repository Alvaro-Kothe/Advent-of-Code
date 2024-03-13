local pq = require("lua.user.priority_queue")

local function hash_pos(position)
  return table.concat(position, ",")
end

local function hash_state(state)
  local result = hash_pos(state.pos) .. "|"
  table.sort(state.remaining, function(a, b)
    if a[1] == b[1] then
      return a[2] < b[2]
    else
      return a[1] < b[1]
    end
  end)

  for _, rem_pos in ipairs(state.remaining) do
    result = result .. hash_pos(rem_pos) .. "|"
  end

  return result
end

local function get_neighbors(position)
  local directions = { { -1, 0 }, { 1, 0 }, { 0, 1 }, { 0, -1 } }
  return coroutine.wrap(function()
    for _, dir in ipairs(directions) do
      coroutine.yield({ position[1] + dir[1], position[2] + dir[2] })
    end
  end)
end

local function find(tbl, el, cmp)
  cmp = cmp or function(a, b)
    return a == b
  end
  for i, value in ipairs(tbl) do
    if cmp(el, value) then
      return i
    end
  end
  return nil
end

local function list_equal(a, b)
  for i, v in ipairs(a) do
    if v ~= b[i] then
      return false
    end
  end
  return true
end

local function distance_to_targets(position, targets, open_passages)
  local distances = {}
  local remaining_targets = {}
  for _, pos in ipairs(targets) do
    table.insert(remaining_targets, pos)
  end

  local queue = { { pos = position, distance = 0 } }
  local visited = { [position[1]] = { [position[2]] = true } }

  while #queue > 0 do
    local current_state = table.remove(queue, 1)
    local target_idx = find(targets, current_state.pos, list_equal)
    if target_idx then
      table.insert(distances, { current_state.distance, current_state.pos })
      table.remove(remaining_targets, target_idx)
    end
    if #remaining_targets == 0 then
      break
    end

    for neighbor in get_neighbors(current_state.pos) do
      local x, y = neighbor[1], neighbor[2]
      visited[x] = visited[x] or {}

      if not visited[x][y] and open_passages[x] and open_passages[x][y] then
        visited[x][y] = true
        table.insert(
          queue,
          { pos = neighbor, distance = current_state.distance + 1 }
        )
      end
    end
  end

  return distances
end

local function append_target_positions(state, remaining)
  for _, target_pos in ipairs(remaining) do
    if not list_equal(target_pos, state.pos) then
      table.insert(state.remaining, target_pos)
    end
  end
end

local function dijkstra(
  start,
  target_positions,
  open_passages,
  finish_at_start
)
  local initial_state =
    { pos = start, remaining = target_positions, steps = 0 }
  local seen_distances = { [hash_state(initial_state)] = 0 }
  local queue = pq.new()
  pq.push(queue, initial_state, 0)
  while not pq.is_empty(queue) do
    local cur_state = pq.pop(queue)
    assert(cur_state)

    if #cur_state.remaining == 0 then
      if finish_at_start and not list_equal(cur_state.pos, start) then
        table.insert(cur_state.remaining, start)
      else
        return cur_state.steps
      end
    end

    local targets_distances =
      distance_to_targets(cur_state.pos, cur_state.remaining, open_passages)
    for _, target_distance in ipairs(targets_distances) do
      local distance, new_pos = target_distance[1], target_distance[2]
      local nxt_distance = cur_state.steps + distance

      local next_state =
        { pos = new_pos, remaining = {}, steps = nxt_distance }
      append_target_positions(next_state, cur_state.remaining)
      local hash = hash_state(next_state)

      if not seen_distances[hash] or nxt_distance < seen_distances[hash] then
        seen_distances[hash] = nxt_distance
        pq.push(queue, next_state, nxt_distance)
      end
    end
  end
end

local open_passages = {}
local numbers_positions = {}

local row = 0
for line in io.lines() do
  row = row + 1
  local col = 0
  open_passages[row] = open_passages[row] or {}

  for ch in line:gmatch(".") do
    col = col + 1
    local num_char = tonumber(ch)
    if num_char then
      open_passages[row][col] = true
      numbers_positions[num_char] = { row, col }
    elseif ch == "." then
      open_passages[row][col] = true
    end
  end
end

local targets = {}
for key, pos in pairs(numbers_positions) do
  if key ~= 0 then
    table.insert(targets, pos)
  end
end

local p1 = dijkstra(numbers_positions[0], targets, open_passages)

print("Part1: " .. p1)

local p2 = dijkstra(numbers_positions[0], targets, open_passages, true)
print("Part2: " .. p2)
