#include "intcode.h"
#include <cstdint>
#include <fstream>
#include <iostream>
#include <ostream>
#include <string>

using position_t = std::pair<int, int>;
int64_t part1(memory_t program) {
  Intcode::IntcodeProgram<int64_t> intcode(program);
  // ABC(D)
  // (!A || !B || !C) && D -> J
  // !(A && B && C) && D
  std::string instructions = //
      "OR A J\n"             // AND needs J as true
      "AND B J\n"
      "AND C J\n"
      "NOT J J\n"
      "AND D J\n"
      "WALK\n";
  intcode.set_queue(instructions);
  std::string out;
  while (!intcode.finished) {
    int64_t prun = intcode.run_program();
    if (prun >= 0 && prun < 256)
      out += prun;
    else
      return prun;
  }
  std::cout << out << '\n';
  return -1;
}

int64_t part2(memory_t program) {
  Intcode::IntcodeProgram<int64_t> intcode(program);
  // ABCDEFGHI
  // #####.#.#..##.###  at 3+  (3, 5, 6, 7, 8) holes
  // shouldn't jump on 3rd bcz
  // 3 + (4 + 1) is hole must jump right after land -> !E
  // 3 + (4 + 4) is hole and if jumped after land would still fall -> !H
  // !E ^ !H -> cant double jump and cant walk forward after land
  // !E ^ !H -> must be false so it doesnt fail
  // ~(~E ^ ~H) = E v H
  // ~(A ^ B ^ C) ^ D ^ (E v H)
  // ~(A ^ B ^ C) ^ (E v H) ^ D
  std::string instructions = //
      "OR A T\n"
      "AND B T\n"
      "AND C T\n"
      "NOT T T\n"
      "OR E J\n"
      "OR H J\n"
      "AND D J\n"
      "AND T J\n"
      "RUN\n";
  intcode.set_queue(instructions);
  std::string out;
  while (!intcode.finished) {
    int64_t prun = intcode.run_program();
    if (prun >= 0 && prun < 256)
      out += prun;
    else
      return prun;
  }
  std::cout << out << '\n';
  return -1;
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day21.txt";
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
