local function bin_to_bitvec(str)
  local result = {}
  for ch in string.gmatch(str, ".") do
    table.insert(result, ch == "1")
  end
  return result
end

local function bitvec_to_bin(tbl)
  local result = ""
  for _, v in ipairs(tbl) do
    local ch = v and "1" or "0"
    result = result .. ch
  end
  return result
end

local function reverse(tbl, flip)
  local result = {}
  local size = #tbl
  for i, v in ipairs(tbl) do
    if flip then
      v = not v
    end
    result[size - i + 1] = v
  end
  return result
end

local function fill_disk(data, size)
  if #data >= size then
    return data
  end
  local b = reverse(data, true)
  table.insert(data, false)
  for _, v in ipairs(b) do
    table.insert(data, v)
  end

  return fill_disk(data, size)
end

local function checksum(data)
  local result = {}
  for i = 1, #data, 2 do
    local a, b = data[i], data[i + 1]
    table.insert(result, a == b)
  end

  return (#result % 2 == 0) and checksum(result) or result
end

local function fill_and_checksum(data, size)
  local filled = fill_disk(data, size)
  for i = size + 1, #filled do
    filled[i] = nil
  end
  return checksum(filled)
end

local function fill_checksum_bin(s, size)
  size = size or 272
  local data = bin_to_bitvec(s)
  local chksum = fill_and_checksum(data, size)
  return bitvec_to_bin(chksum)
end

local initial_state = io.read()

print("Part1: " .. fill_checksum_bin(initial_state, 272))
print("Part2: " .. fill_checksum_bin(initial_state, 35651584))
