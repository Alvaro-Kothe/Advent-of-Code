#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <iterator>
#include <numeric>
#include <ostream>
#include <stdexcept>
#include <string>
#include <vector>

__extension__ using int128_t = __int128;

enum technique_type { stack_t, cut_t, increment_t };
struct technique_t {
  technique_type type_t;
  int n;
};

std::vector<technique_t> parse_data(std::istream &fh) {
  std::vector<technique_t> out;
  std::string str;
  while (fh >> str) {
    technique_t technique;
    if (str == "cut") {
      technique.type_t = cut_t;
      fh >> technique.n;
    } else if (fh >> str; str == "with") {
      technique.type_t = increment_t;
      fh >> str;
      fh >> technique.n;
    } else {
      technique.type_t = stack_t;
      fh >> str >> str;
    }
    out.push_back(technique);
  }
  return out;
}

void apply_technique(std::vector<size_t> &deck, const technique_t technique) {
  switch (technique.type_t) {
    case stack_t:
      std::reverse(deck.begin(), deck.end());
      break;
    case cut_t:
      std::rotate(deck.begin(),
                  (technique.n > 0 ? deck.begin() : deck.end()) + technique.n,
                  deck.end());
      break;
    case increment_t:
      auto old_deck = deck;
      size_t i = 0;
      for (auto it : old_deck) {
        deck[i] = it;
        i = (i + technique.n) % old_deck.size();
      }
      break;
  }
}

size_t part1(const size_t deck_size,
             const std::vector<technique_t> techniques) {
  std::vector<size_t> deck(deck_size);
  std::iota(deck.begin(), deck.end(), 0u);
  for (auto technique : techniques) apply_technique(deck, technique);
  if (auto it_2019 = std::find(deck.begin(), deck.end(), 2019);
      it_2019 != deck.end())
    return std::distance(deck.begin(), it_2019);
  else
    throw std::runtime_error("Do better");
}

// https://stackoverflow.com/questions/43605542/how-to-find-modular-multiplicative-inverse-in-c#43605617
size_t modpower(int128_t base, size_t exp, const size_t m) {
  if (base <= 1 || exp <= 0 || m <= 0) return 1;
  size_t out = 1;
  while (exp > 0) {
    if (exp & 1) out = (out * base) % m;
    base = (base * base) % m;
    exp >>= 1;
  }
  return out;
}

uint64_t modinv(int128_t a, size_t b) { return modpower(a, b - 2, b); }

void apply_technique(int128_t &offset, int128_t &inc, const size_t deck_size,
                     const technique_t technique) {
  switch (technique.type_t) {
    case stack_t:
      inc = deck_size - inc;
      offset = (offset + inc) % deck_size;
      break;
    case cut_t:
      offset = (technique.n > 0
                    ? offset + technique.n * inc
                    : offset + ((technique.n + deck_size) * inc) % deck_size) %
               deck_size;
      break;
    case increment_t:
      // assume coprime
      inc = (modinv(technique.n, deck_size) * inc) % deck_size;
      break;
  }
}

size_t part2(const std::vector<technique_t> techniques) {
  static const uint64_t n_cards = 119315717514047ull;
  static const uint64_t n_shuffles = 101741582076661ull;
  int128_t offset = 0;
  int128_t inc = 1;
  for (auto technique : techniques) {
    apply_technique(offset, inc, n_cards, technique);
  }
  int128_t one_inc = inc;
  inc = modpower(inc, n_shuffles, n_cards);
  offset *= ((inc - 1) * modinv(one_inc - 1, n_cards)) % n_cards;
  offset %= n_cards;
  return (offset + inc * 2020) % n_cards;
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day22.txt";
  size_t deck_size = argc > 2 ? (size_t)argv[2] : 10007;
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  const auto techniques = parse_data(fh);
  std::cout << "Part1: " << part1(deck_size, techniques) << '\n';
  std::cout << "Part2: " << part2(techniques) << '\n';
  return 0;
}
