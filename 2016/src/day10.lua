local function distribute_bot_chip(bot, bots, output)
  local compared_17_61 = false
  local low = table.remove(bot)
  local high = table.remove(bot)
  if low > high then
    low, high = high, low
  end

  compared_17_61 = low == 17 and high == 61

  if bot.is_low_to_bot then
    table.insert(bots[bot.low_target], low)
  else
    output[bot.low_target] = output[bot.low_target] or {}
    table.insert(output[bot.low_target], low)
  end

  if bot.is_high_to_bot then
    table.insert(bots[bot.high_target], high)
  else
    output[bot.high_target] = output[bot.high_target] or {}
    table.insert(output[bot.high_target], high)
  end
  return compared_17_61
end

local function distribute_chips(bots)
  local bot_17_61
  local output = {}
  local changed = true
  while changed do
    changed = false
    for bot_number, bot in pairs(bots) do
      if #bot >= 2 then
        changed = true
        local compared_17_61 = distribute_bot_chip(bot, bots, output)
        if compared_17_61 then
          bot_17_61 = bot_number
        end
      end
    end
  end
  return bot_17_61, output
end

local bots = {}

for line in io.lines() do
  if string.find(line, "value", 1, true) == 1 then
    local value, bot = string.match(line, "value (%d+) goes to bot (%d+)")
    bot = tonumber(bot)
    assert(bot)
    bots[bot] = bots[bot] or {}
    table.insert(bots[bot], tonumber(value))
  elseif string.find(line, "bot", 1, true) == 1 then
    local bot, bo1, target1, bo2, target2 = string.match(
      line,
      "bot (%d+) gives low to (%a+) (%d+) and high to (%a+) (%d+)"
    )
    bot = tonumber(bot)
    assert(bot)
    bots[bot] = bots[bot] or {}
    bots[bot].is_low_to_bot = bo1 == "bot"
    bots[bot].is_high_to_bot = bo2 == "bot"
    bots[bot].low_target = tonumber(target1)
    bots[bot].high_target = tonumber(target2)
  end
end

local p1, outputs = distribute_chips(bots)
local p2 = 1
for i = 0, 2 do
  p2 = p2 * outputs[i][1]
end

print("Part1: " .. p1)
print("Part2: " .. p2)
