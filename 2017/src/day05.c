#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "stdio.h"

int run_instructions(int numbers[], int size, int part2) {
  int steps = 0;
  int cur_idx = 0;
  while (cur_idx >= 0 && cur_idx < size) {
    int offset = numbers[cur_idx];
    int next_idx = cur_idx + offset;
    if (part2 && offset >= 3) {
      numbers[cur_idx]--;
    } else {
      numbers[cur_idx]++;
    }
    cur_idx = next_idx;
    steps++;
  }
  return steps;
}

int main() {
  int instructions[2048] = {0};
  int size = 0;

  char buf[80];

  while (fgets(buf, sizeof(buf), stdin) != NULL) {
    instructions[size++] = atoi(buf);
  }

  int inst_copy[2048];
  memcpy(inst_copy, instructions, sizeof(instructions));

  int p1 = run_instructions(inst_copy, size, 0);
  int p2 = run_instructions(instructions, size, 1);

  printf("Part1: %d\n", p1);
  printf("Part2: %d\n", p2);

  return 0;
}
