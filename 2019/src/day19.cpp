#include <cstddef>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <ostream>
#include <string>

#include "intcode.h"

bool check_position(memory_t program, std::size_t x, std::size_t y) {
  std::queue<int64_t> queue;
  queue.push(x);
  queue.push(y);
  return Intcode::IntcodeProgram<int64_t>(program).run_program(queue);
}

using position_t = std::pair<int, int>;
std::vector<position_t> get_affected_points(memory_t program,
                                            std::size_t limit) {
  std::vector<position_t> out;
  for (size_t x = 0; x < limit; ++x) {
    for (size_t y = 0; y < limit; ++y) {
      if (check_position(program, x, y)) out.push_back({x, y});
    }
  }
  return out;
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day19.txt";
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  const memory_t program = Intcode::parse_data(fh);
  const auto affected_points = get_affected_points(program, 50);
  std::cout << "Part1: " << affected_points.size() << '\n';
  uint32_t x = 0, y = 0;
  while (!check_position(program, x + 99, y)) {
    y++;
    while (!check_position(program, x, y + 99)) x++;
  }
  std::cout << "Part2: " << x * 10000 + y << '\n';
  return 0;
}
