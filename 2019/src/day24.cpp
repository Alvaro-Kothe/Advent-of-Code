#include <array>
#include <cstddef>
#include <fstream>
#include <iostream>
#include <istream>
#include <map>
#include <numeric>
#include <ostream>
#include <set>
#include <stdexcept>
#include <string>

using bitmatrix = std::array<std::array<bool, 5>, 5>;
using rec_bitmatrix = std::map<int, bitmatrix>;

const bitmatrix empty_matrix{{false}};

bitmatrix parse_data(std::istream &fh) {
  bitmatrix matrix;
  int i = 0, j = 0;
  char ch;
  while (fh.get(ch)) {
    if (ch == '\n') {
      i++;
      j = 0;
      continue;
    } else if (ch == '.') {
      matrix[i][j] = false;
    } else if (ch == '#') {
      matrix[i][j] = true;
    }
    j++;
  }
  return matrix;
}

template <typename T>
int convolve_aux(const bitmatrix matrix, const T kernel, const size_t i,
                 const size_t j) {
  int result = 0;
  size_t offset = kernel.size() >> 1;
  for (size_t ki = 0; ki < kernel.size(); ++ki) {
    for (size_t kj = 0; kj < kernel.size(); ++kj) {
      result += (i + ki < offset || j + kj < offset || i + ki - offset >= 5 ||
                 j + kj - offset >= 5)
                    ? 0
                    : matrix[i + ki - offset][j + kj - offset] * kernel[ki][kj];
    }
  }
  return result;
}

void simulate_minute(bitmatrix &matrix) {
  static const std::array<std::array<int, 3>, 3> kernel{
      {{{0, 1, 0}}, {{1, 0, 1}}, {{0, 1, 0}}}};
  auto old_matrix = matrix;
  for (size_t i = 0; i < matrix.size(); ++i) {
    for (size_t j = 0; j < matrix[0].size(); ++j) {
      int adj_bugs = convolve_aux(old_matrix, kernel, i, j);
      if (old_matrix[i][j] && adj_bugs != 1)
        matrix[i][j] = false;
      else if (!old_matrix[i][j] && (adj_bugs == 1 || adj_bugs == 2))
        matrix[i][j] = true;
    }
  }
}

void display(const bitmatrix matrix) {
  for (int i = 0; i < 5; ++i) {
    for (int j = 0; j < 5; ++j) {
      char ch = matrix[i][j] ? '#' : '.';
      std::cout << ch;
    }
    std::cout << '\n';
  }
}

size_t bio_rating(const bitmatrix matrix) {
  size_t result = 0;
  size_t pow = 0;
  for (auto row : matrix) {
    for (bool is_bug : row) {
      result |= is_bug << pow;
      pow++;
    }
  }
  return result;
}

size_t part1(bitmatrix matrix) {
  std::set<bitmatrix> seen;
  for (;;) {
    if (seen.find(matrix) != seen.end())
      return bio_rating(matrix);
    seen.insert(matrix);
    simulate_minute(matrix);
  }
}

std::array<bool, 5> get_column(bitmatrix matrix, size_t column) {
  std::array<bool, 5> out;
  for (size_t i = 0; i < 5; ++i)
    out[i] = matrix[i][column];
  return out;
}

size_t get_bugs_within(const bitmatrix matrix, const size_t row,
                       const size_t column) {
  std::array<bool, 5> bugs;
  if (row == 3 && column == 2) // R: i = 3; j = 2
    bugs = matrix[4];
  else if (row == 1 && column == 2) // H: i = 1, j = 2
    bugs = matrix[0];
  else if (row == 2 && column == 1) // L: i = 2, j = 1
    bugs = get_column(matrix, 0);
  else if (row == 2 && column == 3) // N: i = 2, j = 3
    bugs = get_column(matrix, 4);
  else
    throw std::domain_error("Undefined behaviour");
  return std::reduce(bugs.begin(), bugs.end(), 0);
}

template <typename T>
int convolve_aux(rec_bitmatrix &matrix, const T kernel, const size_t i,
                 const size_t j, const int level) {
  // if go outside, start on the outer matrix (level - 1) from the center 2,2
  // if touches (2,2), go on the inside (level + 1) and look at the entire
  // respective row/column
  size_t offset = kernel.size() >> 1;
  int result = 0;
  for (size_t ki = 0; ki < kernel.size(); ++ki) {
    for (size_t kj = 0; kj < kernel.size(); ++kj) {
      result +=
          kernel[ki][kj] == 0 ? 0
          : (i + ki < offset || j + kj < offset || i + ki - offset >= 5 ||
             j + kj - offset >= 5) // border
              ? matrix[level - 1][2 + ki - offset][2 + kj - offset] *
                    kernel[ki][kj]
              : (i + ki - offset == 2 && j + kj - offset == 2) // middle
                    ? get_bugs_within(matrix[level + 1], i, j) * kernel[ki][kj]
                    : matrix[level][i + ki - offset][j + kj - offset] *
                          kernel[ki][kj];
    }
  }
  return result;
}

void simulate_minute(rec_bitmatrix &levels) {
  static const std::array<std::array<int, 3>, 3> kernel{
      {{{0, 1, 0}}, {{1, 0, 1}}, {{0, 1, 0}}}};
  auto it = levels.begin(); // map sorts the keys in increasing order
  int min_level = it->first;
  it = levels.end();
  it--;
  int max_level = it->first;
  levels.emplace(min_level - 1, empty_matrix);
  levels.emplace(max_level + 1, empty_matrix);
  auto old_levels = levels;
  for (auto &level : levels) {
    for (size_t i = 0; i < 5; ++i) {
      for (size_t j = 0; j < 5; ++j) {
        if (i == 2 && j == 2)
          continue;
        int adj_bugs = convolve_aux(old_levels, kernel, i, j, level.first);
        if (old_levels[level.first][i][j] && adj_bugs != 1)
          level.second[i][j] = false;
        else if (!old_levels[level.first][i][j] &&
                 (adj_bugs == 1 || adj_bugs == 2))
          level.second[i][j] = true;
      }
    }
  }
}
size_t part2(const bitmatrix matrix) {
  rec_bitmatrix levels;
  levels[0] = matrix;
  for (size_t i = 0; i < 200; ++i)
    simulate_minute(levels);
  size_t result = 0;
  for (auto level : levels)
    for (auto row : level.second)
      result += std::reduce(row.begin(), row.end(), 0);
  return result;
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day24.txt";
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  auto grid = parse_data(fh);
  std::cout << "Part1: " << part1(grid) << '\n';
  std::cout << "Part2: " << part2(grid) << '\n';
  return 0;
}
