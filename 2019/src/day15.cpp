#include <cstdint>
#include <fstream>
#include <iostream>
#include <ostream>
#include <queue>
#include <set>
#include <string>
#include <unordered_map>
#include <utility>

using position_t = std::pair<int, int>;
using memory_t = std::unordered_map<unsigned long long int, long long int>;

int power(uint64_t a, uint64_t b) {
  if (b == 0) return 1;
  return a * power(a, b - 1);
}

class IntcodeProgram {
  int64_t get_pos(int64_t i) {
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
  int inst_ptr = 0;
  int64_t relative_base = 0;
  bool finished = false;

  IntcodeProgram(const memory_t program) : memory(program) {}

  int64_t run_program(int input = -1) {
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
          ow = get_pos(1);
          memory[ow] = input;
          inst_ptr += 2;
          break;
        case 4:
          ow = get_pos(1);
          inst_ptr += 2;
          return memory[ow];
        case 5:
          inst_ptr =
              memory[get_pos(1)] != 0 ? memory[get_pos(2)] : inst_ptr + 3;
          break;
        case 6:
          inst_ptr =
              memory[get_pos(1)] == 0 ? memory[get_pos(2)] : inst_ptr + 3;
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
          return -1;
          break;
        default:
          std::cerr << "Unexpected code " << op_code << '\n';
          throw 1;
      }
    }
  }
};

template <typename T, typename U>
std::pair<T, U> operator+(const std::pair<T, U> &l, const std::pair<T, U> &r) {
  return {l.first + r.first, l.second + r.second};
}

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

struct SearchState {
  uint32_t n_commands;
  position_t position;
  IntcodeProgram intcode;

  SearchState(uint32_t n_commands, position_t pos, IntcodeProgram program)
      : n_commands(n_commands), position(pos), intcode(program) {}
};

position_t get_dir(int i) {
  switch (i) {
    case 1:
      return {-1, 0};
    case 2:
      return {1, 0};
    case 3:
      return {0, -1};
    case 4:
      return {0, 1};
  }
  throw "Unexpected direction";
}

void bfs(memory_t initial_program) {
  std::set<position_t> empty_spaces;
  std::queue<SearchState> to_visit;
  to_visit.push(SearchState(0, {0, 0}, IntcodeProgram(initial_program)));
  position_t ox_pos;
  position_t nxt_pos;
  int mv_cmd;
  // Step 1: find oxygen pos and empty spaces
  while (!to_visit.empty()) {
    auto node = to_visit.front();
    to_visit.pop();
    empty_spaces.insert(node.position);
    for (mv_cmd = 1; mv_cmd < 5; ++mv_cmd) {
      nxt_pos = get_dir(mv_cmd) + node.position;
      if (empty_spaces.find(nxt_pos) != empty_spaces.end()) continue;
      IntcodeProgram nxt_prg = node.intcode;
      int64_t status_code = nxt_prg.run_program(mv_cmd);
      switch (status_code) {
        case 1:
          to_visit.push(SearchState(node.n_commands + 1, nxt_pos, nxt_prg));
          break;
        case 2:
          std::cout << "Part1: " << node.n_commands + 1 << std::endl;
          ox_pos = nxt_pos;
          break;
        default:
          break;
      }
    }
  }
  // Step 2: repeat bfs, but just move through empty spaces
  std::queue<std::pair<position_t, uint64_t>> to_fill;
  to_fill.push({ox_pos, 0});
  int fill_time = 0;
  while (!to_fill.empty()) {
    auto [cur_pos, time] = to_fill.front();
    fill_time = time;
    to_fill.pop();
    for (mv_cmd = 1; mv_cmd < 5; ++mv_cmd) {
      nxt_pos = get_dir(mv_cmd) + cur_pos;
      auto fill_it = empty_spaces.find(nxt_pos);
      if (fill_it == empty_spaces.end()) continue;
      empty_spaces.erase(fill_it);
      to_fill.push({nxt_pos, time + 1});
    }
  }
  std::cout << "Part2: " << fill_time << std::endl;
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day15.txt";
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  const memory_t program = parse_data(fh);
  bfs(program);
  return 0;
}
