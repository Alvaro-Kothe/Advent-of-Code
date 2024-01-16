#include <array>
#include <cctype>
#include <cstddef>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <istream>
#include <limits>
#include <map>
#include <numeric>
#include <ostream>
#include <queue>
#include <set>
#include <string>
#include <utility>

using position_t = std::pair<int, int>;
using keyset_t = std::array<bool, 26>;

struct Grid {
  std::set<position_t> blocked_paths;
  std::map<position_t, char> keys;
  std::map<position_t, char> doors;
  std::vector<position_t> entrances;
};

Grid parse_data(std::istream &fh) {
  Grid grid;
  int i = 0, j = 0;
  char ch;
  while (fh.get(ch)) {
    if (ch == '\n') {
      i++;
      j = 0;
      continue;
    } else if (std::islower(ch)) {
      grid.keys[{i, j}] = ch;
    } else if (std::isupper(ch))
      grid.doors[{i, j}] = ch;
    else if (ch == '#')
      grid.blocked_paths.insert({i, j});
    else if (ch == '@') {
      grid.entrances.push_back({i, j});
    }
    j++;
  }
  return grid;
}

template <typename T, typename U>
std::pair<T, U> operator+(const std::pair<T, U> &l, const std::pair<T, U> &r) {
  return {l.first + r.first, l.second + r.second};
}

const static std::array<position_t, 4> directions = {
    std::pair(-1, 0), std::pair(1, 0), std::pair(0, -1), std::pair(0, 1)};

std::vector<position_t> get_neighbors(position_t pos) {
  std::vector<position_t> neighbors;
  for (auto dir : directions) {
    position_t next_pos = pos + dir;
    neighbors.push_back(next_pos);
  }
  return neighbors;
}

struct KeyState {
  position_t pos;
  uint32_t dst;
  char ch;
  KeyState(position_t pos, uint32_t dst, char key)
      : pos(pos), dst(dst), ch(key) {}
};

std::vector<KeyState> get_reachable_keys(const Grid grid,
                                         const position_t start_pos,
                                         const keyset_t obtained_keys) {
  std::vector<KeyState> reachable_keys;
  std::set<position_t> visited{start_pos};
  std::queue<std::pair<position_t, uint32_t>> move_queue;
  move_queue.push({start_pos, 0});
  while (!move_queue.empty()) {
    auto [pos, dist] = move_queue.front();
    move_queue.pop();
    auto neighbors = get_neighbors(pos);
    for (auto neighbor : neighbors) {
      if (visited.find(neighbor) != visited.end() ||
          grid.blocked_paths.find(neighbor) != grid.blocked_paths.end())
        continue;
      visited.insert(neighbor);
      if (auto door_it = grid.doors.find(neighbor);
          door_it != grid.doors.end() && !obtained_keys[door_it->second - 'A'])
        continue;
      else if (auto key_it = grid.keys.find(neighbor);
               key_it != grid.keys.end() &&
               !obtained_keys[key_it->second - 'a'])
        reachable_keys.push_back(KeyState(neighbor, dist + 1, key_it->second));
      else {
        move_queue.push({neighbor, dist + 1});
      }
    }
  }
  return reachable_keys;
}

std::vector<std::vector<KeyState>> get_reachable_keys_per_robot(
    const Grid grid, const std::vector<position_t> positions,
    const keyset_t obtained_keys) {
  std::vector<std::vector<KeyState>> robots;
  for (auto pos : positions)
    robots.push_back(get_reachable_keys(grid, pos, obtained_keys));
  return robots;
}

uint32_t get_keys(
    const Grid grid, const std::vector<position_t> pos,
    const keyset_t obtained_keys,
    std::map<std::pair<std::vector<position_t>, keyset_t>, uint32_t> &cache) {
  std::pair<std::vector<position_t>, keyset_t> cache_key = {pos, obtained_keys};
  if (auto it = cache.find(cache_key); it != cache.end()) return it->second;
  uint32_t collected_keys =
      std::reduce(obtained_keys.begin(), obtained_keys.end(), 0ul);
  if (collected_keys == grid.keys.size()) {
    cache[cache_key] = 0;
    return 0;
  }
  uint32_t out = std::numeric_limits<uint32_t>::max();
  auto robots = get_reachable_keys_per_robot(grid, pos, obtained_keys);
  for (size_t i = 0; i < pos.size(); ++i) {
    auto next_pos = pos;
    for (auto key : robots[i]) {
      auto nxt_collected_keys = obtained_keys;
      nxt_collected_keys[key.ch - 'a'] = true;
      next_pos[i] = key.pos;
      uint32_t distance =
          key.dst + get_keys(grid, next_pos, nxt_collected_keys, cache);
      out = distance < out ? distance : out;
    }
  }
  cache[cache_key] = out;
  return out;
}

Grid get_part2_grid(Grid grid) {
  position_t orig_pos = grid.entrances[0];
  grid.entrances.clear();
  grid.blocked_paths.insert(orig_pos);
  for (auto dir : directions) {
    grid.blocked_paths.insert(orig_pos + dir);
  }
  for (auto i : {-1, 1}) {
    for (auto j : {-1, 1}) {
      grid.entrances.push_back({orig_pos.first + i, orig_pos.second + j});
    }
  }
  return grid;
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/sample18.txt";
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  auto grid = parse_data(fh);
  std::map<std::pair<std::vector<position_t>, keyset_t>, uint32_t> cache;
  std::cout << "Part1: " << get_keys(grid, grid.entrances, {}, cache) << '\n';
  Grid p2_grid = get_part2_grid(grid);
  cache.clear();
  std::cout << "Part2: " << get_keys(p2_grid, p2_grid.entrances, {}, cache)
            << '\n';
  return 0;
}
