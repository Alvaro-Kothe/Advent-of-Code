#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_RULES 128
#define RULE_MAT_SIZE 5

typedef struct {
  int input_size;
  int input_pattern[8][RULE_MAT_SIZE][RULE_MAT_SIZE];
  int output[RULE_MAT_SIZE][RULE_MAT_SIZE];
  int output_size;
} Rule;

typedef struct {
  int size;
  int **data;
} Grid;

Grid create_grid(int size) {
  Grid grid;
  grid.size = size;
  grid.data = malloc(size * sizeof(int *));
  for (int i = 0; i < size; ++i) grid.data[i] = calloc(size, sizeof(int));
  return grid;
}

void free_grid(Grid *grid) {
  for (int i = 0; i < grid->size; ++i) free(grid->data[i]);
  free(grid->data);
}

Rule parse_line(char *str) {
  Rule result;
  char c;
  int i = 0;
  int j = 0;
  int parsing_input = 1;
  while ((c = *str++)) {
    if (c == '=' || c == '>') {
      parsing_input = 0;
      i = j = 0;
    } else if (c == '/') {
      if (parsing_input)
        result.input_size = j;
      else
        result.output_size = j;
      i++;
      j = 0;
    } else if (c == '#' || c == '.') {
      if (parsing_input)
        result.input_pattern[0][i][j] = c == '#';
      else
        result.output[i][j] = c == '#';
      j++;
    }
  }
  return result;
}

void rotate_clockwise(int dst[RULE_MAT_SIZE][RULE_MAT_SIZE],
                      int src[RULE_MAT_SIZE][RULE_MAT_SIZE], int size) {
  for (int i = 0; i < size; ++i)
    for (int j = 0; j < size; ++j) dst[j][size - i - 1] = src[i][j];
}

void flip_horizontal(int dst[RULE_MAT_SIZE][RULE_MAT_SIZE],
                     int src[RULE_MAT_SIZE][RULE_MAT_SIZE], int size) {
  for (int i = 0; i < size; ++i)
    for (int j = 0; j < size; ++j) dst[i][size - j - 1] = src[i][j];
}

void expand_rule(Rule *rule) {
  int i = 1;
  for (; i < 4; ++i)
    rotate_clockwise(rule->input_pattern[i], rule->input_pattern[i - 1],
                     rule->input_size);
  flip_horizontal(rule->input_pattern[i], rule->input_pattern[i - 1],
                  rule->input_size);
  i++;
  for (; i < 8; ++i)
    rotate_clockwise(rule->input_pattern[i], rule->input_pattern[i - 1],
                     rule->input_size);
}

int compare_grid(int a[RULE_MAT_SIZE][RULE_MAT_SIZE],
                 int b[RULE_MAT_SIZE][RULE_MAT_SIZE], int size) {
  for (int i = 0; i < size; ++i)
    for (int j = 0; j < size; ++j)
      if (a[i][j] != b[i][j]) return 0;
  return 1;
}

Grid apply_rule(Grid grid, const Rule rules[MAX_RULES], int nrules) {
  int block_size = 0;
  int new_size = 0;
  if (grid.size % 2 == 0) {
    block_size = 2;
    new_size = (grid.size / 2) * 3;
  } else if (grid.size % 3 == 0) {
    block_size = 3;
    new_size = (grid.size / 3) * 4;
  } else {
    printf("Unexpected grid size: %d\n", grid.size);
    exit(EXIT_FAILURE);
  }

  Grid new_grid = create_grid(new_size);

  for (int i = 0; i < grid.size; i += block_size) {
    for (int j = 0; j < grid.size; j += block_size) {
      int block[RULE_MAT_SIZE][RULE_MAT_SIZE];
      for (int k = 0; k < block_size; ++k)
        for (int l = 0; l < block_size; ++l)
          block[k][l] = grid.data[i + k][j + l];

      for (int k = 0; k < nrules; ++k) {
        Rule rule = rules[k];
        if (block_size != rule.input_size) continue;
        int match = 0;
        for (int rot = 0; rot < 8; ++rot) {
          if (compare_grid(block, rule.input_pattern[rot], block_size)) {
            match = 1;
            for (int ni = 0; ni < rule.output_size; ++ni) {
              int ioff = (i / block_size) * rule.output_size;
              for (int nj = 0; nj < rule.output_size; ++nj) {
                int joff = (j / block_size) * rule.output_size;
                new_grid.data[ioff + ni][joff + nj] = rule.output[ni][nj];
              }
            }
          }

          if (match) break;
        }

        if (match) break;
      }
    }
  }

  return new_grid;
}

void display(Grid grid) {
  for (int i = 0; i < grid.size; ++i) {
    for (int j = 0; j < grid.size; ++j) {
      char c = grid.data[i][j] ? '#' : '.';
      printf("%c", c);
    }
    printf("\n");
  }
}

int count_on(Grid grid) {
  int result = 0;
  for (int i = 0; i < grid.size; ++i)
    for (int j = 0; j < grid.size; ++j) result += grid.data[i][j];
  return result;
}

int main() {
  Rule rules[MAX_RULES];
  char buf[80];
  int nrules = 0;
  while (fgets(buf, sizeof(buf), stdin) != NULL) {
    Rule rule = parse_line(buf);
    rules[nrules++] = rule;
  }
  for (int i = 0; i < nrules; ++i) expand_rule(&rules[i]);

  // .#.
  // ..#
  // ###
  Grid grid = create_grid(3);
  grid.data[0][1] = 1;
  grid.data[1][2] = 1;
  for (int i = 0; i < 3; ++i) grid.data[2][i] = 1;

  int p1 = 0;
  for (int i = 0; i < 18; ++i) {
    grid = apply_rule(grid, rules, nrules);
    if (i == 5 - 1) p1 = count_on(grid);
  }

  printf("Part1: %d\n", p1);
  printf("Part2: %d\n", count_on(grid));
  free_grid(&grid);
  return 0;
}
