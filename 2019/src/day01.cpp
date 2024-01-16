#include <fstream>
#include <iostream>

using namespace std;
int compute_fuel(const int x) { return (x / 3 - 2); }
int compute_fuel2(const int x) {
  int fuel = compute_fuel(x);
  if (fuel <= 0) return 0;
  return fuel + compute_fuel2(fuel);
}

int main() {
  int p1 = 0;
  int p2 = 0;
  std::ifstream f_in("input/day01.txt");
  string line;
  int mass;
  while (getline(f_in, line)) {
    mass = stoi(line);
    p1 += compute_fuel(mass);
    p2 += compute_fuel2(mass);
  }
  cout << "Part1: " << p1 << endl;
  cout << "Part2: " << p2 << endl;
  return 0;
}
