const fs = require("fs");

const filename_ = process.argv[2] || "input/day18.txt";
const data = fs.readFileSync(filename_).toString().trim().split("\n");

function apply_op(op, x, y) {
  if (op === "+") return x + y;
  else if (op === "*") return x * y;
}

function higher_precedence(precedence, a, b) {
  const pa = precedence[a],
    pb = precedence[b];
  if (pa === undefined || pb === undefined) return false;
  return pa >= pb;
}

function evaluate_expresssion(expr_str, precedence = { "+": 1, "*": 1 }) {
  const tokens = expr_str.match(/\d+|[+*()]/g);
  const operator_stack = [],
    operand_stack = [];

  function apply_pending_operators() {
    while (operator_stack.length > 0) {
      const operator = operator_stack.pop();
      if (operator === "(") return;
      const operand2 = operand_stack.pop();
      const operand1 = operand_stack.pop();
      operand_stack.push(apply_op(operator, operand1, operand2));
    }
  }

  for (const token of tokens) {
    if (token === "(") {
      operator_stack.push(token);
    } else if (token === ")") {
      apply_pending_operators();
    } else if (token === "+" || token === "*") {
      while (
        operator_stack.length > 0 &&
        higher_precedence(precedence, operator_stack.at(-1), token)
      ) {
        const operator = operator_stack.pop();
        const operand2 = operand_stack.pop();
        const operand1 = operand_stack.pop();
        operand_stack.push(apply_op(operator, operand1, operand2));
      }
      operator_stack.push(token);
    } else {
      operand_stack.push(parseInt(token, 10));
    }
  }
  apply_pending_operators();

  if (operand_stack.length !== 1 || operator_stack.length !== 0)
    throw new Error("Invalid expression");

  return operand_stack[0];
}

console.log(
  "Part1: ",
  data.reduce((acc, expr) => acc + evaluate_expresssion(expr), 0),
);
console.log(
  "Part2: ",
  data.reduce(
    (acc, expr) => acc + evaluate_expresssion(expr, { "*": 0, "+": 1 }),
    0,
  ),
);
