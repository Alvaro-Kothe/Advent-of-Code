#include <stdio.h>

int main() {
  char ch;
  int score = 0, depth = 0;
  int garbage = 0, ignore_next = 0;
  int cancel_count = 0;

  while ((ch = getchar()) != EOF) {
    if (ch == '\n') break;
    if (ignore_next) {
      ignore_next = 0;
      continue;
    }
    if (garbage) {
      if (ch == '!')
        ignore_next = 1;
      else if (ch == '>')
        garbage = 0;
      else
        cancel_count++;
    } else {
      if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        score += depth;
        depth--;
      } else if (ch == '<')
        garbage = 1;
    }
  }

  printf("Part1: %d\n", score);
  printf("Part2: %d\n", cancel_count);

  return 0;
}
