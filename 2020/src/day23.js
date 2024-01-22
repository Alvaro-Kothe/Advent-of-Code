const fs = require("fs");

const data = "716892543";
// const data = "389125467";
const cups = data.split("").map(Number);

class Node {
  constructor(data) {
    this.data = data;
    this.next = null;
  }
}

/** Circular linked list
 */
class LinkedList {
  constructor() {
    this.head = null;
    this.tail = null;
    this.table = Array(1 << 20);
  }
  append(data) {
    const new_node = new Node(data);
    if (!this.tail) {
      this.head = new_node;
      this.tail = new_node;
      this.tail.next = this.head;
      this.table[data] = this.tail;
      return;
    }
    this.tail.next = new_node;
    this.tail = new_node;
    this.tail.next = this.head;
    this.table[data] = this.tail;
  }
}

function move_ln_lst(cup, highest_value, lookuptbl) {
  let current = cup;
  let picked_end = current,
    picked_start = current.next;
  const picked_values = [];
  for (let i = 0; i < 3; i++) {
    picked_end = picked_end.next;
    picked_values.push(picked_end.data);
  }
  current.next = picked_end.next;
  let destination = current.data - 1;
  while (picked_values.includes(destination) || destination < 1) {
    destination--;
    if (destination < 1) destination = highest_value;
  }
  current = lookuptbl[destination];
  const prev_ln = current.next;
  current.next = picked_start;
  picked_end.next = prev_ln;
  return cup.next;
}

function part1(cups) {
  const lnlst = new LinkedList();
  for (const x of cups) lnlst.append(x);
  let cup = lnlst.head;
  for (let i = 0; i < 100; i++) cup = move_ln_lst(cup, 9, lnlst.table);
  let one_cup = cup;
  while (one_cup.data !== 1) one_cup = one_cup.next;
  let out = "";
  one_cup = one_cup.next;
  for (let i = 0; i < 8; i++) {
    out += one_cup.data;
    one_cup = one_cup.next;
  }
  return out;
}

function part2(cups) {
  const ncups = 1000000;
  const lnlst = new LinkedList();
  for (const x of cups) lnlst.append(x);
  for (let i = cups.length + 1; i <= ncups; i++) lnlst.append(i);
  let cup = lnlst.head;
  for (let i = 0; i < 10000000; i++) {
    cup = move_ln_lst(cup, ncups, lnlst.table);
  }
  let one_cup = cup;
  while (one_cup.data !== 1) one_cup = one_cup.next;
  let out = 1;
  for (let i = 0; i < 2; i++) {
    one_cup = one_cup.next;
    out *= one_cup.data;
  }
  return out;
}

console.log("Part1: ", part1(cups));
console.log("Part2: ", part2(cups));
