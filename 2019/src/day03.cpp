#include <algorithm>
#include <fstream>
#include <iostream>
#include <limits>
#include <map>
#include <sstream>
#include <utility>
using namespace std;

map<pair<int, int>, int> parse_data(const string line) {
  map<pair<int, int>, int> out;
  char dir, c;
  int steps, dx, dy;
  int x = 0, y = 0, len = 0;
  std::stringstream ss(line);
  while (ss >> dir >> steps >> c) {
    switch (dir) {
      case 'U':
        dx = -1;
        dy = 0;
        break;
      case 'D':
        dx = 1;
        dy = 0;
        break;
      case 'L':
        dx = 0;
        dy = -1;
        break;
      case 'R':
        dx = 0;
        dy = 1;
        break;
    }

    for (int i = 0; i < steps; i++) {
      x += dx;
      y += dy;
      len += 1;
      out[{x, y}] = len;
    }
  }
  return out;
}
pair<int, int> get_clst_int_dst(map<pair<int, int>, int> path1,
                                map<pair<int, int>, int> path2) {
  int dst = std::numeric_limits<int>::max();
  int mstep = std::numeric_limits<int>::max();
  for (auto [pos, p1_step] : path1) {
    if (path2.count(pos) > 0) {
      dst = min(dst, abs(pos.first) + abs(pos.second));
      mstep = min(mstep, p1_step + path2[pos]);
    }
  }
  return {dst, mstep};
}
int main(int argc, char *argv[]) {
  string filepath = argc > 1 ? argv[1] : "input/day03.txt";
  std::ifstream fh(filepath);
  string line1, line2;
  fh >> line1 >> line2;

  map<pair<int, int>, int> path1, path2;
  path1 = parse_data(line1);
  path2 = parse_data(line2);
  pair<int, int> ans = get_clst_int_dst(path1, path2);
  cout << "Part1: " << ans.first << endl;
  cout << "Part2: " << ans.second << endl;
  return 0;
}
