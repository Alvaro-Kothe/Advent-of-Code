local function coordinate_value(x, y)
  return x * x + 3 * x + 2 * x * y + y + y * y
end

local function count_bit_ones(n)
  local result = 0
  while n > 0 do
    if n % 2 == 1 then
      result = result + 1
    end
    n = math.floor(n / 2)
  end
  return result
end

local function is_open_space(x, y, fav_number)
  local value = coordinate_value(x, y) + fav_number
  return count_bit_ones(value) % 2 == 0
end

local function get_neighbors(x, y)
  return coroutine.wrap(function()
    for dx = -1, 1 do
      for dy = -1, 1 do
        if math.abs(dx) + math.abs(dy) == 1 then
          local nx, ny = x + dx, y + dy
          if nx >= 0 and ny >= 0 then
            coroutine.yield(nx, ny)
          end
        end
      end
    end
  end)
end

local function bfs(start, target, fav_number, max_steps)
  local queue = { { x = start[1], y = start[2], step = 0 } }
  local visited = {}
  local reachable_positions = 1
  local steps_to_target = nil

  while #queue > 0 do
    local cur_state = table.remove(queue, 1)
    if cur_state.x == target[1] and cur_state.y == target[2] then
      steps_to_target = cur_state.step
    end
    visited[cur_state.x] = visited[cur_state.x] or {}
    visited[cur_state.x][cur_state.y] = true

    for nx, ny in get_neighbors(cur_state.x, cur_state.y) do
      visited[nx] = visited[nx] or {}
      if not visited[nx][ny] then
        visited[nx][ny] = true
        if is_open_space(nx, ny, fav_number) then
          if max_steps and cur_state.step + 1 <= max_steps then
            reachable_positions = reachable_positions + 1
          end

          if
            not steps_to_target or (max_steps and cur_state.step < max_steps)
          then
            table.insert(queue, { x = nx, y = ny, step = cur_state.step + 1 })
          end
        end
      end
    end
  end

  if steps_to_target then
    return reachable_positions, steps_to_target
  end
  error("Not found")
end

local fav_number = tonumber(io.read())
assert(fav_number)

local reachable_in_50, steps_to_target = bfs(
  { 1, 1 },
  { 31, 39 },
  fav_number,
  50
)
print("Part1: " .. steps_to_target)
print("Part2: " .. reachable_in_50)
