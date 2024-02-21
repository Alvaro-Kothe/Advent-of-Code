#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void reverse_window(int array[], int size, int start, int end) {
  while (start < end) {
    int temp = array[start % size];
    array[start % size] = array[end % size];
    array[end % size] = temp;
    start++;
    end--;
  }
}

void int2hexstr(int num, char *str) { sprintf(str, "%02x", num); }

void hash_aux(int array[], int size, int *cur_pos, int *skip_size, int len) {
  reverse_window(array, size, *cur_pos, *cur_pos + len - 1);
  *cur_pos += len + *skip_size;
  *cur_pos %= size;
  *skip_size += 1;
}

const char *knothash(char *str) {
  int sequence_to_add[] = {17, 31, 73, 47, 23};

  int size = 256;
  int sparse_hash[size];
  for (int i = 0; i < size; ++i) {
    sparse_hash[i] = i;
  }
  int skip_size = 0, cur_pos = 0;

  for (int k = 0; k < 64; ++k) {
    char *cur = str;
    int c;
    while ((c = *cur++)) {
      hash_aux(sparse_hash, size, &cur_pos, &skip_size, c);
    }
    for (int i = 0; i < 5; ++i)
      hash_aux(sparse_hash, size, &cur_pos, &skip_size, sequence_to_add[i]);
  }

  int dense_hash[16];
  for (int i = 0; i < 16; ++i) {
    int result = 0;
    for (int j = 16 * i; j < 16 * (i + 1); ++j) result ^= sparse_hash[j];
    dense_hash[i] = result;
  }

  char *hexstr = malloc(sizeof(char) * 64);
  for (int i = 0; i < 16; ++i) {
    char temp[3];
    int2hexstr(dense_hash[i], temp);
    strcat(hexstr, temp);
  }
  return hexstr;
}

int hex2int(char ch) {
  if (ch >= '0' && ch <= '9') return ch - '0';
  if (ch >= 'A' && ch <= 'F') return ch - 'A' + 10;
  if (ch >= 'a' && ch <= 'f') return ch - 'a' + 10;
  return -1;
}

int grid[128][128] = {0};
int visited[128][128] = {0};

void dfs(int i, int j) {
  if (visited[i][j] || !grid[i][j]) return;
  visited[i][j] = 1;
  for (int di = -1; di <= 1; di++)
    for (int dj = -1; dj <= 1; dj++) {
      int ni = i + di, nj = j + dj;
      int s = abs(di) + abs(dj);
      int is_cross = s == 0 || s > 1;  // is diagonal or is center
      if (ni >= 0 && ni < 128 && nj >= 0 && nj < 128 && !is_cross &&
          !visited[ni][nj] && grid[ni][nj])
        dfs(ni, nj);
    }
}

int main() {
  char buf[32];
  if (fgets(buf, sizeof(buf), stdin) == NULL) {
    return EXIT_FAILURE;
  }
  buf[strcspn(buf, "\n")] = 0;

  for (int i = 0; i < 128; ++i) {
    char key[64];
    sprintf(key, "%s-%d", buf, i);
    const char *hash = knothash(key);
    char c;
    int j = 0;
    while ((c = *hash++)) {
      int val = hex2int(c);
      for (int k = 3; k >= 0; --k, j++) grid[i][j] = (val >> k) & 1;
    }
  }

  int used_squares = 0;
  int regions = 0;
  for (int i = 0; i < 128; ++i)
    for (int j = 0; j < 128; ++j) {
      used_squares += grid[i][j];
      if (grid[i][j] && !visited[i][j]) {
        regions++;
        dfs(i, j);
      }
    }

  printf("Part1: %d\n", used_squares);
  printf("Part2: %d\n", regions);

  return 0;
}
