local function highest_power(n, base)
  local i = 1
  while i * base <= n do
    i = i * base
  end
  return i
end

--- https://en.wikipedia.org/wiki/Josephus_problem
local function safe_position(n)
  local l = n - highest_power(n, 2)
  return 2 * l + 1
end

local function safe_position_across(n)
  local highest_power_of_3 = highest_power(n, 3)
  if highest_power_of_3 == n then
    return n
  elseif n <= 2 * highest_power_of_3 then
    return n - highest_power_of_3
  else
    return 2 * n - 3 * highest_power_of_3
  end
end

local nelves = tonumber(io.read())
print("Part1: " .. safe_position(nelves))
print("Part2: " .. safe_position_across(nelves))

--[[ 
n       f(n)
1       1     =n
2       1     =n - 1
3       3     = n
4       1     = n - 3
5       2     = n - 3
6       3     = n - 3
7       5     = n - 2
8       7     = n - 1
9       9     = n
10      1     = n - 9
11      2     ''
12      3     ''
13      4     ''
14      5     ''
15      6     ''
16      7     ''
17      8     ''
18      9     ''
19      11     = n - 8 = n - 9 + 1
20      13     = n - 7 = n - 9 + 2
21      15     = n - 6
22      17     = n - 5
23      19     = n - 4
24      21     = n - 3
25      23     = n - 2
26      25     = n - 1 = n - 9 + 8
27      27 ]]
