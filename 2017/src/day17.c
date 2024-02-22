#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  int *data;
  size_t size;
  size_t capacity;
} Vec_t;

Vec_t *vec_new(int capacity) {
  Vec_t *vec = malloc(sizeof(Vec_t));
  vec->capacity = capacity;
  vec->size = 0;
  vec->data = malloc(sizeof(int) * vec->capacity);
  if (vec->data == NULL) {
    perror("malloc error");
    exit(EXIT_FAILURE);
  }
  return vec;
}

void push_back(Vec_t *vector, int value) {
  if (vector->size >= vector->capacity) {
    vector->capacity *= 2;
    vector->data = realloc(vector->data, vector->capacity * sizeof(int));
    if (vector->data == NULL) {
      perror("Failed to  reallocate memory for vector");
      exit(EXIT_FAILURE);
    }
  }
  vector->data[vector->size++] = value;
}

void rotate(Vec_t *vec, int n) {
  if (n < 0) {
    n = -n;
    n %= vec->size;
    n = vec->size - n;
  }
  n %= vec->size;

  int *temp = malloc(sizeof(int) * vec->capacity);
  for (size_t i = 0; i < vec->size; ++i) {
    temp[(i + n) % vec->size] = vec->data[i];
  }
  free(vec->data);
  vec->data = temp;
}

void display(Vec_t *vec) {
  for (size_t i = 0; i < vec->size; ++i) printf("%d ", vec->data[i]);
  printf("\n");
}

int main() {
  int insertion_steps = -1;
  scanf("%d", &insertion_steps);
  if (insertion_steps < 0) return EXIT_FAILURE;

  Vec_t *vec = vec_new(2018);

  push_back(vec, 0);
  for (int i = 1; i < 2018; ++i) {
    rotate(vec, -insertion_steps);
    push_back(vec, i);
  }

  size_t pos_2017 = 0;
  for (; pos_2017 < vec->size; ++pos_2017)
    if (vec->data[pos_2017] == 2017) break;

  int p1 = vec->data[(pos_2017 + 1) % vec->size];

  printf("Part1: %d\n", p1);

  free(vec->data);
  free(vec);

  int p2 = 0;
  int insertions = 50000000;
  int cur_pos = 0;
  for (int i = 1; i <= insertions; ++i) {
    cur_pos += insertion_steps;
    cur_pos %= i;
    cur_pos++;
    if (cur_pos == 1) p2 = i;
  }

  printf("Part2: %d\n", p2);

  return 0;
}
