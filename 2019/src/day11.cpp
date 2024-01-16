#include <algorithm>
#include <fstream>
#include <iostream>
#include <limits>
#include <map>
#include <ostream>
#include <set>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

using position = std::pair<int, int>;
using pair_map = std::map<position, bool>;
using pairset = std::set<position>;
using memory_t = std::unordered_map<unsigned long long int, long long int>;

memory_t parse_data(std::istream &fh) {
  memory_t out;
  std::string str;
  int i = 0;
  while (getline(fh, str, ',')) {
    out[i] = std::stoll(str);
    i++;
  }
  return out;
}

int power(unsigned int a, unsigned int b) {
  if (b == 0) return 1;
  return a * power(a, b - 1);
}

class IntcodeProgram {
  int get_pos(int i) {
    switch ((program[inst_ptr] / (power(10, i + 1)) % 10)) {
      case 0:
        return program[inst_ptr + i];
      case 1:
        return inst_ptr + i;
      case 2:
        return relative_base + program[inst_ptr + i];
      default:
        throw std::runtime_error("Unexpected mode");
    }
  }

 public:
  memory_t program;
  int inst_ptr = 0;
  int relative_base = 0;

  IntcodeProgram(memory_t program) : program(program) {}

  int run_program(int input) {
    int op_code, ow;
    while (program[inst_ptr] != 99) {
      op_code = program[inst_ptr] % 100;
      switch (op_code) {
        case 1:
          ow = get_pos(3);
          program[ow] = program[get_pos(1)] + program[get_pos(2)];
          inst_ptr += 4;
          break;
        case 2:
          ow = get_pos(3);
          program[ow] = program[get_pos(1)] * program[get_pos(2)];
          inst_ptr += 4;
          break;
        case 3:
          ow = get_pos(1);
          program[ow] = input;
          inst_ptr += 2;
          break;
        case 4:
          ow = get_pos(1);
          inst_ptr += 2;
          return program[ow];
        case 5:
          inst_ptr =
              program[get_pos(1)] != 0 ? program[get_pos(2)] : inst_ptr + 3;
          break;
        case 6:
          inst_ptr =
              program[get_pos(1)] == 0 ? program[get_pos(2)] : inst_ptr + 3;
          break;
        case 7:
          ow = get_pos(3);
          program[ow] = program[get_pos(1)] < program[get_pos(2)] ? 1 : 0;
          inst_ptr += 4;
          break;
        case 8:
          ow = get_pos(3);
          program[ow] = program[get_pos(1)] == program[get_pos(2)] ? 1 : 0;
          inst_ptr += 4;
          break;
        case 9:
          relative_base += program[get_pos(1)];
          inst_ptr += 2;
          break;
        default:
          return -2;
      }
    }
    return -1;
  }

  virtual ~IntcodeProgram() {}
};

pair_map run_robot(memory_t program, int start_color = 0) {
  IntcodeProgram intcode(program);
  int x = 0, y = 0;
  int dx = 0, dy = -1;
  pair_map painted;
  int color = intcode.run_program(start_color);
  while (color == 0 || color == 1) {
    painted[std::make_pair(x, y)] = color;
    bool turn_left = intcode.run_program(0) == 0;
    if (turn_left) {
      int tmp = dy;
      dy = -dx;
      dx = tmp;
    } else {
      int tmp = dy;
      dy = dx;
      dx = -tmp;
    }
    x += dx;
    y += dy;
    auto it = painted.find(std::make_pair(x, y));
    if (it != painted.end())
      color = intcode.run_program(it->second);
    else
      color = intcode.run_program(0);
  }
  return painted;
}

void display(std::vector<std::pair<int, int>> map) {
  int xmin = std::numeric_limits<int>::max();
  int xmax = std::numeric_limits<int>::min();
  int ymin = xmin;
  int ymax = xmax;
  for (auto [x, y] : map) {
    if (xmin > x) xmin = x;
    if (xmax < x) xmax = x;
    if (ymin > y) ymin = y;
    if (ymax < y) ymax = y;
  }
  for (int y = ymin; y <= ymax; ++y) {
    for (int x = xmin; x <= xmax; ++x) {
      auto it = std::find(map.begin(), map.end(), std::make_pair(x, y));
      char ch = it != map.end() ? '#' : ' ';
      std::cout << ch;
    }
    std::cout << '\n';
  }
}

void part2(memory_t program) {
  IntcodeProgram intcode(program);
  int x = 0, y = 0;
  int dx = 0, dy = -1;
  int tmp;
  std::vector<std::pair<int, int>> white_panels;
  white_panels.reserve(128);  // prevents malloc error
  auto get_it = [&x, &y, &white_panels]() -> auto {
    return std::find(white_panels.begin(), white_panels.end(),
                     std::make_pair(x, y));
  };
  int color = intcode.run_program(1);
  while (color == 0 || color == 1) {
    auto it = get_it();
    if (color == 1 && it == white_panels.end()) {
      white_panels.push_back(std::make_pair(x, y));
    } else if (color == 0 && it != white_panels.end()) {
      white_panels.erase(it);
    }
    bool turn_left = intcode.run_program(0) == 0;
    if (turn_left) {
      tmp = dy;
      dy = -dx;
      dx = tmp;
    } else {
      tmp = dy;
      dy = dx;
      dx = -tmp;
    }
    x += dx;
    y += dy;
    it = get_it();
    if (it != white_panels.end())
      color = intcode.run_program(1);
    else
      color = intcode.run_program(0);
  }
  display(white_panels);
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day11.txt";
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  memory_t program = parse_data(fh);
  std::cout << "Part1: " << run_robot(program).size() << std::endl;
  std::cout << "Part2: " << std::endl;
  part2(program);
  return 0;
}
