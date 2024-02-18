#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "stdio.h"

#define MAX_LINE_LENGTH 100
#define MAX_REGISTERS 1024

typedef struct Instruction {
  char reg[6];
  char op[5];
  int val;
  char cond_reg[6];
  char cond_op[4];
  int cond_val;
} Instruction;

typedef struct Node {
  char key[6];
  int value;
  struct Node *next;
} Node;

typedef struct {
  Node *head;
} HashtableEntry;

typedef struct {
  HashtableEntry table[MAX_REGISTERS];
} Hashtable;

uint32_t hash(char *str) {
  uint32_t h = 0xc7af23, m = 1e9 + 7;
  int c;
  while ((c = *str++)) h = ((h << 5 | h >> 17) + c) % m;
  return h;
}

void insert(Hashtable *ht, char *key, int value) {
  uint32_t index = hash(key) % MAX_REGISTERS;
  Node *new_node = (Node *)malloc(sizeof(Node));
  strcpy(new_node->key, key);
  new_node->value = value;
  new_node->next = NULL;

  if (ht->table[index].head == NULL) {
    ht->table[index].head = new_node;
  } else {
    Node *temp = ht->table[index].head;
    while (temp->next != NULL) {
      temp = temp->next;
    }
    temp->next = new_node;
  }
}

Node *search(Hashtable *ht, char *key) {
  uint32_t index = hash(key) % MAX_REGISTERS;
  Node *temp = ht->table[index].head;

  while (temp != NULL) {
    if (strcmp(temp->key, key) == 0) {
      return temp;
    }
    temp = temp->next;
  }

  return NULL;
}

void free_ht(Hashtable *ht) {
  for (int i = 0; i < MAX_REGISTERS; i++) {
    Node *temp = ht->table[i].head;
    while (temp != NULL) {
      Node *next = temp->next;
      free(temp);
      temp = next;
    }
  }
}

Hashtable run_instructions(Instruction instructions[], int size,
                           int *max_value) {
  Hashtable ht = {0};

  for (int i = 0; i < size; ++i) {
    Instruction instr = instructions[i];
    Node *cond_node = search(&ht, instr.cond_reg);
    int cond_reg_val = cond_node == NULL ? 0 : cond_node->value;
    int cond_met = 0;

    if (strcmp(instr.cond_op, "==") == 0) {
      cond_met = (cond_reg_val == instr.cond_val);
    } else if (strcmp(instr.cond_op, "!=") == 0) {
      cond_met = (cond_reg_val != instr.cond_val);
    } else if (strcmp(instr.cond_op, ">") == 0) {
      cond_met = (cond_reg_val > instr.cond_val);
    } else if (strcmp(instr.cond_op, "<") == 0) {
      cond_met = (cond_reg_val < instr.cond_val);
    } else if (strcmp(instr.cond_op, ">=") == 0) {
      cond_met = (cond_reg_val >= instr.cond_val);
    } else if (strcmp(instr.cond_op, "<=") == 0) {
      cond_met = (cond_reg_val <= instr.cond_val);
    }

    if (cond_met) {
      Node *reg_node = search(&ht, instr.reg);

      if (reg_node == NULL) {
        insert(&ht, instr.reg, 0);
        reg_node = search(&ht, instr.reg);
      }

      reg_node->value +=
          (strcmp(instr.op, "inc") == 0) ? instr.val : -instr.val;
      if (reg_node->value > *max_value) {
        *max_value = reg_node->value;
      }
    }
  }
  return ht;
}

int find_max(Hashtable *ht) {
  int max_value = 0;
  for (int i = 0; i < MAX_REGISTERS; ++i) {
    Node *temp = ht->table[i].head;
    while (temp != NULL) {
      if (temp->value > max_value) max_value = temp->value;
      temp = temp->next;
    }
  }
  return max_value;
}

int main() {
  Instruction instructions[MAX_REGISTERS];
  int size = 0;

  char buf[MAX_LINE_LENGTH];

  while (fgets(buf, sizeof(buf), stdin) != NULL) {
    Instruction instr;
    sscanf(buf, "%s %s %d if %s %s %d", instr.reg, instr.op, &instr.val,
           instr.cond_reg, instr.cond_op, &instr.cond_val);
    instructions[size++] = instr;
  }

  int p2 = 0;
  Hashtable ht = run_instructions(instructions, size, &p2);

  int p1 = find_max(&ht);

  printf("Part1: %d\n", p1);
  printf("Part2: %d\n", p2);

  free_ht(&ht);

  return 0;
}
