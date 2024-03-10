local md5 = require("lua.user.md5")

local function find_chs_with_seqsize(s, size)
  local char_in_sequence = {}
  local result = {}
  for i = 1, #s - size + 1 do
    local ch = string.sub(s, i, i)
    if not char_in_sequence[ch] then
      local found = true
      for j = i + 1, i + size - 1 do
        if string.sub(s, j, j) ~= ch then
          found = false
          break
        end
      end
      if found then
        char_in_sequence[ch] = true
        table.insert(result, ch)
      end
    end
  end
  return result
end

local function generate_hash(salt, index, extra_calls)
  extra_calls = extra_calls or 0
  local hash = md5.sumhexa(salt .. tostring(index))
  for _ = 1, extra_calls do
    hash = md5.sumhexa(hash)
  end
  return hash
end

local function is_char_in_5seq(
  ch,
  salt,
  extra_calls,
  index,
  visited,
  sequences
)
  for i = index + 1, index + 1000 do
    if not visited[i] then
      visited[i] = true
      local hash = generate_hash(salt, i, extra_calls)
      sequences[3][i] = find_chs_with_seqsize(hash, 3)
      sequences[5][i] = find_chs_with_seqsize(hash, 5)
    end

    for _, ch_in_5seq in ipairs(sequences[5][i]) do
      if ch == ch_in_5seq then
        return true
      end
    end
  end
  return false
end

local function find_index(salt, extra_calls)
  local index = 0
  local keys_found = 0
  local visited = {}
  local sequences = { [3] = {}, [5] = {} }

  while keys_found < 64 do
    if not visited[index] then
      visited[index] = true
      local hash = generate_hash(salt, index, extra_calls)
      sequences[3][index] = find_chs_with_seqsize(hash, 3)
    end

    for _, ch_in_3seq in ipairs(sequences[3][index]) do
      if
        is_char_in_5seq(
          ch_in_3seq,
          salt,
          extra_calls,
          index,
          visited,
          sequences
        )
      then
        keys_found = keys_found + 1
        break
      end
      break -- ignore subsequent triplets
    end
    index = index + 1
  end

  return index - 1
end

local salt = io.read()

local p1 = find_index(salt)

print("Part1: " .. p1)

local p2 = find_index(salt, 2016)
print("Part2: " .. p2)
