#ifndef INTCODE_H
#define INTCODE_H

#include "utils.h"
#include <cassert>
#include <cstdint>
#include <iostream>
#include <istream>
#include <optional>
#include <queue>
#include <stdexcept>
#include <string>
#include <unordered_map>

using memory_t = std::unordered_map<uint64_t, int64_t>;
namespace Intcode {

memory_t parse_data(std::istream &fh);

template <typename T> class IntcodeProgram {
private:
  int64_t get_pos(int i) {
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

public:
  memory_t memory;
  int64_t inst_ptr = 0;
  int64_t relative_base = 0;
  bool finished = false, use_default = false;
  std::queue<T> queue;
  T default_input;
  int64_t last_output = -1;

  IntcodeProgram() {}
  IntcodeProgram(const memory_t program) : memory(program) {}
  IntcodeProgram(const memory_t program, const std::queue<T> queue)
      : memory(program), queue(queue) {}

  std::optional<int64_t> run_program(int timeout) {
    int op_code, ow;
    if (finished) {
      std::cerr << "Program stopped\n";
      throw 1;
    }
    for (;;) {
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
        if (queue.empty() && !use_default)
          throw std::runtime_error("Queue is empty");
        else if (queue.empty() && timeout > 0) {
          timeout--;
          queue.push(default_input);
        } else if (queue.empty())
          return std::nullopt;
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

  int64_t run_program() { return run_program(-1).value(); }

  int64_t run_program(std::queue<T> new_queue) {
    queue = new_queue;
    return run_program();
  }
  void set_queue(std::string str) {
    for (char ch : str)
      queue.push(ch);
  }
  void clear_queue() {
    std::queue<T> empty;
    queue.swap(empty);
  }
};
} // namespace Intcode

#endif // !INTCODE_H
