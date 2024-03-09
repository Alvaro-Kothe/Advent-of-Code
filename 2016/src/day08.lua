local WIDTH = 50
local HEIGHT = 6

local function mod1(x, m)
  return (x - 1) % m + 1
end

local function rect(matrix, cols, rows)
  for i = 1, rows do
    for j = 1, cols do
      matrix[i][j] = true
    end
  end
end

local function rotate_col(matrix, col, amount)
  local original = {}
  local height = #matrix
  for i = 1, height do
    original[i] = matrix[i][col]
  end
  for i, value in ipairs(original) do
    matrix[mod1(i + amount, height)][col] = value
  end
end

local function rotate_row(matrix, row, amount)
  local original = {}
  for i, v in ipairs(matrix[row]) do
    original[i] = v
  end
  local width = #original
  for i, value in ipairs(original) do
    matrix[row][mod1(i + amount, width)] = value
  end
end

local function print_screen(screen)
  for _, row in ipairs(screen) do
    for _, value in ipairs(row) do
      if value then
        io.write("#")
      else
        io.write(" ")
      end
    end
    io.write("\n")
  end
end

local screen = {}
for i = 1, HEIGHT do
  screen[i] = {}
  for j = 1, WIDTH do
    screen[i][j] = false
  end
end
print_screen(screen)

for line in io.lines() do
  local action, what, arg1, arg2 =
    string.match(line, "(%a+)%s*(%a*)%D+(%d+)%D+(%d+)")
  arg1 = tonumber(arg1)
  arg2 = tonumber(arg2)
  if action == "rect" then
    rect(screen, arg1, arg2)
  elseif action == "rotate" then
    if what == "row" then
      rotate_row(screen, arg1 + 1, arg2)
    elseif what == "column" then
      rotate_col(screen, arg1 + 1, arg2)
    else
      error("Invalid rotation " .. what)
    end
  else
    error("Invalid action " .. action)
  end
end

local p1 = 0
for _, row in ipairs(screen) do
  for _, value in ipairs(row) do
    if value then
      p1 = p1 + 1
    end
  end
end

print("Part1: " .. p1)
print("Part2:")
print_screen(screen)
