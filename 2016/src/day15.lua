local function prodf(a, ...)
  return a and a * prodf(...) or 1
end
local function prodt(t)
  return prodf(unpack(t))
end

local function mulInv(a, b)
  local b0 = b
  local x0 = 0
  local x1 = 1

  if b == 1 then
    return 1
  end

  while a > 1 do
    local q = math.floor(a / b)
    local amb = math.fmod(a, b)
    a = b
    b = amb
    local xqx = x1 - q * x0
    x1 = x0
    x0 = xqx
  end

  if x1 < 0 then
    x1 = x1 + b0
  end

  return x1
end

-- https://rosettacode.org/wiki/Chinese_remainder_theorem#Lua
local function chinese_remainder(n, a)
  local prod = prodt(n)

  local p
  local sm = 0
  for i = 1, #n do
    p = prod / n[i]
    sm = sm + a[i] * mulInv(p, n[i]) * p
  end

  return math.fmod(sm, prod)
end

local discs = {}
local last_disc = -1
for line in io.lines() do
  local disc_number, positions, start_pos = string.match(
    line,
    "Disc #(%d+) has (%d+) positions; at time=0, it is at position (%d+)."
  )
  disc_number = tonumber(disc_number)
  assert(disc_number)
  if disc_number > last_disc then
    last_disc = disc_number
  end
  discs[disc_number] =
    { positions = tonumber(positions), start = tonumber(start_pos) }
end

local num = {}
local rem = {}
for disc_number, disc in pairs(discs) do
  table.insert(num, disc.positions)
  table.insert(
    rem,
    disc.positions - (disc.start + disc_number) % disc.positions
  )
end

local p1 = chinese_remainder(num, rem)
print("Part1: " .. p1)

-- Part2
table.insert(num, 11)
table.insert(rem, 11 - (0 + last_disc + 1) % 11)

local p2 = chinese_remainder(num, rem)
print("Part2: " .. p2)
