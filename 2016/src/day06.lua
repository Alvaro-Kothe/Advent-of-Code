local function count_char_word(str, counter)
  for i = 1, #str do
    if not counter[i] then
      counter[i] = {}
    end
    local ch = str:sub(i, i)
    counter[i][ch] = (counter[i][ch] or 0) + 1
  end
end

local function find_mode(freq_tbl)
  local max_count = 0
  local common_key
  for key, value in pairs(freq_tbl) do
    if value > max_count then
      max_count = value
      common_key = key
    end
  end
  return common_key
end

local function find_least_common(freq_tbl)
  local min_count = math.huge
  local least_common_key
  for key, value in pairs(freq_tbl) do
    if value < min_count then
      min_count = value
      least_common_key = key
    end
  end
  return least_common_key
end

local counter = {}

for word in io.lines() do
  count_char_word(word, counter)
end

local common_chars = {}
local least_common = {}
for i, freq_tbl in ipairs(counter) do
  common_chars[i] = find_mode(freq_tbl)
  least_common[i] = find_least_common(freq_tbl)
end

print("Part1: " .. table.concat(common_chars))
print("Part2: " .. table.concat(least_common))
