#include <algorithm>
#include <cmath>
#include <fstream>
#include <iostream>
#include <numeric>
#include <set>
#include <tuple>
#include <utility>
#include <vector>

using position = std::pair<int, int>;
using pair_vec = std::vector<position>;

template <typename T, typename U>
std::pair<T, U> &operator+=(std::pair<T, U> &l, const std::pair<T, U> &r) {
  l.first += r.first;
  l.second += r.second;
  return l;
}
template <typename T, typename U>
std::pair<T, U> operator-(const std::pair<T, U> &l, const std::pair<T, U> &r) {
  return {l.first - r.first, l.second - r.second};
}

template <typename T>
std::pair<T, T> operator/(const std::pair<T, T> &l, const T &r) {
  return {l.first / r, l.second / r};
}

pair_vec parse_data(std::istream &fh) {
  pair_vec out;
  std::string line;
  int x;
  int y = 0;
  while (fh >> line) {
    x = line.find('#');
    while (x != std::string::npos) {
      out.push_back({x, y});
      x = line.find('#', x + 1);
    }
    y++;
  }
  return out;
}

std::set<position> count_visible(const position station,
                                 const pair_vec asteroids) {
  std::set<position> seen;
  for (position pos : asteroids) {
    if (pos == station) continue;
    position diff_station = pos - station;
    int gcd = std::abs(std::gcd(diff_station.first, diff_station.second));
    seen.insert(diff_station / gcd);
  }
  return seen;
}

std::tuple<int, position, std::set<position>> best_station(
    const pair_vec asteroids) {
  std::tuple<int, position, std::set<position>> out;
  int record_visible = -1;
  for (auto station : asteroids) {
    auto visible = count_visible(station, asteroids);
    int nvisible = visible.size();
    if (nvisible > record_visible) {
      out = std::make_tuple(nvisible, station, visible);
      record_visible = nvisible;
    }
  }
  return out;
}

position get_target_diff(position station,
                         std::set<position> visible_asteroids) {
  auto sort_clockwise = [](position a, position b) {
    return std::atan2(a.first, a.second) > std::atan2(b.first, b.second);
  };
  pair_vec visible_vec(visible_asteroids.begin(), visible_asteroids.end());
  std::sort(visible_vec.begin(), visible_vec.end(), sort_clockwise);
  return visible_vec[199];
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day10.txt";
  std::ifstream fh(filepath);
  pair_vec asteroids = parse_data(fh);
  auto [nvisible, station, visible] = best_station(asteroids);
  std::cout << "Part1: " << nvisible << std::endl;
  position target_dif = get_target_diff(station, visible);
  position target_ast = {station.first + target_dif.first,
                         station.second + target_dif.second};
  while (std::find(asteroids.begin(), asteroids.end(), target_ast) ==
         asteroids.end()) {
    target_ast += target_dif;
  }
  std::cout << "Part2: " << target_ast.first * 100 + target_ast.second
            << std::endl;
  return 0;
}
