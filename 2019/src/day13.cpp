#include <cstdint>
#include <fstream>
#include <iostream>
#include <ostream>
#include <stdexcept>
#include <string>
#include <unordered_map>

using memory_t = std::unordered_map<unsigned long long int, long long int>;

struct block_t {
  int64_t x, y, id;
};

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

int power(uint64_t a, uint64_t b) {
  if (b == 0)
    return 1;
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
        return -1;
        break;
      default:
        std::cerr << "Unexpected code " << op_code << '\n';
        throw 1;
      }
    }
  }
};

int part1(memory_t program) {
  IntcodeProgram intcode(program);
  int i = 0;
  int out = 0;
  int prog_output = intcode.run_program();
  while (!intcode.finished) {
    if (i == 2 && prog_output == 2) {
      out++;
    }
    i = (i + 1) % 3;
    prog_output = intcode.run_program();
  }
  return out;
}

int part2(memory_t program) {
  IntcodeProgram intcode(program);
  intcode.memory[0] = 2;
  int i = 0;
  int score = 0;
  block_t cur_block;
  int paddle_x = 0, ball_x = 0;
  auto get_input = [&paddle_x, &ball_x]() -> int {
    if (ball_x < paddle_x)
      return -1;
    else if (ball_x > paddle_x)
      return 1;
    return 0;
  };
  int inp = get_input();
  int prog_output = intcode.run_program(inp);
  while (!intcode.finished) {
    switch (i) {
    case 0:
      cur_block.x = prog_output;
      break;
    case 1:
      cur_block.y = prog_output;
      break;
    case 2:
      cur_block.id = prog_output;
      if (cur_block.x == -1 && cur_block.y == 0)
        score = prog_output;
      if (prog_output == 4) {
        ball_x = cur_block.x;
      } else if (prog_output == 3) {
        paddle_x = cur_block.x;
      }
      break;
    }
    i = (i + 1) % 3;
    inp = get_input();
    prog_output = intcode.run_program(inp);
  };
  return score;
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day13.txt";
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  const memory_t program = parse_data(fh);
  std::cout << "Part1: " << part1(program) << std::endl;
  std::cout << "Part2: " << part2(program) << std::endl;
  return 0;
}
