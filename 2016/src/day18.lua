local trap_configurations =
  { ["^^."] = true, [".^^"] = true, ["^.."] = true, ["..^"] = true }

local function generate_row(previous_row)
  local result = ""
  local row_size = #previous_row
  for i = 1, row_size do
    local window = ""
    for j = i - 1, i + 1 do
      window = window
        .. ((j < 1 or j > row_size) and "." or string.sub(previous_row, j, j))
    end
    result = result .. (trap_configurations[window] and "^" or ".")
  end
  return result
end

local inp = io.read()

local nsafe = 0
local p1, p2
local row = inp
for i = 1, 400000 do
  local _, safe_in_row = string.gsub(row, "%.", "")
  nsafe = nsafe + safe_in_row
  if i == 40 then
    p1 = nsafe
  end
  row = generate_row(row)
end

p2 = nsafe
print("Part1: " .. p1)
print("Part2: " .. p2)
