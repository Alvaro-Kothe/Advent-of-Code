#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_STATES 10
#define MAX_BUCKETS 10000

struct Rule {
  int write;
  int move;
  char next_state;
};

typedef struct {
  char state;
  struct Rule rules[2];
} State;

int parse_dir(char *str) {
  if (strcmp(str, "left.") == 0) return -1;
  if (strcmp(str, "right.") == 0) return 1;
  printf("Invalid direction \"%s\"\n", str);
  exit(EXIT_FAILURE);
}

int find(char ch, State states[MAX_STATES], int size) {
  for (int i = 0; i < size; ++i)
    if (states[i].state == ch) return i;
  return -1;
}

uint32_t hash(int x) { return x; }

typedef struct Node {
  int key;
  int value;
  struct Node *next;
} Node;

typedef struct {
  Node *head;
} HashtableEntry;

typedef struct {
  HashtableEntry table[MAX_BUCKETS];
} Hashtable;

Node *insert(Hashtable *ht, int key, int value) {
  uint32_t index = hash(key) % MAX_BUCKETS;
  Node *new_node = (Node *)malloc(sizeof(Node));
  new_node->key = key;
  new_node->value = value;
  new_node->next = NULL;

  if (ht->table[index].head == NULL) {
    ht->table[index].head = new_node;
  } else {
    Node *temp = ht->table[index].head;
    while (temp->next != NULL) {
      if (temp->key == key) {
        new_node->next = temp->next;
        return temp;
      }
      temp = temp->next;
    }
    temp->next = new_node;
  }
  return NULL;
}

Node *search(Hashtable *ht, int key) {
  uint32_t index = hash(key) % MAX_BUCKETS;
  if (ht->table[index].head == NULL) {
    return NULL;
  }
  Node *temp = ht->table[index].head;
  while (temp != NULL) {
    if (temp->key == key) return temp;

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

char apply_rule(struct Rule rule, int *cursor, Hashtable *ht, Node *node) {
  if (node == NULL) {
    insert(ht, *cursor, rule.write);
  } else {
    node->value = rule.write;
  }
  *cursor += rule.move;
  return rule.next_state;
}

/** Apply rule for given state and return the next state as a char. */
char verify_state(State state, int *cursor, Hashtable *ht) {
  Node *cur_node = search(ht, *cursor);
  int cur_value = cur_node == NULL ? 0 : cur_node->value;
  return apply_rule(state.rules[cur_value], cursor, ht, cur_node);
}

int main() {
  int read_preamble = 0;
  char begin_state;
  int diagnostic_checksum_steps = 0;

  State states[MAX_STATES];
  int nstates = 0;

  while (!feof(stdin)) {
    if (!read_preamble) {
      read_preamble = 1;
      fscanf(
          stdin,
          "Begin in state %c.\nPerform a diagnostic checksum after %d steps.",
          &begin_state, &diagnostic_checksum_steps);
    } else {
      char d0[10], d1[10];
      if (fscanf(stdin, "\nIn state %c:", &states[nstates].state) != 1)
        continue;
      fscanf(stdin, " If the current value is 0:");
      fscanf(stdin, " - Write the value %d.", &states[nstates].rules[0].write);
      fscanf(stdin, " - Move one slot to the %s", d0);
      fscanf(stdin, " - Continue with state %c.",
             &states[nstates].rules[0].next_state);
      fscanf(stdin, " If the current value is 1:");
      fscanf(stdin, " - Write the value %d.", &states[nstates].rules[1].write);
      fscanf(stdin, " - Move one slot to the %s", d1);
      fscanf(stdin, " - Continue with state %c.",
             &states[nstates].rules[1].next_state);
      states[nstates].rules[0].move = parse_dir(d0);
      states[nstates].rules[1].move = parse_dir(d1);
      nstates++;
    }
  }

  Hashtable tape = {NULL};
  int cursor = 0;

  char cur_state_ch = begin_state;
  for (int i = 0; i < diagnostic_checksum_steps; ++i) {
    int cur_state_idx = find(cur_state_ch, states, nstates);
    cur_state_ch = verify_state(states[cur_state_idx], &cursor, &tape);
  }

  int sum = 0;
  for (int i = 0; i < MAX_BUCKETS; ++i) {
    Node *temp = tape.table[i].head;
    while (temp != NULL) {
      sum += temp->value;
      temp = temp->next;
    }
  }

  printf("Part1: %d\n", sum);

  free_ht(&tape);

  return 0;
}
