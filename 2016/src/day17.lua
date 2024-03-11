local md5 = require("lua.user.md5")

--- Directions are up, down, left, and right
local directions = {
  "U",
  "D",
  "L",
  "R",
  U = { -1, 0 },
  D = { 1, 0 },
  L = { 0, -1 },
  R = { 0, 1 },
}

local function find_open_doors(str)
  local result = {}
  for i = 1, 4 do
    local ch = string.sub(str, i, i)
    if tonumber(ch, 16) > 10 then
      table.insert(result, directions[i])
    end
  end
  return result
end

local function generate_hash(prefix, suffix)
  return md5.sumhexa(prefix .. suffix)
end

local function bfs(start, target, passcode)
  local queue = { { path = "", pos = start } }

  while #queue > 0 do
    local cur_state = table.remove(queue, 1)
    if cur_state.pos[1] == target[1] and cur_state.pos[2] == target[2] then
      return cur_state.path
    end

    local hash = generate_hash(passcode, cur_state.path)
    local open_doors = find_open_doors(hash)

    for _, dirstr in ipairs(open_doors) do
      local dir_arr = directions[dirstr]
      local nx, ny =
        cur_state.pos[1] + dir_arr[1], cur_state.pos[2] + dir_arr[2]

      if nx >= 1 and ny >= 1 and nx <= 4 and ny <= 4 then
        local next_state =
          { path = cur_state.path .. dirstr, pos = { nx, ny } }
        table.insert(queue, next_state)
      end
    end
  end
  error("Not found")
end

local function dfs(start, target, passcode)
  local function aux(pos, path, path_len)
    if pos[1] == target[1] and pos[2] == target[2] then
      return path_len
    end

    local max_len = 0
    local hash = generate_hash(passcode, path)
    local open_doors = find_open_doors(hash)

    for _, dir_string in ipairs(open_doors) do
      local dir_vec = directions[dir_string]
      local nx = pos[1] + dir_vec[1]
      local ny = pos[2] + dir_vec[2]

      if nx >= 1 and ny >= 1 and nx <= 4 and ny <= 4 then
        local subpath_len = aux({ nx, ny }, path .. dir_string, path_len + 1)

        if subpath_len > max_len then
          max_len = subpath_len
        end
      end
    end
    return max_len
  end
  return aux(start, "", 0)
end

local passcode = io.read()

local p1 = bfs({ 1, 1 }, { 4, 4 }, passcode)

print("Part1: " .. p1)

local p2 = dfs({ 1, 1 }, { 4, 4 }, passcode)
print("Part2: " .. p2)
