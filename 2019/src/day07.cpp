#include <algorithm>
#include <fstream>
#include <functional>
#include <iostream>
#include <vector>

std::vector<int> parse_data(std::istream &fh) {
  std::vector<int> out;
  std::string str;
  while (getline(fh, str, ',')) {
    out.push_back(stoi(str));
  }
  return out;
}

class Amplifier {
public:
  std::vector<int> program;
  int inst_ptr = 0;

  Amplifier(std::vector<int> program, int inst_ptr = 0)
      : program(program), inst_ptr(inst_ptr) {}

  void update_values(int &v1, int &v2) {
    int oparg = program[inst_ptr];
    int m1 = (oparg / 100) % 10;
    int m2 = (oparg / 1000) % 10;
    v1 = m1 == 1 ? program[inst_ptr + 1] : program[program[inst_ptr + 1]];
    v2 = m2 == 1 ? program[inst_ptr + 2] : program[program[inst_ptr + 2]];
  }
  int run_program(int input_signal, int output_signal) {
    int op_code, v1, v2, ow;
    int out;
    while (program[inst_ptr] != 99) {
      op_code = program[inst_ptr] % 100;
      switch (op_code) {
      case 1:
        update_values(v1, v2);
        ow = program[inst_ptr + 3];
        program[ow] = v1 + v2;
        inst_ptr += 4;
        break;
      case 2:
        update_values(v1, v2);
        ow = program[inst_ptr + 3];
        program[ow] = v1 * v2;
        inst_ptr += 4;
        break;
      case 3:
        ow = program[inst_ptr + 1];
        program[ow] = input_signal;
        input_signal = output_signal;
        inst_ptr += 2;
        break;
      case 4:
        inst_ptr += 2;
        return program[program[inst_ptr - 1]];
        break;
      case 5:
        update_values(v1, v2);
        inst_ptr = v1 != 0 ? v2 : inst_ptr + 3;
        break;
      case 6:
        update_values(v1, v2);
        inst_ptr = v1 == 0 ? v2 : inst_ptr + 3;
        break;
      case 7:
        update_values(v1, v2);
        ow = program[inst_ptr + 3];
        program[ow] = v1 < v2 ? 1 : 0;
        inst_ptr += 4;
        break;
      case 8:
        update_values(v1, v2);
        ow = program[inst_ptr + 3];
        program[ow] = v1 == v2 ? 1 : 0;
        inst_ptr += 4;
        break;
      default:
        throw std::runtime_error("Bad operator");
      }
    }
    return -1;
  }
};

int get_thruster_signal(std::vector<int> vint, std::vector<int> seq) {
  int signal = 0;
  for (int is : seq) {
    signal = Amplifier(vint).run_program(is, signal);
  }
  return signal;
}

int max_thruster(std::vector<int> vint, std::vector<int> perm,
                 std::function<int(std::vector<int>, std::vector<int>)>
                     thruster_fn = get_thruster_signal) {
  int out = -1;
  do {
    out = std::max(out, thruster_fn(vint, perm));
  } while (std::next_permutation(perm.begin(), perm.end()));
  return out;
}

int get_looped_thruster_signal(std::vector<int> vint, std::vector<int> seq) {
  int signal = 0, cur_amp = 0;
  int program_output;
  std::vector<Amplifier> vamp;
  for (int i = 0; i < seq.size(); i++) {
    Amplifier amp = Amplifier(vint);
    signal = amp.run_program(seq[i], signal);
    vamp.push_back(amp);
  }
  program_output = signal;
  while (program_output >= 0) {
    signal = program_output;
    program_output = vamp[cur_amp].run_program(signal, signal);
    cur_amp = (cur_amp + 1) % seq.size();
  }
  return signal;
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day07.txt";
  std::ifstream fh(filepath);
  std::vector<int> program = parse_data(fh);
  std::cout << "Part1: " << max_thruster(program, std::vector{0, 1, 2, 3, 4})
            << std::endl;
  std::cout << "Part2: "
            << max_thruster(program, std::vector{5, 6, 7, 8, 9},
                            get_looped_thruster_signal)
            << std::endl;
  return 0;
}
