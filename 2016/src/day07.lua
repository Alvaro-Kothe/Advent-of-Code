local function is_abba(str, start)
  local a, b, c, d = string.byte(str, start, start + 3)
  return a ~= b and a == d and b == c
end

local function get_abba(str)
  return coroutine.wrap(function()
    for i = 1, #str - 3 do
      if is_abba(str, i) then
        coroutine.yield(str:sub(i, i + 3))
      end
    end
  end)
end

local function is_aba(str, start)
  local a, b, c = string.byte(str, start, start + 2)
  return a ~= b and a == c
end

local function get_aba(str)
  return coroutine.wrap(function()
    for i = 1, #str - 2 do
      if is_aba(str, i) then
        coroutine.yield(str:sub(i, i + 2))
      end
    end
  end)
end

local function support_TLS(str)
  local abba_inside = false
  for inside, outside in string.gmatch(str, "(%a+)%[?(%a*)%]?") do
    if not abba_inside and get_abba(inside)() then
      abba_inside = true
    end
    if get_abba(outside)() then
      return false
    end
  end
  return abba_inside
end

local function support_SSL(str)
  local inside_set, outside_set = {}, {}
  for inside, outside in string.gmatch(str, "(%a+)%[?(%a*)%]?") do
    for aba_inside in get_aba(inside) do
      inside_set[aba_inside] = true
    end
    for aba_outside in get_aba(outside) do
      outside_set[aba_outside] = true
    end
  end
  for aba_in in pairs(inside_set) do
    local a, b = string.byte(aba_in, 1, 2)
    local bab = string.char(b, a, b)
    if outside_set[bab] then
      return true
    end
  end
  return false
end

local p1 = 0
local p2 = 0
for line in io.lines() do
  if support_TLS(line) then
    p1 = p1 + 1
  end
  if support_SSL(line) then
    p2 = p2 + 1
  end
end

print("Part1: " .. p1)
print("Part2: " .. p2)
