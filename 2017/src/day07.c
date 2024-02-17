#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Program {
  char name[16];
  int weigth;
  char children[10][16];
  int nchildren;
} Program;

void add_child(Program *parent, char *name) {
  strcpy(parent->children[parent->nchildren++], name);
}

Program *parse_line(char *line) {
  Program *node = (Program *)malloc(sizeof(Program));
  sscanf(line, "%s (%d)", node->name, &node->weigth);
  node->nchildren = 0;

  char *token = strtok(line, ">");
  token = strtok(NULL, ">");

  token = strtok(token, ", ");
  while (token != NULL) {
    add_child(node, token);
    token = strtok(NULL, ", ");
  }
  return node;
}

int find_root(Program *programs, int size) {
  for (int i = 0; i < size; ++i) {
    int is_root = 1;
    for (int j = 0; j < size; ++j) {
      if (i == j) continue;

      for (int k = 0; k < programs[j].nchildren; ++k) {
        if (strcmp(programs[i].name, programs[j].children[k]) == 0) {
          is_root = 0;
          break;
        }
      }

      if (!is_root) break;
    }
    if (is_root) return i;
  }
  return -1;
}

int find_program(char *name, Program *programs, int size) {
  for (int i = 0; i < size; i++) {
    if (strcmp(programs[i].name, name) == 0) {
      return i;
    }
  }
  return -1;
}

int compute_weights(Program *programs, int idx, int *weigths, int size) {
  if (weigths[idx] > 0) return weigths[idx];
  int total_weight = programs[idx].weigth;
  for (int k = 0; k < programs[idx].nchildren; ++k)
    total_weight += compute_weights(
        programs, find_program(programs[idx].children[k], programs, size),
        weigths, size);
  weigths[idx] = total_weight;
  return total_weight;
}

// Explore child until don't see any difference. Get the parent of the last
// difference.
int find_imbalance(Program *programs, int *weigths, int size, int parent_idx) {
  int child_weights[10];
  int child_idx[10];
  for (int k = 0; k < programs[parent_idx].nchildren; ++k) {
    int idx = find_program(programs[parent_idx].children[k], programs, size);
    child_idx[k] = idx;
    child_weights[k] = compute_weights(programs, idx, weigths, size);
  }
  int max_dif = 0;
  int max_dif_idx = -1;
  for (int i = 0; i < programs[parent_idx].nchildren; ++i) {
    int ndif = 0;
    for (int j = 0; j < programs[parent_idx].nchildren; ++j) {
      if (child_weights[i] != child_weights[j]) {
        ndif++;
      }
    }
    if (ndif > max_dif) {
      max_dif = ndif;
      max_dif_idx = i;
    }
  }
  if (max_dif == 0) return -1;
  int parent_idx_rec =
      find_imbalance(programs, weigths, size, child_idx[max_dif_idx]);
  return parent_idx_rec >= 0 ? parent_idx_rec : parent_idx;
}

int fix_imbalance(Program *programs, int *weigths, int size, int idx) {
  int child_weights[10];
  int child_idx[10];
  for (int k = 0; k < programs[idx].nchildren; ++k) {
    int idx_child = find_program(programs[idx].children[k], programs, size);
    child_idx[k] = idx_child;
    child_weights[k] = compute_weights(programs, idx_child, weigths, size);
  }
  int max_dif = 0;
  int max_dif_idx = -1;
  for (int i = 0; i < programs[idx].nchildren; ++i) {
    int ndif = 0;
    for (int j = 0; j < programs[idx].nchildren; ++j) {
      if (child_weights[i] != child_weights[j]) {
        ndif++;
      }
    }
    if (ndif > max_dif) {
      max_dif = ndif;
      max_dif_idx = i;
    }
  }
  int max_dif_single_weight = programs[child_idx[max_dif_idx]].weigth;
  for (int i = 0; i < programs[idx].nchildren; ++i) {
    if (i == max_dif_idx) continue;
    int weight_dif = child_weights[max_dif_idx] - child_weights[i];
    return max_dif_single_weight - weight_dif;
  }
  return -1;
}

int main() {
  Program nodes[2048];
  int total_weights[2048] = {0};
  int size = 0;
  char buf[100];

  while (fgets(buf, sizeof(buf), stdin) != NULL) {
    buf[strcspn(buf, "\n")] = 0;
    nodes[size++] = *parse_line(buf);
  }

  int root_idx = find_root(nodes, size);
  int imbalance_parent = find_imbalance(nodes, total_weights, size, root_idx);
  int p2 = fix_imbalance(nodes, total_weights, size, imbalance_parent);

  printf("Part1: %s\n", nodes[root_idx].name);
  printf("Part2: %d\n", p2);

  return 0;
}
