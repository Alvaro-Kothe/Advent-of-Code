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

enum Operation_t { Snd, Set, Add, Mul, Mod, Rcv, Jgz };
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
  if (strcmp(str, "snd") == 0) return Snd;
  if (strcmp(str, "set") == 0) return Set;
  if (strcmp(str, "add") == 0) return Add;
  if (strcmp(str, "mul") == 0) return Mul;
  if (strcmp(str, "mod") == 0) return Mod;
  if (strcmp(str, "rcv") == 0) return Rcv;
  if (strcmp(str, "jgz") == 0) return Jgz;

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

// Returns 1 if last sound played was recovered, 0 otherwise.
// If stop_after_sent is 0, then the program returns 1 only when
// `case Rcv` and `this_queue` is empty;
int apply_instruction(int64_t registers[], Instruction instr, int *sound,
                      int *instr_pointer, int stop_after_sent,
                      int *sent_counter, Queue *this_queue,
                      Queue *other_queue) {
  switch (instr.operation) {
    case Snd:
      *sound = get_value(registers, instr.value1);
      if (!stop_after_sent) {
        enqueue(other_queue, *sound);
        *sent_counter += 1;
      }
      break;
    case Set:
      registers[get_address(instr.value1)] = get_value(registers, instr.value2);
      break;
    case Add:
      registers[get_address(instr.value1)] +=
          get_value(registers, instr.value2);
      break;
    case Mul:
      registers[get_address(instr.value1)] *=
          get_value(registers, instr.value2);
      break;
    case Mod:
      registers[get_address(instr.value1)] %=
          get_value(registers, instr.value2);
      break;
    case Rcv:
      if (stop_after_sent && registers[get_address(instr.value1)] != 0) {
        return 1;
      } else if (!stop_after_sent && is_empty(this_queue)) {
        return 1;
      } else if (!stop_after_sent)
        registers[get_address(instr.value1)] = dequeue(this_queue);

      break;
    case Jgz:
      if (get_value(registers, instr.value1) > 0) {
        *instr_pointer += get_value(registers, instr.value2);
        return 0;
      }
      break;
  }
  *instr_pointer += 1;
  return 0;
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

  int ip = 0;
  int sound = -1;
  while (ip < ninstructions &&
         !apply_instruction(registers, instructions[ip], &sound, &ip, 1, 0,
                            NULL, NULL))
    ;

  printf("Part1: %d\n", sound);

  int64_t registers0[26] = {0};
  int64_t registers1[26] = {0};
  registers1['p' - 'a'] = 1;
  Queue *queue0 = create_queue();
  Queue *queue1 = create_queue();
  int sent0 = 0;
  int sent1 = 0;
  int ip0 = 0;
  int ip1 = 0;
  int sound0, sound1;

  for (;;) {
    // clear queues
    while (ip0 < ninstructions &&
           !apply_instruction(registers0, instructions[ip0], &sound0, &ip0, 0,
                              &sent0, queue0, queue1))
      ;
    while (ip1 < ninstructions &&
           !apply_instruction(registers1, instructions[ip1], &sound1, &ip1, 0,
                              &sent1, queue1, queue0))
      ;
    // check if both stopped
    int p0_waiting = ip0 >= ninstructions ||
                     apply_instruction(registers0, instructions[ip0], &sound0,
                                       &ip0, 0, &sent0, queue0, queue1);
    int p1_waiting = ip1 >= ninstructions ||
                     apply_instruction(registers1, instructions[ip1], &sound1,
                                       &ip1, 0, &sent1, queue1, queue0);
    if (p0_waiting && p1_waiting) break;
  }

  printf("Part2: %d\n", sent1);
  return 0;
}
