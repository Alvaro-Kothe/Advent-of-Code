#include "intcode.h"
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <ostream>
#include <set>
#include <string>

using position_t = std::pair<int, int>;
std::string ascii_program(memory_t program) {
  Intcode::IntcodeProgram intcode(program);
  std::string out;
  while (!intcode.finished) {
    char c = intcode.run_program();
    out += c;
  }
  return out;
}

struct Robot {
  position_t pos, dir;
  position_t move() { return {pos.first + dir.first, pos.second + dir.second}; }
};

struct Grid {
  int nrow, ncol;
  Robot robot;
  std::set<position_t> scafold;
};

Grid parse_grid(const std::string grid_str) {
  Grid grid;
  int i = 0, j = 0;
  for (char ch : grid_str) {
    switch (ch) {
    case '\n':
      i++;
      grid.ncol = j;
      j = -1; // it will be incremented to 0 after the switch
      break;
    case '#':
      grid.scafold.insert({i, j});
      break;
    case '^':
      grid.robot.pos = {i, j};
      grid.robot.dir = {-1, 0};
      break;
    case 'v':
      grid.robot.pos = {i, j};
      grid.robot.dir = {1, 0};
      break;
    case '>':
      grid.robot.pos = {i, j};
      grid.robot.dir = {0, 1};
      break;
    case '<':
      grid.robot.pos = {i, j};
      grid.robot.dir = {0, -1};
      break;
    default:
      break;
    }
    j++;
  }
  grid.nrow = i;
  return grid;
}

template <typename T, typename U>
std::pair<T, U> operator+(const std::pair<T, U> &l, const std::pair<T, U> &r) {
  return {l.first + r.first, l.second + r.second};
}

uint32_t part1(const std::set<position_t> scafolds) {
  static std::array<position_t, 4> directions = {
      std::pair(-1, 0), std::pair(1, 0), std::pair(0, -1), std::pair(0, 1)};
  uint32_t out = 0;
  auto is_intersection = [&scafolds](const position_t pos) -> bool {
    for (auto dir : directions) {
      if (scafolds.find(pos + dir) == scafolds.end())
        return false;
    }
    return true;
  };
  for (auto scafold : scafolds) {
    if (is_intersection(scafold))
      out += scafold.first * scafold.second;
  }
  return out;
}

position_t turn(const position_t cur_dir, const char turn_dir) {
  switch (turn_dir) {
  case 'L':
    return {-cur_dir.second, cur_dir.first};
  case 'R':
    return {cur_dir.second, -cur_dir.first};
  }
  throw "Invalid direction";
}

std::string escape(char c) {
  std::string s(1, c);
  return s;
}

std::vector<std::string> get_path(Grid grid) {
  std::vector<std::string> path;
  static std::array<char, 2> directions{'L', 'R'};
  auto valid_move = [&grid]() -> bool {
    return grid.scafold.find(grid.robot.move()) != grid.scafold.end();
  };
  if (!valid_move()) { // fix robot direction
    for (char dir : directions) {
      auto old_dir = grid.robot.dir;
      grid.robot.dir = turn(grid.robot.dir, dir);
      if (valid_move()) {
        path.push_back(escape(dir));
        break;
      } else
        grid.robot.dir = old_dir;
    }
  }
  for (;;) {
    uint32_t n_moves = 0;
    while (valid_move()) {
      n_moves++;
      grid.robot.pos = grid.robot.move();
    }
    path.push_back(std::to_string(n_moves));
    bool dead_end = true;
    for (char dir : directions) { // arrived at the end, must turn.
      auto old_dir = grid.robot.dir;
      grid.robot.dir = turn(grid.robot.dir, dir);
      if (valid_move()) {
        path.push_back(escape(dir));
        dead_end = false;
        break;
      } else
        grid.robot.dir = old_dir;
    }
    if (dead_end)
      return path;
  }
}
std::string join(const std::vector<std::string> vec,
                 const std::string separator) {
  std::string out;
  for (auto s = vec.begin(); s != vec.end(); ++s) {
    out += *s;
    if (s != vec.end() - 1)
      out += separator;
  }
  return out;
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day17.txt";
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  const memory_t program = Intcode::parse_data(fh);
  auto grid_str = ascii_program(program);
  auto grid = parse_grid(grid_str);
  std::cout << "Part1: " << part1(grid.scafold) << '\n';
  std::cout << grid_str;
  auto path = get_path(grid);
  std::cout << "Path: " << join(path, ",") << '\n';
  std::string path_parts = "A,A,C,B,C,B,C,A,B,A\n" // main
                           "R,8,L,12,R,8\n"        // A
                           "L,12,L,12,L,10,R,10\n" // B
                           "L,10,L,10,R,8\n"       // C
                           "n\n";                  // no feed
  std::queue<int64_t> input_queue;
  for (char ch : path_parts)
    input_queue.push(ch);
  Intcode::IntcodeProgram intcode(program);
  intcode.memory[0] = 2;
  intcode.queue = input_queue;
  int p2 = 0;
  while (!intcode.finished) {
    p2 = intcode.run_program();
  }
  std::cout << "Part2: " << p2 << '\n';
  return 0;
}
