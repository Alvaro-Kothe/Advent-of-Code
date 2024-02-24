#include <stdio.h>

#define MAX_COMPONENTS 100

typedef struct {
  int ports[2];
} Component;

Component components[MAX_COMPONENTS];
int ncomponents = 0;

int visited[MAX_COMPONENTS] = {0};

int find_max_strength(int connection) {
  int result = 0;

  for (int i = 0; i < ncomponents; ++i) {
    if (visited[i]) continue;

    for (int port_idx = 0; port_idx < 2; ++port_idx) {
      if (components[i].ports[port_idx] == connection) {
        visited[i] = 1;
        int strength = components[i].ports[0] + components[i].ports[1];
        int other_port = components[i].ports[(port_idx + 1) % 2];
        int path_str = strength + find_max_strength(other_port);
        if (path_str > result) result = path_str;
        visited[i] = 0;
        break;
      }
    }
  }
  return result;
}

void find_longest_path(int connection, int *path_len, int *path_strength) {
  int max_len = *path_len;
  int max_str = *path_strength;

  for (int i = 0; i < ncomponents; ++i) {
    if (visited[i]) continue;

    for (int port_idx = 0; port_idx < 2; ++port_idx) {
      if (components[i].ports[port_idx] == connection) {
        visited[i] = 1;
        int other_port = components[i].ports[(port_idx + 1) % 2];
        int this_path_len = *path_len + 1;
        int this_path_str =
            *path_strength + components[i].ports[0] + components[i].ports[1];
        find_longest_path(other_port, &this_path_len, &this_path_str);
        if (this_path_len > max_len) {
          max_len = this_path_len;
          max_str = this_path_str;
        } else if (this_path_len == max_len && this_path_str > max_str) {
          max_str = this_path_str;
        }
        visited[i] = 0;
        break;
      }
    }
  }
  *path_len = max_len;
  *path_strength = max_str;
}

int main() {
  while (!feof(stdin)) {
    fscanf(stdin, "%d/%d", &components[ncomponents].ports[0],
           &components[ncomponents].ports[1]);
    ncomponents++;
  }
  int p1 = find_max_strength(0);

  for (int i = 0; i < ncomponents; ++i) visited[i] = 0;

  int max_len = 0;
  int max_str = 0;

  find_longest_path(0, &max_len, &max_str);

  printf("Part1: %d\n", p1);
  printf("Part1: %d\n", max_str);
  return 0;
}
