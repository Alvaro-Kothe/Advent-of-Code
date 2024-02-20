#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * Following the system from:
 * https://www.redblobgames.com/grids/hexagons/#coordinates-cube
 * The coordinates has a restraint that q + r + s = 0
 */
void move(int pos[], char* str) {
  if (strcmp(str, "n") == 0) {
    pos[1] -= 1;
    pos[2] += 1;
  } else if (strcmp(str, "ne") == 0) {
    pos[0] += 1;
    pos[1] -= 1;
  } else if (strcmp(str, "se") == 0) {
    pos[0] += 1;
    pos[2] -= 1;
  } else if (strcmp(str, "s") == 0) {
    pos[1] += 1;
    pos[2] -= 1;
  } else if (strcmp(str, "sw") == 0) {
    pos[0] -= 1;
    pos[1] += 1;
  } else if (strcmp(str, "nw") == 0) {
    pos[0] -= 1;
    pos[2] += 1;
  }
}

int cube_distance_origin(int pos[]) {
  int sum = 0;
  for (int i = 0; i < 3; ++i) sum += abs(pos[i]);
  return sum / 2;
}

int main() {
  int pos[3] = {0, 0, 0};
  char buf[3];
  char c;
  int max_dst = 0;
  while ((c = fgetc(stdin)) != EOF) {
    if (c == ',' || c == '\n') {
      move(pos, buf);
      buf[0] = '\0';
      int dst = cube_distance_origin(pos);
      if (dst > max_dst) max_dst = dst;
    } else
      strncat(buf, &c, 1);
  }
  move(pos, buf);

  printf("Part1: %d\n", cube_distance_origin(pos));
  printf("Part2: %d\n", max_dst);

  return 0;
}
