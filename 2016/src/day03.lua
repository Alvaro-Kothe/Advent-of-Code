local function parse_data(str)
  local out = {}
  for num in string.gmatch(str, "%S+") do
    table.insert(out, tonumber(num))
  end
  return out
end

local function valid_triangle(a, b, c)
  return (a + b) > c and (a + c) > b and (b + c) > a
end

local p1, p2 = 0, 0
local acc = { {}, {}, {} }

local line = io.read()
repeat
  local triangle = parse_data(line)
  if valid_triangle(table.unpack(triangle)) then
    p1 = p1 + 1
  end
  for i, v in ipairs(triangle) do
    table.insert(acc[i], v)
  end
  if #acc[1] == 3 then
    for _, triang in ipairs(acc) do
      if valid_triangle(table.unpack(triang)) then
        p2 = p2 + 1
      end
    end
    acc = { {}, {}, {} }
  end
  line = io.read()
until line == nil

print("Part1: " .. p1)
print("Part2: " .. p2)
