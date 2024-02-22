#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_COMMANDS 10000
#define MAX_BUCKETS 10000

typedef struct Node {
  int key[16];
  int value;
  struct Node *next;
} Node;

typedef struct {
  Node *head;
} HashtableEntry;

typedef struct {
  HashtableEntry table[MAX_BUCKETS];
} Hashtable;

uint32_t hash(int *str, int size) {
  uint32_t hash = 5381;
  int c;

  int i = 0;
  while (i < size && (c = *str++)) {
    hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
    i++;
  }

  return hash;
}

// Insert entry in hashtable, if entry is repeated, replace and return old
// entry.
Node *insert(Hashtable *ht, int *key, int size, int value) {
  uint32_t index = hash(key, size) % MAX_BUCKETS;
  Node *new_node = (Node *)malloc(sizeof(Node));
  memcpy(new_node->key, key, sizeof(int) * size);
  new_node->value = value;
  new_node->next = NULL;

  if (ht->table[index].head == NULL) {
    ht->table[index].head = new_node;
  } else {
    Node *temp = ht->table[index].head;
    while (temp->next != NULL) {
      if (memcmp(key, temp->key, sizeof(int) * size) == 0) {
        new_node->next = temp->next;
        return temp;
      }
      temp = temp->next;
    }
    temp->next = new_node;
  }
  return NULL;
}

void free_ht(Hashtable *ht) {
  for (int i = 0; i < MAX_BUCKETS; i++) {
    Node *temp = ht->table[i].head;
    while (temp != NULL) {
      Node *next = temp->next;
      free(temp);
      temp = next;
    }
  }
}

void rotate(int arr[], int size, int n) {
  if (n < 0) n = size - (n % size);

  int *temp = (int *)malloc(sizeof(int) * size);
  for (int i = 0; i < size; ++i) {
    temp[(i + n) % size] = arr[i];
  }
  memcpy(arr, temp, sizeof(int) * size);
  free(temp);
}

void exchange(int arr[], int pos1, int pos2) {
  int temp = arr[pos1];
  arr[pos1] = arr[pos2];
  arr[pos2] = temp;
}

void partner(int arr[], int size, char name1, char name2) {
  int pos1 = -1;
  int pos2 = -1;
  for (int i = 0; i < size; ++i) {
    if (pos1 > 0 && pos2 > 0) break;
    if (arr[i] == name1) pos1 = i;
    if (arr[i] == name2) pos2 = i;
  }
  exchange(arr, pos1, pos2);
}

void match(char *str, int arr[], int size) {
  char name1, name2;
  int pos1, pos2, spin_size;
  if (sscanf(str, "s%d", &spin_size) == 1)
    rotate(arr, size, spin_size);
  else if (sscanf(str, "x%d/%d", &pos1, &pos2) == 2)
    exchange(arr, pos1, pos2);
  else if (sscanf(str, "p%c/%c", &name1, &name2) == 2)
    partner(arr, size, name1, name2);
}

void print_programs(int arr[], int size) {
  for (int i = 0; i < size; i++) {
    printf("%c", arr[i]);
  }
  printf("\n");
}

int main() {
  int programs[] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
                    'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p'};
  char commands[MAX_COMMANDS][16];
  int ncommands = 0;
  int size = sizeof(programs) / sizeof(programs[0]);
  char buf[16] = {0};
  char c;
  while ((c = fgetc(stdin)) != EOF) {
    if (c == ',' || c == '\n') {
      strcpy(commands[ncommands++], buf);
      buf[0] = '\0';
    } else
      strncat(buf, &c, 1);
  }
  if (buf[0] != '\0') {
    strcpy(commands[ncommands++], buf);
  }

  for (int i = 0; i < ncommands; ++i) match(commands[i], programs, size);
  printf("Part1: ");
  print_programs(programs, size);

  int ndances = 1;
  Hashtable ht = {NULL};

  int niter = 1000000000;
  for (; ndances < niter; ndances++) {
    Node *prev_entry = insert(&ht, programs, size, ndances);
    if (prev_entry != NULL &&
        (niter - ndances) % (ndances - prev_entry->value) == 0) {
      break;
    }

    for (int i = 0; i < ncommands; ++i) match(commands[i], programs, size);
  }

  printf("Part2: ");
  print_programs(programs, size);

  free_ht(&ht);

  return 0;
}
