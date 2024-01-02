#include "iostream"
#include <fstream>
#include <vector>
using namespace std;

vector<int> parse_data(istream &fh) {
  int val;
  vector<int> out;
  string str;
  while (getline(fh, str, ',')) {
    out.push_back(stoi(str));
  }
  return out;
}

int run_program(vector<int> vint) {
  for (int i = 0; vint[i] != 99; i += 4) {
    int p1 = vint[i + 1];
    int p2 = vint[i + 2];
    int overwrite_pos = vint[i + 3];
    switch (vint[i]) {
    case 1:
      vint[overwrite_pos] = vint[p1] + vint[p2];
      break;
    case 2:
      vint[overwrite_pos] = vint[p1] * vint[p2];
      break;
    }
  }
  return vint[0];
}

int part2(vector<int> vint) {
  for (int noun = 0; noun < 100; noun++) {
    for (int verb = 0; verb < 100; verb++) {
      vint[1] = noun;
      vint[2] = verb;
      if (run_program(vint) == 19690720)
        return 100 * noun + verb;
    }
  }
  throw std::runtime_error("Not found");
}

int main() {
  std::ifstream fh("input/day02.txt");
  vector<int> program = parse_data(fh);
  program[1] = 12;
  program[2] = 2;
  cout << "Part1: " << run_program(program) << endl;
  cout << "Part2: " << part2(program) << endl;
  return 0;
}
