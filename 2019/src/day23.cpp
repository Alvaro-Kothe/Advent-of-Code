#include <array>
#include <cstddef>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <optional>
#include <ostream>
#include <string>

#include "intcode.h"

const size_t ncomputers = 50;
const int default_input = -1;

int part1(memory_t program) {
  std::array<Intcode::IntcodeProgram<int64_t>, ncomputers> computers;
  for (size_t i = 0; i < ncomputers; ++i) {
    computers[i].memory = program;
    computers[i].queue.push(i);
    computers[i].use_default = true;
    computers[i].default_input = default_input;
  }

  for (;;) {
    for (auto &computer : computers) {
      std::optional<size_t> addr = computer.run_program(1);
      if (!addr.has_value()) continue;
      int64_t x = computer.run_program();
      int64_t y = computer.run_program();
      if (addr.value() == 255) return y;
      computers[addr.value()].queue.push(x);
      computers[addr.value()].queue.push(y);
    }
  }
  return -1;
}

int part2(memory_t program) {
  std::array<Intcode::IntcodeProgram<int64_t>, ncomputers> computers;
  for (size_t i = 0; i < ncomputers; ++i) {
    computers[i].memory = program;
    computers[i].queue.push(i);
    computers[i].use_default = true;
    computers[i].default_input = default_input;
  }

  int natx, naty;
  int nat_lasty = -1;
  for (;;) {
    bool idle = true;
    for (auto &computer : computers) {
      if (!computer.queue.empty()) idle = false;
      std::optional<size_t> addr = computer.run_program(2);
      if (!addr.has_value()) continue;
      idle = false;
      int64_t x = computer.run_program();
      int64_t y = computer.run_program();
      if (addr.value() == 255) {
        natx = x;
        naty = y;
      } else {
        computers[addr.value()].queue.push(x);
        computers[addr.value()].queue.push(y);
      }
    }
    if (idle) {
      if (naty == nat_lasty) return nat_lasty;
      nat_lasty = naty;
      computers[0].queue.push(natx);
      computers[0].queue.push(naty);
    }
  }
  return -1;
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day23.txt";
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  const memory_t program = Intcode::parse_data(fh);
  std::cout << "Part1: " << part1(program) << '\n';
  std::cout << "Part2: " << part2(program) << '\n';
  return 0;
}
