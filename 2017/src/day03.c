#include <stdlib.h>

#include "stdio.h"

#define GRID_SIZE 1000

int compute_distance_spiral(int value) {
  if (value == 1) {
    return 0;
  }

  int ring = 0;    // diagonal steps taken
  int corner = 1;  // bottom right corner value
  while (corner * corner < value) {
    corner += 2;
    ring++;
  }
  // Backtrack corners until value is reached
  int nearest_corner = corner * corner;
  while (nearest_corner > value) {
    nearest_corner -= corner - 1;
  }

  // distance from the value to a center of side to move directly to 1.
  int distance_to_side_center =
      abs((nearest_corner + (corner - 1) / 2) - value);
  int result = ring + distance_to_side_center;
  return result;
}

int sum_neighbors(int grid[GRID_SIZE][GRID_SIZE], int x, int y) {
  int dx[] = {1, 1, 0, -1, -1, -1, 0, 1};
  int dy[] = {0, 1, 1, 1, 0, -1, -1, -1};
  int sum = 0;
  for (size_t i = 0; i < 8; ++i) sum += grid[x + dx[i]][y + dy[i]];
  return sum;
}

int part2(int value) {
  int grid[GRID_SIZE][GRID_SIZE] = {0};
  int x = GRID_SIZE / 2;
  int y = GRID_SIZE / 2;
  grid[x][y] = 1;

  int current_value = 0;
  int ring = 1;

  for (;;) {
    x++;
    current_value = sum_neighbors(grid, x, y);
    if (current_value > value) {
      return current_value;
    }
    grid[x][y] = current_value;
    // move directions (up, left, down, right)
    int dx[] = {0, -1, 0, 1};
    int dy[] = {-1, 0, 1, 0};

    for (size_t i = 0; i < 4; ++i) {
      size_t move_len = i == 0 ? 2 * ring - 1 : 2 * ring;
      for (size_t j = 0; j < move_len; ++j) {
        x += dx[i];
        y += dy[i];
        current_value = sum_neighbors(grid, x, y);
        if (current_value > value) {
          return current_value;
        }
        grid[x][y] = current_value;
      }
    }
    ring++;
  }
}

int main() {
  int input;
  scanf("%d", &input);

  int p1 = compute_distance_spiral(input);

  printf("Part1: %d\n", p1);
  printf("Part2: %d\n", part2(input));

  return 0;
}
