local function parse_room(str)
  local name, id, checksum = str:match("([%a%-]+)-(%d+)%[(%a+)%]")
  return name, tonumber(id), checksum
end

local function count_characters(str)
  local count = {}
  for ch in str:gmatch(".") do
    if ch ~= "-" then
      count[ch] = (count[ch] or 0) + 1
    end
  end
  return count
end

local function calculate_checksum(name)
  local count = count_characters(name)
  local sorted_chars = {}
  for key in pairs(count) do
    table.insert(sorted_chars, key)
  end
  table.sort(sorted_chars, function(a, b)
    if count[a] == count[b] then
      return a < b
    else
      return count[a] > count[b]
    end
  end)
  return table.concat(sorted_chars, "", 1, 5)
end

local function is_real_room(name, checksum)
  return calculate_checksum(name) == checksum
end

local function decrypt_message(name, id)
  local decrypted = ""
  for ch in name:gmatch(".") do
    if ch == "-" then
      decrypted = decrypted .. " "
    else
      local ch_byte = string.byte(ch) - string.byte("a")
      local decrypted_char_byte = (ch_byte + id) % 26 + string.byte("a")
      decrypted = decrypted .. string.char(decrypted_char_byte)
    end
  end
  return decrypted
end

local p1 = 0
local p2 = -1
for line in io.lines() do
  local name, id, checksum = parse_room(line)
  if is_real_room(name, checksum) then
    p1 = p1 + id
    local decrypted = decrypt_message(name, id)
    if decrypted:find("north") then
      p2 = id
    end
  end
end

print("Part1: " .. p1)
print("Part2: " .. p2)

