-- Should use luajit to compile this code, regular lua is too slow
local md5 = require("lua.user.md5")

local function all_defined(tbl)
  for i = 1, 8 do
    if not tbl[i] then
      return false
    end
  end
  return true
end

local function fill_with_garbage(tbl)
  local out = {}
  for i = 1, 8 do
    if tbl[i] then
      out[i] = tbl[i]
    else
      out[i] = math.random(0, 9)
    end
  end
  return out
end

local function clear_line()
  io.write("\r")
  io.write(string.rep(" ", 80))
  io.write("\r")
  io.flush()
end

local function generate_password(door_id)
  local index = 0
  local password = ""
  local password2 = {}
  repeat
    if index % 30000 == 0 then
      io.write(table.concat(fill_with_garbage(password2)) .. "\t" .. password .. "\r")
      io.flush()
    end
    local hash_input = door_id .. tostring(index)
    local hash = md5.sumhexa(hash_input)
    local ch, ch2 = hash:match("^00000(.)(.)")
    if ch then
      if password:len() < 8 then
        password = password .. ch
      end
      local pos = tonumber(ch, 16)
      if 0 <= pos and pos <= 7 and not password2[pos + 1] then
        password2[pos + 1] = ch2
      end
    end
    index = index + 1
  until password:len() >= 8 and all_defined(password2)
  clear_line()
  return password, table.concat(password2)
end

local door_id = io.read()

local password, password2 = generate_password(door_id)

print("Part1: " .. password)
print("Part2: " .. password2)
