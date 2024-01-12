#include <array>
#include <cctype>
#include <cstddef>
#include <fstream>
#include <iostream>
#include <istream>
#include <ostream>
#include <queue>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>

using position_t = std::pair<int, int>;
template <> struct std::hash<position_t> {
  std::size_t operator()(const position_t &pos) const noexcept {
    std::size_t h1 = std::hash<int>{}(pos.first);
    std::size_t h2 = std::hash<int>{}(pos.second);
    return h1 ^ (h2 << 1);
  }
};
template <> struct std::hash<std::pair<position_t, size_t>> {
  std::size_t
  operator()(const std::pair<position_t, size_t> &h) const noexcept {
    std::size_t h1 = std::hash<position_t>{}(h.first);
    std::size_t h2 = std::hash<size_t>{}(h.second);
    return h1 ^ (h2 << 1);
  }
};
template <typename T, typename U>
std::pair<T, U> operator+(const std::pair<T, U> &l, const std::pair<T, U> &r) {
  return {l.first + r.first, l.second + r.second};
}

const static std::array<position_t, 4> directions = {
    std::pair(-1, 0), std::pair(1, 0), std::pair(0, -1), std::pair(0, 1)};

struct Grid {
  std::unordered_set<position_t> open_passages;
  std::unordered_map<position_t, std::string> portal_pos2str;
  std::unordered_map<std::string, std::vector<position_t>> portal_str2pos;
  std::unordered_map<position_t, position_t> portal_pos2pos;
  size_t nrow, ncol;
};

Grid parse_data(std::istream &fh) {
  Grid grid;
  int i = 0, j = 0;
  char ch;
  std::unordered_map<position_t, char> char_positions;
  while (fh.get(ch)) {
    if (ch == '\n') {
      i++;
      grid.ncol = j;
      j = 0;
      continue;
    } else if (ch == '.') {
      grid.open_passages.insert({i, j});
    } else if (std::isupper(ch)) {
      char_positions[{i, j}] = ch;
    }
    j++;
  }

  while (!char_positions.empty()) {
    position_t dot_pos = {-1, -1};
    auto el = char_positions.begin();
    std::string str;
    for (position_t dir : directions) {
      position_t np = el->first + dir;
      if (str.size() < 2) {
        if (auto it = char_positions.find(np); it != char_positions.end()) {
          str = el->first < it->first ? std::string(1, el->second) + it->second
                                      : std::string(1, it->second) + el->second;
          char_positions.erase(it);
          position_t adj_nb = np + dir;
          if (dot_pos.first < 0 &&
              grid.open_passages.find(adj_nb) != grid.open_passages.end())
            dot_pos = adj_nb;
        }
      }
      if (dot_pos.first < 0 &&
          grid.open_passages.find(np) != grid.open_passages.end())
        dot_pos = np;
      if (str.size() == 2 && dot_pos.first >= 0)
        break;
    }
    char_positions.erase(el);
    grid.portal_pos2str[dot_pos] = str;
    grid.portal_str2pos[str].push_back(dot_pos);
  }
  for (auto it : grid.portal_str2pos) {
    if (it.second.size() == 2) {
      grid.portal_pos2pos[it.second[0]] = it.second[1];
      grid.portal_pos2pos[it.second[1]] = it.second[0];
    }
  }
  grid.nrow = i;
  return grid;
}

size_t bfs(Grid grid, position_t source, position_t target) {
  std::queue<std::pair<position_t, size_t>> queue;
  queue.push({source, 0});
  std::unordered_set<position_t> visited{source};
  while (!queue.empty()) {
    auto [pos, dst] = queue.front();
    queue.pop();
    if (pos == target)
      return dst;
    for (auto dir : directions) {
      position_t next_pos = pos + dir;
      if (visited.find(next_pos) != visited.end() ||
          grid.open_passages.find(next_pos) == grid.open_passages.end())
        continue;
      visited.insert(next_pos);
      if (auto it = grid.portal_pos2pos.find(next_pos);
          it != grid.portal_pos2pos.end() &&
          visited.find(it->second) == visited.end()) {
        visited.insert(it->second);
        queue.push({it->second, dst + 2});
      }
      queue.push({next_pos, dst + 1});
    }
  }
  throw std::runtime_error("Unreachable");
}

size_t part2(Grid grid) {
  position_t source = grid.portal_str2pos["AA"][0],
             target = grid.portal_str2pos["ZZ"][0];

  std::queue<std::pair<std::pair<position_t, size_t>, size_t>> queue;
  queue.push({{source, 0}, 0});
  std::unordered_set<std::pair<position_t, size_t>> visited;
  while (!queue.empty()) {
    auto [cur_state, dst] = queue.front();
    auto [pos, depth] = cur_state;
    queue.pop();
    if (pos == target && depth == 0)
      return dst;
    if (visited.find(cur_state) != visited.end())
      continue;
    visited.insert(cur_state);
    for (auto dir : directions) {
      auto next_pos = pos + dir;
      if (grid.open_passages.find(next_pos) == grid.open_passages.end())
        continue;
      if (auto it = grid.portal_pos2pos.find(next_pos);
          it != grid.portal_pos2pos.end()) {
        if (3 < next_pos.first && next_pos.first < grid.nrow - 3 &&
            3 < next_pos.second &&
            next_pos.second < grid.ncol - 3) // Inner loop
          queue.push({{it->second, depth + 1}, dst + 2});
        else if (depth > 0) // outer loop
          queue.push({{it->second, depth - 1}, dst + 2});
      }
      queue.push({{next_pos, depth}, dst + 1});
    }
  }
  throw std::runtime_error("Unreachable");
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day20.txt";
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  auto grid = parse_data(fh);
  std::cout << "Part1: "
            << bfs(grid, grid.portal_str2pos["AA"][0],
                   grid.portal_str2pos["ZZ"][0])
            << '\n';
  std::cout << "Part2: " << part2(grid) << '\n';
  return 0;
}
