#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "stdio.h"

#define LINE_LENGTH 128
#define MAX_BANKS 16

// Binary search tree node
typedef struct Node {
  int data[MAX_BANKS];
  struct Node *left;
  struct Node *right;
} Node;

Node *create_node(int data[MAX_BANKS]) {
  Node *temp = (Node *)malloc(sizeof(Node));
  memcpy(temp->data, data, sizeof(int) * MAX_BANKS);
  temp->left = temp->right = NULL;
  return temp;
}

bool insert_node(Node **node, int data[MAX_BANKS]) {
  if (*node == NULL) {
    *node = create_node(data);
    return true;
  }
  int cmp = memcmp(data, (*node)->data, sizeof(int) * MAX_BANKS);
  if (cmp == 0) {  // array already exists
    return false;
  } else if (cmp > 0) {
    return insert_node(&(*node)->right, data);
  } else {
    return insert_node(&(*node)->left, data);
  }
}

void delete(Node *root) {
  if (root == NULL) return;
  delete (root->left);
  delete (root->right);
  free(root);
}

int find_max_idx(const int array[], const int size) {
  int max_idx = 0;
  int max = array[0];
  for (int i = 1; i < size; ++i) {
    if (array[i] > max) {
      max = array[i];
      max_idx = i;
    }
  }
  return max_idx;
}

void reallocate_banks(int array[], const int size) {
  int cur_idx = find_max_idx(array, size);
  int tmp = array[cur_idx];
  array[cur_idx] = 0;
  while (tmp > 0) {
    cur_idx = (cur_idx + 1) % size;
    array[cur_idx]++;
    tmp--;
  }
}

int part1(int array[], int size) {
  Node *root = create_node(array);
  int steps = 0;
  for (;;) {
    reallocate_banks(array, size);
    steps++;
    if (!insert_node(&root, array)) {
      delete (root);
      return steps;
    }
  }
}

int part2(int array[], int size) {
  int steps = 0;
  int initial_array[MAX_BANKS];
  memcpy(initial_array, array, sizeof(int) * MAX_BANKS);
  while (memcmp(initial_array, array, sizeof(int) * MAX_BANKS) != 0 ||
         steps == 0) {
    steps++;
    reallocate_banks(array, size);
  }
  return steps;
}

int main() {
  int numbers[MAX_BANKS] = {0};
  int size = 0;

  char buf[LINE_LENGTH];
  char *saveptr;

  if (fgets(buf, sizeof(buf), stdin) != NULL) {
    char *token = strtok_r(buf, "\t", &saveptr);
    while (token != NULL) {
      int num = atoi(token);
      numbers[size++] = num;
      token = strtok_r(NULL, "\t", &saveptr);
    }
  }

  int p1 = part1(numbers, size);
  int p2 = part2(numbers, size);

  printf("Part1: %d\n", p1);
  printf("Part2: %d\n", p2);

  return 0;
}
