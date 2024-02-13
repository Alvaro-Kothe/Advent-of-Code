#include <stdlib.h>

#include "stdio.h"

int part1(int *digits, size_t size) {
  int sum = 0;
  int prev_digit = 0;
  for (size_t i = 0; i <= size; ++i) {
    if (digits[i % size] == prev_digit) {
      sum += prev_digit;
    }
    prev_digit = digits[i];
  }
  return sum;
}

int part2(int *digits, size_t size) {
  size_t ahead = size / 2;
  int sum = 0;
  for (size_t i = 0; i < size; ++i) {
    int cur_digit = digits[i % size];
    if (cur_digit == digits[(i + ahead) % size]) {
      sum += cur_digit;
    }
  }
  return sum;
}

int main() {
  char digit;
  size_t capacity = 4;
  size_t size = 0;
  int *digits = malloc(sizeof(int) * capacity);
  while ((digit = getchar()) != EOF) {
    int cur_digit = digit - '0';

    if (cur_digit < 0 || cur_digit > 9) {
      continue;
    }

    if (size >= capacity) {
      capacity <<= 1;
      int *temp = realloc(digits, capacity * sizeof(int));
      if (temp == NULL) {
        printf("ERROR: realloc failed\n");
        exit(1);
      }
      digits = temp;
    }

    digits[size++] = cur_digit;
  }

  int p1 = part1(digits, size);
  int p2 = part2(digits, size);
  printf("Part1: %d\n", p1);
  printf("Part2: %d\n", p2);

  free(digits);
  return 0;
}
