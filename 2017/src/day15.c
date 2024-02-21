#include <stdint.h>
#include <stdio.h>
#include <string.h>

uint64_t get_next_value(uint64_t value, uint64_t factor, uint64_t multiple_of) {
  uint64_t next_value = value * factor;
  next_value %= 2147483647;
  if (next_value % multiple_of == 0) return next_value;
  return get_next_value(next_value, factor, multiple_of);
}

int main() {
  uint64_t generator_original[] = {679, 771};
  uint64_t generators[2];
  memcpy(generators, generator_original, sizeof(generator_original));

  uint64_t factor[] = {16807, 48271};
  uint64_t multiple_of[] = {4, 8};
  uint64_t mask = 0xffff;

  int p1 = 0;
  for (int i = 0; i < 40000000; ++i) {
    for (int k = 0; k < 2; ++k)
      generators[k] = get_next_value(generators[k], factor[k], 1);

    if ((generators[0] & mask) == (generators[1] & mask)) p1++;
  }

  memcpy(generators, generator_original, sizeof(generator_original));
  int p2 = 0;
  for (int i = 0; i < 5000000; ++i) {
    for (int k = 0; k < 2; ++k)
      generators[k] = get_next_value(generators[k], factor[k], multiple_of[k]);

    if ((generators[0] & mask) == (generators[1] & mask)) p2++;
  }

  printf("Part1: %d\n", p1);
  printf("Part2: %d\n", p2);

  return 0;
}
