local function get_position(ch)
  assert(type(ch) == "string")
  return string.byte(ch) - string.byte("a") + 1
end

local function get_value(registers, value)
  local numvalue = tonumber(value)
  if numvalue ~= nil then
    return numvalue
  else
    return registers[get_position(value)]
  end
end

local operations = {
  ["tgl"] = function(registers, x)
    return get_value(registers, x), true
  end,
  ["cpy"] = function(registers, x, y)
    registers[get_position(y)] = get_value(registers, x)
  end,
  ["inc"] = function(registers, x)
    local pos = get_position(x)
    registers[pos] = registers[pos] + 1
  end,
  ["dec"] = function(registers, x)
    local pos = get_position(x)
    registers[pos] = registers[pos] - 1
  end,
  ["jnz"] = function(registers, x, y)
    if get_value(registers, x) ~= 0 then
      return get_value(registers, y)
    end
  end,
}

--- Found a loop between inst_ptr 5 and 10.
--- 5       cpy     b       c       [150822 6 0 640143]
--- 6       inc     a       nil     [150822 6 6 640143]
--- 7       dec     c       nil     [150823 6 6 640143]
--- 8       jnz     c       -2      [150823 6 5 640143]
--- 6       inc     a       nil     [150823 6 5 640143]
--- 7       dec     c       nil     [150824 6 5 640143]
--- 8       jnz     c       -2      [150824 6 4 640143]
--- 6       inc     a       nil     [150824 6 4 640143]
--- 7       dec     c       nil     [150825 6 4 640143]
--- 8       jnz     c       -2      [150825 6 3 640143]
--- 6       inc     a       nil     [150825 6 3 640143]
--- 7       dec     c       nil     [150826 6 3 640143]
--- 8       jnz     c       -2      [150826 6 2 640143]
--- 6       inc     a       nil     [150826 6 2 640143]
--- 7       dec     c       nil     [150827 6 2 640143]
--- 8       jnz     c       -2      [150827 6 1 640143]
--- 6       inc     a       nil     [150827 6 1 640143]
--- 7       dec     c       nil     [150828 6 1 640143]
--- 8       jnz     c       -2      [150828 6 0 640143]
--- 9       dec     d       nil     [150828 6 0 640143]
--- 10      jnz     d       -5      [150828 6 0 640142]
---
--- 6 -- 8 can be simplified -> a += b; b = 0
--- 5 -- 9 -> a += c; d--
--- 5 -- 10 -> a += b * d; d = 0; c = 0
local function can_multiply(instructions, inst_ptr)
  local expected_sequence = {
    { "cpy", "cap2", "cap3" },
    { "inc", "cap1" },
    { "dec", "cap3" },
    { "jnz", "cap3", "-2" },
    { "dec", "cap4" },
    { "jnz", "cap4" },
  }
  local captures = {}
  for i, expected in ipairs(expected_sequence) do
    local instruction = instructions[inst_ptr + i - 1]
    for j, el in ipairs(expected) do
      local is_capture, _, capture_idx = string.find(el, "cap(%d)")

      if is_capture then
        capture_idx = tonumber(capture_idx)
        assert(capture_idx)
        captures[capture_idx] = captures[capture_idx] or instruction[j]
        if
          captures[capture_idx] ~= instruction[j]
          or not string.find(captures[capture_idx], "[a-d]")
        then
          return false
        end
      else
        if el ~= instruction[j] then
          return false
        end
      end
    end
  end

  return true, captures
end

local function multiply(registers, captures)
  local positions = {}
  for _, ch in ipairs(captures) do
    table.insert(positions, get_position(ch))
  end

  registers[positions[1]] = registers[positions[1]]
    + (registers[positions[2]] * registers[positions[4]]) -- a += b * d
  registers[positions[3]] = 0
  registers[positions[4]] = 0
end

local function toggle_instruction(instruction)
  local toggled = {}
  for _, v in ipairs(instruction) do
    table.insert(toggled, v)
  end
  if #toggled == 2 then
    toggled[1] = toggled[1] == "inc" and "dec" or "inc"
  else
    toggled[1] = toggled[1] == "jnz" and "cpy" or "jnz"
  end
  return toggled
end

local function apply_instruction(instructions, inst_ptr, registers)
  local instruction = instructions[inst_ptr]
  local op, x, y = instruction[1], instruction[2], instruction[3]

  local ok, offset, is_toggle = pcall(operations[op], registers, x, y)

  if not ok then
    offset = 1
    is_toggle = false
  end
  offset = offset or 1

  if is_toggle then
    local change_index = inst_ptr + offset
    if change_index > 0 and change_index <= #instructions then
      instructions[inst_ptr + offset] =
        toggle_instruction(instructions[inst_ptr + offset])
    end
    offset = 1
  end

  return inst_ptr + offset
end

local function run_instructions(instructions, registers)
  local inst_ptr = 1
  repeat
    local can_skip, captures = can_multiply(instructions, inst_ptr)
    if can_skip then
      multiply(registers, captures)
      inst_ptr = inst_ptr + 5
    else
      inst_ptr = apply_instruction(instructions, inst_ptr, registers)
    end
  until inst_ptr < 1 or inst_ptr > #instructions
end

local registers = { 7, 0, 0, 0 }
local instructions = {}
local instructions2 = {}

for line in io.lines() do
  local result = {}
  for m in string.gmatch(line, "%S+") do
    table.insert(result, m)
  end
  table.insert(instructions, result)
  table.insert(instructions2, result)
end

run_instructions(instructions, registers)

print("Part1: " .. registers[1])

local registers2 = { 12, 0, 0, 0 }
run_instructions(instructions2, registers2)
print("Part2: " .. registers2[1])
