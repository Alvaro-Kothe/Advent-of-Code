#include <stdio.h>

#define MAX_LAYERS 100

int layers[MAX_LAYERS] = {0};
int last_layer = 0;

int caught(int time, int range) { return (time % (2 * (range - 1))) == 0; }

int main() {
  while (!feof(stdin)) {
    int depth, range;
    fscanf(stdin, "%d: %d", &depth, &range);
    layers[depth] = range;

    if (depth > last_layer) last_layer = depth;
  }

  int severity = 0;

  for (int packet = 0; packet <= last_layer; packet++) {
    if (layers[packet] > 0 && caught(packet, layers[packet]))
      severity += packet * layers[packet];
  }

  int delay = 1;
  int got_caught = 1;

  while (got_caught) {
    got_caught = 0;

    for (int packet = 0; packet <= last_layer; packet++) {
      if (layers[packet] > 0 && caught(packet + delay, layers[packet])) {
        got_caught = 1;
        break;
      }
    }
    if (got_caught) delay++;
  }

  printf("Part1: %d\n", severity);
  printf("Part1: %d\n", delay);

  return 0;
}
