#include <array>
#include <cassert>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <numeric>
#include <ostream>
#include <stdexcept>
#include <string>
#include <vector>

using vecint_t = std::vector<uint64_t>;
vecint_t str_to_vec(std::string str) {
  vecint_t out;
  for (char ch : str) {
    out.push_back(ch - '0');
  }
  return out;
}

vecint_t parse_data(std::istream &fh) {
  vecint_t out;
  char ch;
  while (fh >> ch) {
    out.push_back(ch - '0');
  }
  return out;
}

int get_pattern(uint32_t idx, uint32_t n_repeat) {
  static std::array<int, 4> pattern = {0, 1, 0, -1};
  n_repeat++;
  idx %= pattern.size() * n_repeat;
  for (uint32_t i = 0; i < pattern.size(); ++i) {
    if (idx < (i + 1) * n_repeat)
      return pattern[i];
  }
  throw std::runtime_error("Bug");
}

int compute_new_index(vecint_t digits, uint32_t idx) {
  int sum = 0;
  for (uint32_t i = 0; i < digits.size(); ++i) {
    sum += digits[i] * get_pattern(i + 1, idx);
  }
  return std::abs(sum) % 10;
}

vecint_t apply_phase(const vecint_t digits) {
  vecint_t new_phase = digits;
  for (uint32_t i = 0; i < digits.size(); ++i) {
    new_phase[i] = compute_new_index(digits, i);
  }
  return new_phase;
}

uint32_t extract_digits(const vecint_t digits, uint32_t n,
                        uint64_t offset = 0) {
  uint32_t pow = 1, sum = 0;
  while (n > 0) {
    n--;
    sum += pow * digits[offset + n];
    pow *= 10;
  }
  return sum;
}

uint64_t part2(vecint_t digits) {
  const uint32_t offset = extract_digits(digits, 7);
  // https://stackoverflow.com/questions/49921880/repeat-elements-in-a-vector
  const uint32_t nrepeat = 10000;
  digits.reserve(digits.size() * nrepeat);
  auto end = digits.end();
  for (uint32_t i = 1; i < nrepeat; ++i)
    digits.insert(digits.end(), digits.begin(), end);
  assert(offset < digits.size());
  digits.erase(digits.begin(), digits.begin() + offset);
  for (int i = 0; i < 100; ++i) {
    int64_t partial_sum = std::reduce(digits.begin(), digits.end(), 0ull);
    for (auto it = digits.begin(); it != digits.end(); ++it) {
      auto digit = *it;
      *it = std::abs(partial_sum % 10);
      partial_sum -= digit;
    }
  }
  return extract_digits(digits, 8);
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day16.txt";
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  const auto digits = parse_data(fh);
  auto p1_digits = digits;
  for (int i = 0; i < 100; ++i)
    p1_digits = apply_phase(p1_digits);
  std::cout << "Part1: " << extract_digits(p1_digits, 8) << std::endl;
  std::cout << "Part2: " << part2(digits) << std::endl;
  return 0;
}
