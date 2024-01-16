#pragma once
#include <utility>
template <typename T>
T power(T a, T b) {
  if (b == 0) return 1;
  return a * power(a, b - 1);
}

template <typename T, typename U>
std::pair<T, U> operator+(const std::pair<T, U> &l, const std::pair<T, U> &r) {
  return {l.first + r.first, l.second + r.second};
}
