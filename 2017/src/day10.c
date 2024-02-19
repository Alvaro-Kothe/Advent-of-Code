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

int main() {
  char buf[128], line[128];
  int input_lengths[30];
  int il_size = 0;
  if (fgets(buf, sizeof(buf), stdin) != NULL) {
    strcpy(line, buf);
    char *token = strtok(buf, ",");
    while (token != NULL) {
      int num = atoi(token);
      input_lengths[il_size++] = num;
      token = strtok(NULL, ",");
    }
  }

  int size = 256;
  int array[size];
  for (int i = 0; i < size; ++i) {
    array[i] = i;
  }

  int skip_size = 0;
  int cur_pos = 0;

  for (int i = 0; i < il_size; ++i) {
    int len = input_lengths[i];
    reverse_window(array, size, cur_pos, cur_pos + len - 1);
    cur_pos += len + skip_size;
    cur_pos %= size;
    skip_size++;
  }

  int p1 = array[0] * array[1];

  // Part2
  int ascii_length[256];
  int al_size = 0;
  for (int i = 0; line[i] != '\0' && line[i] != '\n'; ++i) {
    ascii_length[al_size++] = (int)line[i];
  }

  int sequence_to_add[] = {17, 31, 73, 47, 23};
  for (int i = 0; i < 5; ++i) {
    ascii_length[al_size++] = sequence_to_add[i];
  }

  int sparse_hash[size];
  for (int i = 0; i < size; ++i) {
    sparse_hash[i] = i;
  }
  skip_size = 0;
  cur_pos = 0;

  for (int k = 0; k < 64; ++k) {
    for (int i = 0; i < al_size; ++i) {
      int len = ascii_length[i];
      reverse_window(sparse_hash, size, cur_pos, cur_pos + len - 1);
      cur_pos += len + skip_size;
      cur_pos %= size;
      skip_size++;
    }
  }

  int dense_hash[16];
  for (int i = 0; i < 16; ++i) {
    int result = 0;
    for (int j = 16 * i; j < 16 * (i + 1); ++j) result ^= sparse_hash[j];
    dense_hash[i] = result;
  }

  char hexstr[64];
  for (int i = 0; i < 16; ++i) {
    char temp[3];
    int2hexstr(dense_hash[i], temp);
    strcat(hexstr, temp);
  }

  printf("Part1: %d\n", p1);
  printf("Part2: %s\n", hexstr);

  return 0;
}
