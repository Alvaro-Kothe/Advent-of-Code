#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

#define MAX_SIZE 400

char grid[MAX_SIZE][MAX_SIZE];

void turn(int *dx, int *dy) {
  int temp = *dx;
  *dx = *dy;
  *dy = -temp;
}

// turn left or right
void change_direction(int x, int y, int *dx, int *dy) {
  for (int i = 0; i < 2; i++) {
    turn(dx, dy);
    int nx = x + *dx, ny = y + *dy;
    if (nx >= 0 && ny >= 0 && grid[nx][ny] != ' ' && grid[nx][ny] != '\0')
      return;
    turn(dx, dy);
  }
  printf("Invalid turn\n");
  exit(1);
}

int main() {
  int i = 0, j = 0;
  int x = 0, y = 0;
  int dx = 1, dy = 0;

  char c;
  while ((c = getchar()) != EOF) {
    switch (c) {
      case '\n':
        i++;
        j = 0;
        break;
      case '|':
        if (i == 0) y = j;
        grid[i][j] = c;
        j++;
        break;
      default:
        grid[i][j] = c;
        j++;
        break;
    }
  }

  char p1[80] = {0};
  int p1size = 0;
  int nsteps = 0;

  while (grid[x][y] != ' ' && grid[x][y] != '\0') {
    if (isalpha(grid[x][y])) p1[p1size++] = grid[x][y];
    if (grid[x][y] == '+') change_direction(x, y, &dx, &dy);
    x += dx;
    y += dy;
    nsteps++;
  }
  p1[p1size] = '\0';

  printf("Part1: %s\n", p1);
  printf("Part2: %d\n", nsteps);
  return 0;
}
