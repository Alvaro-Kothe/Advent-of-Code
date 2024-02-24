#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_COMMANDS 10000
#define MAX_BUCKETS 10000

typedef enum NodeState { Clean, Weakened, Infected, Flagged } NodeState;

uint32_t hash(int point[2]) {
  uint32_t hash = 5381;

  for (int i = 0; i < 2; ++i) {
    hash = ((hash << 5) + hash) + point[i]; /* hash * 33 + c */
  }

  return hash;
}

typedef struct Node {
  int key[2];
  enum NodeState value;
  struct Node *next;
} Node;

typedef struct {
  Node *head;
} HashtableEntry;

typedef struct {
  HashtableEntry table[MAX_BUCKETS];
} Hashtable;

Node *insert(Hashtable *ht, int key[2], int value) {
  uint32_t index = hash(key) % MAX_BUCKETS;
  Node *new_node = (Node *)malloc(sizeof(Node));
  memcpy(new_node->key, key, sizeof(int) * 2);
  new_node->value = value;
  new_node->next = NULL;

  if (ht->table[index].head == NULL) {
    ht->table[index].head = new_node;
  } else {
    Node *temp = ht->table[index].head;
    while (temp->next != NULL) {
      if (memcmp(key, temp->key, sizeof(int) * 2) == 0) {
        new_node->next = temp->next;
        return temp;
      }
      temp = temp->next;
    }
    temp->next = new_node;
  }
  return NULL;
}

Node *search(Hashtable *ht, int key[2]) {
  uint32_t index = hash(key) % MAX_BUCKETS;
  if (ht->table[index].head == NULL) {
    return NULL;
  }
  Node *temp = ht->table[index].head;
  while (temp != NULL) {
    if (memcmp(key, temp->key, sizeof(int) * 2) == 0) return temp;

    temp = temp->next;
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

void turn_right(int *dx, int *dy) {
  int tmp = *dx;
  *dx = *dy;
  *dy = -tmp;
}

void turn_left(int *dx, int *dy) {
  int tmp = *dx;
  *dx = -*dy;
  *dy = tmp;
}

void reverse_direction(int *dx, int *dy) {
  *dx = -*dx;
  *dy = -*dy;
}

/**
 * Returns the value left at the node;
 */
int burst(Hashtable *ht, int *x, int *y, int *dx, int *dy) {
  int cur_pos[] = {*x, *y};
  Node *cur_node = search(ht, cur_pos);
  NodeState cur_state = cur_node == NULL ? Clean : cur_node->value;

  NodeState new_state = Clean;
  if (cur_state == Infected) {
    turn_right(dx, dy);
    new_state = Clean;
  } else {
    turn_left(dx, dy);
    new_state = Infected;
  }

  if (cur_node == NULL)
    insert(ht, cur_pos, new_state);
  else
    cur_node->value = new_state;

  *x += *dx;
  *y += *dy;
  return new_state;
}

int burst_evolved(Hashtable *ht, int *x, int *y, int *dx, int *dy) {
  int cur_pos[] = {*x, *y};
  Node *cur_node = search(ht, cur_pos);
  NodeState cur_state = cur_node == NULL ? Clean : cur_node->value;

  NodeState new_state = Clean;
  switch (cur_state) {
    case Clean:
      turn_left(dx, dy);
      new_state = Weakened;
      break;
    case Weakened:
      new_state = Infected;
      break;
    case Infected:
      turn_right(dx, dy);
      new_state = Flagged;
      break;
    case Flagged:
      reverse_direction(dx, dy);
      new_state = Clean;
      break;
  }

  if (cur_node == NULL)
    insert(ht, cur_pos, new_state);
  else
    cur_node->value = new_state;

  *x += *dx;
  *y += *dy;
  return new_state;
}

int main() {
  Hashtable ht1 = {NULL};
  Hashtable ht2 = {NULL};
  char c;
  int i = 0, j = 0;
  int lasti, lastj;
  while ((c = fgetc(stdin)) != EOF) {
    switch (c) {
      case '\n':
        j = 0;
        i++;
        break;
      case '.':
      case '#':;
        if (c == '#') {
          int point[2] = {i, j};
          insert(&ht1, point, Infected);
          insert(&ht2, point, Infected);
        }
        lasti = i;
        lastj = j;
        j++;
        break;
      default:
        break;
    }
  }

  int x = lasti / 2;
  int y = lastj / 2;
  int dx = -1;
  int dy = 0;
  int p1 = 0;
  int p2 = 0;

  // Part 1
  for (int i = 0; i < 10000; ++i)
    p1 += burst(&ht1, &x, &y, &dx, &dy) == Infected;

  x = lasti / 2;
  y = lastj / 2;
  dx = -1;
  dy = 0;
  for (int i = 0; i < 10000000; ++i)
    p2 += burst_evolved(&ht2, &x, &y, &dx, &dy) == Infected;

  printf("Part1: %d\n", p1);
  printf("Part2: %d\n", p2);

  free_ht(&ht1);
  free_ht(&ht2);
  return 0;
}
