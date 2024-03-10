-- Represent generators as uppercase, chips as lowercase
local function get_elements(str)
  local result = {}
  for element, element_type in string.gmatch(str, "a ([%a]+)[%-%a]* (%a+)") do
    if element_type == "generator" then
      table.insert(result, string.upper(element))
    elseif element_type == "microchip" then
      table.insert(result, string.lower(element))
    else
      error("Invalid element type " .. element_type)
    end
  end
  return result
end

local function is_valid(state)
  for _, items in ipairs(state) do
    local generators, chips = {}, {}
    local ngenerators = 0
    for _, el in ipairs(items) do
      if string.find(el, "%u") then -- is uppercase -> its generator
        generators[string.lower(el)] = true
        ngenerators = ngenerators + 1
      else
        chips[el] = true
      end
    end

    if ngenerators > 0 then
      for chip in pairs(chips) do
        if not generators[chip] then
          return false
        end
      end
    end
  end

  return true
end

local function generate_combinations(set, k)
  assert(#set >= k, "Not enoughg elements to combine")
  local function aux(combination, start_index)
    if #combination == k then
      coroutine.yield(combination)
      return
    end

    for i = start_index, #set do
      local new_combination = {}
      for _, value in ipairs(combination) do
        table.insert(new_combination, value)
      end
      table.insert(new_combination, set[i])
      aux(new_combination, i + 1)
    end
  end

  return coroutine.wrap(function()
    aux({}, 1)
  end)
end

local function element_in_table(element, tbl)
  for _, value in ipairs(tbl) do
    if value == element then
      return true
    end
  end
  return false
end

local function gen_state(elevator_floor, items_to_move, base_state)
  local result = { elevator = elevator_floor }

  for floor, items in ipairs(base_state) do
    result[floor] = result[floor] or {}
    if floor == elevator_floor then
      for _, to_move in ipairs(items_to_move) do
        table.insert(result[floor], to_move)
      end
    end

    for _, item in ipairs(items) do
      if not element_in_table(item, items_to_move) then
        table.insert(result[floor], item)
      end
    end
  end
  return result
end

local function gen_next_states(state)
  local next_floors = {}
  for _, i in ipairs({ -1, 1 }) do
    local nxt_floor = state.elevator + i
    if nxt_floor >= 1 and nxt_floor <= 4 then
      table.insert(next_floors, nxt_floor)
    end
  end
  local nitems = #state[state.elevator]

  local move_set = {}
  for k = 1, math.min(nitems, 2) do
    for to_move in generate_combinations(state[state.elevator], k) do
      table.insert(move_set, to_move)
    end
  end

  return coroutine.wrap(function()
    for _, next_floor in ipairs(next_floors) do
      for _, moved_items in ipairs(move_set) do
        local next_state = gen_state(next_floor, moved_items, state)
        if is_valid(next_state) then
          coroutine.yield(next_state)
        end
      end
    end
  end)
end

-- The hash will be number of unpaired chips, unpaired generators and pairs in the floor
local function stringify_state(state)
  local result = ""
  result = result .. state.elevator
  for _, items in ipairs(state) do
    result = result .. ","
    local ngenerators, nchips = 0, 0
    local generators, chips = {}, {}
    for _, item in ipairs(items) do
      if string.find(item, "%u") then
        ngenerators = ngenerators + 1
        generators[string.lower(item)] = true
      else
        nchips = nchips + 1
        chips[item] = true
      end
    end

    local npairs = 0
    for chip in pairs(chips) do
      if generators[chip] then
        nchips = nchips - 1
        ngenerators = ngenerators - 1
        npairs = npairs + 1
      end
    end
    result = result .. ngenerators .. "|" .. nchips .. "|" .. npairs
  end
  return result
end

local function bfs(initial_state)
  local queue = { { state = initial_state, steps = 0 } }
  local visited = {}
  visited[stringify_state(initial_state)] = true
  local total_items = 0
  for _, items in ipairs(initial_state) do
    total_items = total_items + #items
  end

  while #queue > 0 do
    local current = table.remove(queue, 1)
    local current_state = current.state
    if current_state.elevator == 4 and #current_state[4] == total_items then
      return current.steps
    end

    for next_state in gen_next_states(current_state) do
      local key = stringify_state(next_state)
      if not visited[key] then
        visited[key] = true
        table.insert(queue, { state = next_state, steps = current.steps + 1 })
      end
    end
  end
  error("Not found")
end

local initial_state = {}
for line in io.lines() do
  table.insert(initial_state, get_elements(line))
end

initial_state.elevator = 1
print("Part1: " .. bfs(initial_state))
-- Part 2 add new elements to floor 1
for _, element in ipairs({ "elerium", "dilithium" }) do
  table.insert(initial_state[1], element)
  table.insert(initial_state[1], string.upper(element))
end
print("Part2: " .. bfs(initial_state))
