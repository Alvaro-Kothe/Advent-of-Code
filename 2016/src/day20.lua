local function is_disjoint(interval1, interval2)
  local l, u = interval1, interval2
  if not u[1] or (l[1] and u[1] < l[1]) then
    l, u = u, l
  end
  return l[2] and u[1] and l[2] < u[1]
end

local function interval_intersection(interval1, interval2)
  if is_disjoint(interval1, interval2) then
    return
  end
  local lower = (
    interval1[1]
    and interval2[1]
    and math.max(interval1[1], interval2[1])
  )
    or interval1[1]
    or interval2[1]
  local upper = (
    interval1[2]
    and interval2[2]
    and math.min(interval1[2], interval2[2])
  )
    or interval1[2]
    or interval2[2]
  return { lower, upper }
end

local function interval_union(intervals)
  table.sort(intervals, function(a, b)
    return a[1] < b[1]
  end)
  local result = {}

  for _, interval in ipairs(intervals) do
    if #result == 0 or result[#result][2] < interval[1] then
      table.insert(result, interval)
    else
      result[#result] =
        { result[#result][1], math.max(result[#result][2], interval[2]) }
    end
  end

  return result
end

local function interval_difference(interval1, interval2)
  local not_interval2_1 = { nil, interval2[1] - 1 }
  local not_interval2_2 = { interval2[2] + 1, nil }

  local inter1 = interval_intersection(interval1, not_interval2_1)
  local inter2 = interval_intersection(interval1, not_interval2_2)

  if not inter1 then
    return { inter2 }
  elseif not inter2 then
    return { inter1 }
  else
    return interval_union({ inter1, inter2 })
  end
end

local function blacklist(whitelisted, blacklist_range)
  local result = {}
  for _, interval in ipairs(whitelisted) do
    local allowed_ranges = interval_difference(interval, blacklist_range)
    for _, allowed in ipairs(allowed_ranges) do
      table.insert(result, allowed)
    end
  end
  return result
end

local max_ip = 4294967295

local whitelisted = { { 0, max_ip } }

for line in io.lines() do
  local lo, up = string.match(line, "(%d+)-(%d+)")
  lo = tonumber(lo)
  up = tonumber(up)
  whitelisted = blacklist(whitelisted, { lo, up })
end

table.sort(whitelisted, function(a, b)
  return a[1] < b[1]
end)

local allowd_ips = 0
for _, interval in ipairs(whitelisted) do
  allowd_ips = allowd_ips + interval[2] - interval[1] + 1
end

print("Part1: " .. whitelisted[1][1])
print("Part2: " .. allowd_ips)

local function repr_interval(interval)
  return "["
    .. (interval[1] or "-inf")
    .. ", "
    .. (interval[2] or "inf")
    .. "]"
end
