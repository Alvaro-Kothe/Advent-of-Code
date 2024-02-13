#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "stdio.h"

typedef struct {
  int *data;
  size_t size;
  size_t capacity;
} Vec_t;

typedef struct {
  Vec_t *data;
  size_t size;
  size_t capacity;
} VecVec_t;

VecVec_t *vecvec_new() {
  VecVec_t *vec = malloc(sizeof(VecVec_t));
  vec->capacity = 4;
  vec->data = malloc(sizeof(Vec_t) * vec->capacity);
  vec->size = 0;
  if (vec->data == NULL) {
    perror("malloc error");
    exit(EXIT_FAILURE);
  }
  return vec;
}

Vec_t *vec_new() {
  Vec_t *vec = malloc(sizeof(Vec_t));
  vec->capacity = 4;
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
    vector->capacity <<= 1;
    vector->data = realloc(vector->data, vector->capacity * sizeof(int));
    if (vector->data == NULL) {
      perror("Failed to  reallocate memory for vector");
      exit(EXIT_FAILURE);
    }
  }
  vector->data[vector->size++] = value;
}

void push_back_vector(VecVec_t *vector_vector, Vec_t *vector) {
  if (vector_vector->size >= vector_vector->capacity) {
    vector_vector->capacity <<= 1;
    vector_vector->data = realloc(vector_vector->data,
                                  vector_vector->capacity * sizeof(VecVec_t));
    if (vector_vector->data == NULL) {
      perror("Failed to reallocate memory for nested vector");
      exit(EXIT_FAILURE);
    }
  }
  vector_vector->data[vector_vector->size++] = *vector;
}

void free_nested(VecVec_t *nested_vector) {
  for (size_t i = 0; i < nested_vector->size; ++i) {
    free(nested_vector->data[i].data);
  }
  free(nested_vector->data);
  free(nested_vector);
}

VecVec_t *parse_data() {
  VecVec_t *result = vecvec_new();

  char *line = NULL;
  size_t len = 0;
  ssize_t read;
  char *saveptr;

  while ((read = getline(&line, &len, stdin)) != -1) {
    Vec_t *vector = vec_new();

    char *token = strtok_r(line, "\t", &saveptr);
    while (token != NULL) {
      int num = atoi(token);
      printf("%d\n", num);
      push_back(vector, num);
      token = strtok_r(NULL, "\t", &saveptr);
    }

    push_back_vector(result, vector);
  }

  return result;
}

int part1(const VecVec_t *data) {
  int sum = 0;
  for (size_t i = 0; i < data->size; ++i) {
    const Vec_t vec = data->data[i];
    int min = vec.data[0], max = vec.data[0];
    for (size_t j = 0; j < vec.size; ++j) {
      if (vec.data[j] < min) {
        min = vec.data[j];
      }
      if (vec.data[j] > max) {
        max = vec.data[j];
      }
    }
    sum += max - min;
  }
  return sum;
}

int evenly_divide(int x, int y) {
  if (x > y && x % y == 0) {
    return x / y;
  } else if (y > x && y % x == 0) {
    return y / x;
  }
  return 0;
}

int part2(const VecVec_t *data) {
  int sum = 0;
  for (size_t i = 0; i < data->size; ++i) {
    const Vec_t vec = data->data[i];
    for (size_t j = 0; j < vec.size; ++j) {
      bool found = false;
      for (size_t k = j + 1; k < vec.size; ++k) {
        int div = evenly_divide(vec.data[j], vec.data[k]);
        if (div > 0) {
          sum += div;
          found = true;
          break;
        }
      }
      if (found) {
        break;
      }
    }
  }
  return sum;
}

int main() {
  VecVec_t *data = parse_data();

  int p1 = part1(data);
  int p2 = part2(data);
  printf("Part1: %d\n", p1);
  printf("Part2: %d\n", p2);

  free_nested(data);
  return 0;
}
