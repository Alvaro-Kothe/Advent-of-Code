local results = { Infinite = "INFINITE", Out = "OUT", Exit = "EXIT" }
local NREPEATS = 0xf

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
  ["out"] = function(registers, x)
    return get_value(registers, x), true
  end,
}

--- cap2 -> value or register, rest -> register
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
        if captures[capture_idx] ~= instruction[j] then
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
  for i, str in ipairs(captures) do
    local v = i ~= 2 and get_position(str) or get_value(registers, str)
    table.insert(positions, v)
  end

  registers[positions[1]] = registers[positions[1]]
    + (positions[2] * registers[positions[4]]) -- a += b * d
  registers[positions[3]] = 0
  registers[positions[4]] = 0
end

local function apply_instruction(instructions, inst_ptr, registers)
  local instruction = instructions[inst_ptr]
  local op, x, y = instruction[1], instruction[2], instruction[3]

  local value, is_out = operations[op](registers, x, y)
  if is_out then
    return inst_ptr + 1, value
  end

  value = value or 1

  return inst_ptr + value, nil
end

local function hash_state(registers, inst_ptr)
  return tostring(inst_ptr) .. "|" .. table.concat(registers, ",")
end

local function run_instructions(instructions, registers, inst_ptr)
  local seen = {}

  inst_ptr = inst_ptr or 1

  repeat
    local hash = hash_state(registers, inst_ptr)
    if seen[hash] then
      return results.Infinite, inst_ptr
    end
    seen[hash] = true

    local can_skip, captures = can_multiply(instructions, inst_ptr)
    if can_skip then
      multiply(registers, captures)
      inst_ptr = inst_ptr + 5
    else
      local out_value
      inst_ptr, out_value =
        apply_instruction(instructions, inst_ptr, registers)
      if out_value then
        return results.Out, inst_ptr, out_value
      end
    end
  until inst_ptr < 1 or inst_ptr > #instructions
  return results.Exit, inst_ptr
end

local function find_min_init_a(instructions)
  local a = 0
  local nxt_out = { [0] = 1, [1] = 0 }
  while true do
    local correct_out_count = 0
    local expected_out = 0
    local registers = { a, 0, 0, 0 }
    local inst_ptr = 1

    for _ = 1, NREPEATS do
      local exit_status, nxt_ptr, out_value =
        run_instructions(instructions, registers, inst_ptr)
      if exit_status == results.Infinite or exit_status == results.Exit then
        break
      elseif exit_status == results.Out then
        assert(nxt_ptr)
        if out_value == expected_out then
          correct_out_count = correct_out_count + 1
          expected_out = nxt_out[out_value]
        else
          break
        end
        inst_ptr = nxt_ptr
      end
    end

    if correct_out_count >= NREPEATS then
      return a
    else
      a = a + 1
    end
  end
end

local instructions = {}

for line in io.lines() do
  local result = {}
  for m in string.gmatch(line, "%S+") do
    table.insert(result, m)
  end
  table.insert(instructions, result)
end

print("Part1: " .. find_min_init_a(instructions))
