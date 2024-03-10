local function get_position(ch)
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
}

local function run_instructions(instructions, registers)
  local inst_ptr = 1
  repeat
    local instruction = instructions[inst_ptr]
    local op, x, y = instruction[1], instruction[2], instruction[3]
    local offset = operations[op](registers, x, y) or 1
    inst_ptr = inst_ptr + offset
  until inst_ptr < 1 or inst_ptr > #instructions
end

local registers = { 0, 0, 0, 0 }
local registers2 = { 0, 0, 1, 0 }
local instructions = {}

for line in io.lines() do
  local op, x, y = string.match(line, "(%a+) (%S+) ?(%S*)")
  table.insert(instructions, { op, x, y })
end

run_instructions(instructions, registers)

print("Part1: " .. registers[1])

run_instructions(instructions, registers2)
print("Part1: " .. registers2[1])
