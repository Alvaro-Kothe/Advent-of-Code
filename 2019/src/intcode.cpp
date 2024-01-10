#include "intcode.h"
#include <cassert>
#include <cstdint>
#include <iostream>
#include <queue>

memory_t Intcode::parse_data(std::istream &fh) {
  memory_t out;
  std::string str;
  int i = 0;
  while (getline(fh, str, ',')) {
    out[i] = std::stoll(str);
    i++;
  }
  return out;
}
uint64_t power(uint64_t a, uint64_t b) {
  if (b == 0)
    return 1;
  return a * power(a, b - 1);
}

int64_t Intcode::IntcodeProgram::get_pos(int64_t i) {
  int64_t out;
  switch ((memory[inst_ptr] / (power(10, i + 1)) % 10)) {
  case 0:
    out = memory[inst_ptr + i];
    break;
  case 1:
    out = inst_ptr + i;
    break;
  case 2:
    out = relative_base + memory[inst_ptr + i];
    break;
  default:
    throw std::runtime_error("Unexpected mode");
  }
  return out;
}

int64_t Intcode::IntcodeProgram::run_program(const int input) {
  queue = std::queue<int64_t>();
  queue.push(input);
  return run_program();
}

int64_t Intcode::IntcodeProgram::run_program(std::queue<int64_t> queue) {
  this->queue = queue;
  return run_program();
}

int64_t Intcode::IntcodeProgram::run_program() {
  int op_code, ow;
  if (this->finished) {
    std::cerr << "Program stopped\n";
    throw 1;
  }
  while (true) {
    op_code = memory[inst_ptr] % 100;
    switch (op_code) {
    case 1:
      ow = get_pos(3);
      memory[ow] = memory[get_pos(1)] + memory[get_pos(2)];
      inst_ptr += 4;
      break;
    case 2:
      ow = get_pos(3);
      memory[ow] = memory[get_pos(1)] * memory[get_pos(2)];
      inst_ptr += 4;
      break;
    case 3:
      assert(!queue.empty());
      ow = get_pos(1);
      memory[ow] = queue.front();
      queue.pop();
      inst_ptr += 2;
      break;
    case 4:
      last_output = memory[get_pos(1)];
      inst_ptr += 2;
      return last_output;
    case 5:
      inst_ptr = memory[get_pos(1)] != 0 ? memory[get_pos(2)] : inst_ptr + 3;
      break;
    case 6:
      inst_ptr = memory[get_pos(1)] == 0 ? memory[get_pos(2)] : inst_ptr + 3;
      break;
    case 7:
      ow = get_pos(3);
      memory[ow] = memory[get_pos(1)] < memory[get_pos(2)] ? 1 : 0;
      inst_ptr += 4;
      break;
    case 8:
      ow = get_pos(3);
      memory[ow] = memory[get_pos(1)] == memory[get_pos(2)] ? 1 : 0;
      inst_ptr += 4;
      break;
    case 9:
      relative_base += memory[get_pos(1)];
      inst_ptr += 2;
      break;
    case 99:
      finished = true;
      return last_output;
      break;
    default:
      std::cerr << "Unexpected code " << op_code << '\n';
      throw 1;
    }
  }
}
