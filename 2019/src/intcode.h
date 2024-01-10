#ifndef INTCODE_H
#define INTCODE_H

#include <cstdint>
#include <istream>
#include <queue>
#include <unordered_map>

using memory_t = std::unordered_map<uint64_t, int64_t>;
namespace Intcode {
memory_t parse_data(std::istream &fh);
class IntcodeProgram {
private:
  int64_t get_pos(int64_t i);

public:
  memory_t memory;
  int inst_ptr = 0;
  int64_t relative_base = 0;
  bool finished = false;
  std::queue<int64_t> queue;
  int64_t last_output = -1;

  IntcodeProgram(const memory_t program) : memory(program) {}

  int64_t run_program();
  int64_t run_program(int input);
  int64_t run_program(std::queue<int64_t> new_queue);
  void reset() {
    inst_ptr = 0;
    // relative_base = 0;
    finished = false;
  }
};
} // namespace Intcode

#endif // !INTCODE_H
