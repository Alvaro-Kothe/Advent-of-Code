#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <unordered_map>

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

void run_program(memory_t vint, int input) {
  int inst_ptr = 0, relative_base = 0;
  int op_code, ow;
  auto get_pos = [&vint, &inst_ptr, &relative_base](int i) -> int {
    switch ((vint[inst_ptr] / (power(10, i + 1)) % 10)) {
      case 0:
        return vint[inst_ptr + i];
      case 1:
        return inst_ptr + i;
      case 2:
        return relative_base + vint[inst_ptr + i];
      default:
        throw std::runtime_error("Unexpected mode");
    }
  };
  while (vint[inst_ptr] != 99) {
    op_code = vint[inst_ptr] % 100;
    switch (op_code) {
      case 1:
        ow = get_pos(3);
        vint[ow] = vint[get_pos(1)] + vint[get_pos(2)];
        inst_ptr += 4;
        break;
      case 2:
        ow = get_pos(3);
        vint[ow] = vint[get_pos(1)] * vint[get_pos(2)];
        inst_ptr += 4;
        break;
      case 3:
        ow = get_pos(1);
        vint[ow] = input;
        inst_ptr += 2;
        break;
      case 4:
        std::cout << vint[get_pos(1)] << std::endl;
        inst_ptr += 2;
        break;
      case 5:
        inst_ptr = vint[get_pos(1)] != 0 ? vint[get_pos(2)] : inst_ptr + 3;
        break;
      case 6:
        inst_ptr = vint[get_pos(1)] == 0 ? vint[get_pos(2)] : inst_ptr + 3;
        break;
      case 7:
        ow = get_pos(3);
        vint[ow] = vint[get_pos(1)] < vint[get_pos(2)] ? 1 : 0;
        inst_ptr += 4;
        break;
      case 8:
        ow = get_pos(3);
        vint[ow] = vint[get_pos(1)] == vint[get_pos(2)] ? 1 : 0;
        inst_ptr += 4;
        break;
      case 9:
        relative_base += vint[get_pos(1)];
        inst_ptr += 2;
        break;
      default:
        throw std::runtime_error("Bad operator");
    }
  }
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day09.txt";
  std::ifstream fh(filepath);
  memory_t program = parse_data(fh);
  std::cout << "Part1: ";
  run_program(program, 1);
  std::cout << "Part2: ";
  run_program(program, 2);
  return 0;
}
