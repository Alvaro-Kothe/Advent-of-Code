#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "stdio.h"

bool is_anagram(char *str1, char *str2) {
  int count1[256] = {0};
  int count2[256] = {0};
  int i;

  for (i = 0; str1[i] && str2[i]; ++i) {
    count1[(unsigned char)str1[i]]++;
    count2[(unsigned char)str2[i]]++;
  }

  if (str1[i] || str2[i]) return false;

  for (i = 0; i < 256; ++i)
    if (count1[i] != count2[i]) return false;

  return true;
}

bool is_password_valid(char *passphrase, int *is_anagram_flag) {
  char *words[100];
  int nwords = 0;

  char *token = strtok(passphrase, " ");

  while (token != NULL) {
    words[nwords++] = token;
    token = strtok(NULL, " ");
  }

  for (int i = 0; i < nwords; ++i) {
    for (int j = i + 1; j < nwords; ++j) {
      if (strcmp(words[i], words[j]) == 0) {
        return false;
      }
      if (is_anagram(words[i], words[j])) *is_anagram_flag = 1;
    }
  }
  return true;
}

int main() {
  char passphrase[1024];
  int valid_passwords = 0;
  int valid_passwords_with_anagram = 0;

  while (fgets(passphrase, sizeof(passphrase), stdin) != NULL) {
    // remove newline
    passphrase[strcspn(passphrase, "\n")] = 0;
    int is_anagram_flag = 0;
    if (is_password_valid(passphrase, &is_anagram_flag)) {
      valid_passwords++;
      if (!is_anagram_flag) {
        valid_passwords_with_anagram++;
      }
    }
  }

  printf("Part1: %d\n", valid_passwords);
  printf("Part2: %d\n", valid_passwords_with_anagram);

  return 0;
}
