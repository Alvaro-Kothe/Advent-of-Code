#include <stdio.h>

#define MAX_PROGRAMS 2000
#define MAX_CONNECTIONS 20

typedef struct {
  int id;
  int connections[MAX_CONNECTIONS];
  int num_connections;
  int visited;
} Program;

Program programs[MAX_PROGRAMS];
int num_programs = 0;

void dfs(int program_id) {
  programs[program_id].visited = 1;

  for (int i = 0; i < programs[program_id].num_connections; i++) {
    int connected_program_id = programs[program_id].connections[i];
    if (!programs[connected_program_id].visited) {
      dfs(connected_program_id);
    }
  }
}

int main() {
  while (!feof(stdin)) {
    int program_id;
    fscanf(stdin, "%d <->", &program_id);

    programs[num_programs].id = program_id;
    programs[num_programs].visited = 0;

    while (fscanf(stdin, "%d",
                  &programs[num_programs]
                       .connections[programs[num_programs].num_connections]) !=
           EOF) {
      programs[num_programs].num_connections++;
      char c;
      fscanf(stdin, "%c", &c);
      if (c == '\n') break;
    }

    num_programs++;
  }

  dfs(0);

  int group_zero_size = 0;
  for (int i = 0; i < num_programs; ++i) {
    if (programs[i].visited) {
      group_zero_size++;
    }
  }

  int num_groups = 1;
  for (int i = 0; i < num_programs; ++i) {
    if (!programs[i].visited) {
      dfs(i);
      num_groups++;
    }
  }

  printf("Part1: %d\n", group_zero_size);
  printf("Part1: %d\n", num_groups);

  return 0;
}
