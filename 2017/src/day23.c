#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_INSTRUCTIONS 100
#define MAX_SIZE 1000

typedef struct {
  int64_t items[MAX_SIZE];
  int front;
  int rear;
} Queue;

Queue *create_queue() {
  Queue *q = (Queue *)malloc(sizeof(Queue));
  q->front = -1;
  q->rear = -1;
  return q;
}

int is_empty(Queue *q) { return (q->front == -1 && q->rear == -1); }
int is_full(Queue *q) { return (q->rear == MAX_SIZE - 1); }

void enqueue(Queue *q, int64_t value) {
  if (is_full(q)) {
    printf("Queue is full. Cannot enqueue.\n");
    return;
  }
  if (is_empty(q)) {
    q->front = q->rear = 0;
  } else {
    q->rear++;
  }
  q->items[q->rear] = value;
}

int64_t dequeue(Queue *q) {
  if (is_empty(q)) {
    printf("Queue is empty\n");
    return -1;
  }
  int item = q->items[q->front];
  if (q->front == q->rear) {
    q->front = q->rear = -1;
  } else {
    q->front++;
  }
  return item;
}

enum Operation_t { Set, Sub, Mul, Jnz };
enum ValueType { Reg_t, Num_t, None_t };
struct Value_t {
  enum ValueType type;
  char reg;
  int value;
};

typedef struct {
  enum Operation_t operation;
  struct Value_t value1;
  struct Value_t value2;
} Instruction;

enum Operation_t parse_operation(char *str) {
  if (strcmp(str, "set") == 0) return Set;
  if (strcmp(str, "sub") == 0) return Sub;
  if (strcmp(str, "mul") == 0) return Mul;
  if (strcmp(str, "jnz") == 0) return Jnz;

  exit(EXIT_FAILURE);
}

int get_address(struct Value_t val) { return val.reg - 'a'; }

int64_t get_value(int64_t registers[], struct Value_t val) {
  switch (val.type) {
    case None_t:
      exit(EXIT_FAILURE);
    case Reg_t:
      return registers[get_address(val)];
    case Num_t:
      return val.value;
  }
  printf("Invalid value type\n");
  exit(EXIT_FAILURE);
}

int apply_instruction(int64_t registers[], Instruction instr,
                      int *instr_pointer) {
  switch (instr.operation) {
    case Set:
      registers[get_address(instr.value1)] = get_value(registers, instr.value2);
      break;
    case Sub:
      registers[get_address(instr.value1)] -=
          get_value(registers, instr.value2);
      break;
    case Mul:
      registers[get_address(instr.value1)] *=
          get_value(registers, instr.value2);
      break;
    case Jnz:
      if (get_value(registers, instr.value1) != 0) {
        *instr_pointer += get_value(registers, instr.value2);
        return 0;
      }
      break;
  }
  *instr_pointer += 1;
  return 0;
}

int is_prime(int x) {
  if (x == 2) return 1;
  if (x < 2 || x % 2 == 0) return 0;
  for (int i = 3; (i * i) <= x; i += 2)
    if (x % i == 0) return 0;

  return 1;
}

int main() {
  int64_t registers[26] = {0};

  Instruction instructions[MAX_INSTRUCTIONS];
  int ninstructions = 0;

  char buf[80];

  while (fgets(buf, sizeof(buf), stdin) != NULL) {
    Instruction instr;
    char op_str[4];
    if (sscanf(buf, "%s %d %d", op_str, &instr.value1.value,
               &instr.value2.value) == 3) {
      instr.value1.type = Num_t;
      instr.value2.type = Num_t;
    } else if (sscanf(buf, "%s %c %d", op_str, &instr.value1.reg,
                      &instr.value2.value) == 3) {
      instr.value1.type = Reg_t;
      instr.value2.type = Num_t;
    } else if (sscanf(buf, "%s %c %c", op_str, &instr.value1.reg,
                      &instr.value2.reg) == 3) {
      instr.value1.type = Reg_t;
      instr.value2.type = Reg_t;
    } else if (sscanf(buf, "%s %d", op_str, &instr.value1.value) == 2) {
      instr.value1.type = Num_t;
      instr.value2.type = None_t;
    } else if (sscanf(buf, "%s %c", op_str, &instr.value1.reg) == 2) {
      instr.value1.type = Reg_t;
      instr.value2.type = None_t;
    }
    instr.operation = parse_operation(op_str);
    instructions[ninstructions++] = instr;
  }

  // Part 1
  int ip = 0;
  int p1 = 0;
  while (ip < ninstructions &&
         (p1 += instructions[ip].operation == Mul,
          !apply_instruction(registers, instructions[ip], &ip)))
    ;

  // Part 2
  for (int i = 0; i < 26; ++i) registers[i] = 0;
  registers[0] = 1;
  ip = 0;
  int counter = 0;
  // Initialize b and c to see the range to verify.
  while (counter++ < 100 && ip < ninstructions &&
         !apply_instruction(registers, instructions[ip], &ip))
    ;

  int b = registers[1];
  int c = registers[2];
  int h = 0;

  for (int i = b; i <= c; i += 17) h += !is_prime(i);

  printf("Part1: %d\n", p1);
  printf("Part2: %d\n", h);
  return 0;
}
