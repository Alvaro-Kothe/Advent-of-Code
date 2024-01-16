#include <fstream>
#include <iostream>
#include <vector>
using namespace std;

vector<int> parse_data(istream &fh) {
  vector<int> out;
  string str;
  while (getline(fh, str, ',')) {
    out.push_back(stoi(str));
  }
  return out;
}

void update_values(vector<int> vint, int n, int &v1, int &v2) {
  int oparg = vint[n];
  int m1 = (oparg / 100) % 10;
  int m2 = (oparg / 1000) % 10;
  v1 = m1 == 1 ? vint[n + 1] : vint[vint[n + 1]];
  v2 = m2 == 1 ? vint[n + 2] : vint[vint[n + 2]];
}

void run_program(vector<int> vint, int input) {
  int inst_ptr = 0;
  int op_code, v1, v2, ow;
  while (vint[inst_ptr] != 99) {
    op_code = vint[inst_ptr] % 100;
    switch (op_code) {
      case 1:
        update_values(vint, inst_ptr, v1, v2);
        ow = vint[inst_ptr + 3];
        vint[ow] = v1 + v2;
        inst_ptr += 4;
        break;
      case 2:
        update_values(vint, inst_ptr, v1, v2);
        ow = vint[inst_ptr + 3];
        vint[ow] = v1 * v2;
        inst_ptr += 4;
        break;
      case 3:
        ow = vint[inst_ptr + 1];
        vint[ow] = input;
        inst_ptr += 2;
        break;
      case 4:
        cout << vint[vint[inst_ptr + 1]] << endl;
        inst_ptr += 2;
        break;
      case 5:
        update_values(vint, inst_ptr, v1, v2);
        inst_ptr = v1 != 0 ? v2 : inst_ptr + 3;
        break;
      case 6:
        update_values(vint, inst_ptr, v1, v2);
        inst_ptr = v1 == 0 ? v2 : inst_ptr + 3;
        break;
      case 7:
        update_values(vint, inst_ptr, v1, v2);
        ow = vint[inst_ptr + 3];
        vint[ow] = v1 < v2 ? 1 : 0;
        inst_ptr += 4;
        break;
      case 8:
        update_values(vint, inst_ptr, v1, v2);
        ow = vint[inst_ptr + 3];
        vint[ow] = v1 == v2 ? 1 : 0;
        inst_ptr += 4;
        break;
      default:
        throw std::runtime_error("Bad operator");
    }
  }
}

int main(int argc, char **argv) {
  string filepath = argc > 1 ? argv[1] : "input/day05.txt";
  std::ifstream fh(filepath);
  vector<int> program = parse_data(fh);
  cout << "Part1: " << endl;
  run_program(program, 1);
  cout << "Part2: ";
  run_program(program, 5);
  return 0;
}
