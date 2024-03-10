local function decompress(str, version2)
  local result = 0
  local idx = 1
  while idx <= string.len(str) do
    local ch = str:sub(idx, idx)
    if ch == "(" then
      local _, close_pos, capture_size, repeat_amount =
        string.find(str, "%((%d+)x(%d+)%)", idx)
      close_pos = tonumber(close_pos)
      capture_size = tonumber(capture_size)
      repeat_amount = tonumber(repeat_amount)
      assert(close_pos and capture_size and repeat_amount)
      idx = close_pos + 1
      local captured_group = ""
      for _ = 1, capture_size do
        captured_group = captured_group .. str:sub(idx, idx)
        idx = idx + 1
      end
      result = result
        + (
            version2 and decompress(captured_group, version2)
            or string.len(captured_group)
          )
          * repeat_amount
    else
      result = result + 1
      idx = idx + 1
    end
  end
  return result
end

local inp = io.read()
print("Part1: " .. decompress(inp))
print("Part2: " .. decompress(inp, true))
