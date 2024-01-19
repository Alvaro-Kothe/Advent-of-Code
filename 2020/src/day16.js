const fs = require("fs");

const filename_ = process.argv[2] || "input/day16.txt";
const data = fs
  .readFileSync(filename_)
  .toString()
  .split("\n\n")
  .filter(Boolean);

function parse_rule(str) {
  const numeric_ranges = str.split("\n").map((rule) => {
    const [_, ranges] = rule.split(": ");
    const range_pairs = ranges.split(" or ");
    const num_range = range_pairs.map((pair) => pair.split("-").map(Number));
    return num_range;
  });
  return numeric_ranges;
}

function verification_fn(ranges) {
  function verify_value_any(value) {
    for (const or_range of ranges) {
      for (const [lo, hi] of or_range) {
        if (lo <= value && value <= hi) {
          return true;
        }
      }
    }
    return false;
  }
  return verify_value_any;
}

function parse_ticket(ticket_str) {
  return ticket_str.split(",").map(Number);
}

function get_tickets(tickets_str) {
  return tickets_str.split("\n").slice(1).filter(Boolean).map(parse_ticket);
}

const ranges = parse_rule(data[0]);
const verify_value = verification_fn(ranges);
const my_ticket = get_tickets(data[1])[0];
const nearby_tickets = get_tickets(data[2]);

function is_ticket_valid(ticket) {
  for (const value of ticket) if (!verify_value(value)) return false;
  return true;
}

function part1(tickets) {
  let out = 0;
  for (const ticket of tickets)
    ticket.forEach((value) => {
      if (!verify_value(value)) out += value;
    });

  return out;
}

function value_in_range(range, value) {
  for (const [lo, hi] of range) {
    if (lo <= value && value <= hi) return true;
  }
  return false;
}

function determine_fields(found_fields, found_rules, fieldrule) {
  for (let i = 0; i < fieldrule.length; i++) {
    if ((found_fields >> i) & 0b1) continue;
    const remaining_rules = fieldrule[i];
    const is_determined = (remaining_rules & (remaining_rules - 1)) === 0;
    if (is_determined) {
      found_fields |= 1 << i;
      found_rules |= remaining_rules;
      for (let j = 0; j < fieldrule.length; j++)
        if (j != i) fieldrule[j] &= ~remaining_rules;
      return determine_fields(found_fields, found_rules, fieldrule);
    }
  }
  return [found_fields, found_rules, fieldrule];
}

function map_fields(tickets, ranges) {
  const n_rules = ranges.length;
  const bitset_all_possible = (1 << n_rules) - 1;
  let found_fields = 0,
    found_rules = 0;
  let full_map = false;
  // this array will map the ticket field to the rule index
  // ex., [1, 4, 2, 8] -> field 0 -> rule 0, field 1 -> rule 2
  let field2rule = Array(n_rules).fill(bitset_all_possible);

  for (const ticket of tickets) {
    for (let field_idx = 0; field_idx < n_rules; field_idx++) {
      if ((found_fields >> field_idx) & 0b1) continue;
      for (let rule_idx = 0; rule_idx < n_rules; rule_idx++) {
        if ((found_rules >> rule_idx) & 0b1) continue;
        if (!value_in_range(ranges[rule_idx], ticket[field_idx])) {
          field2rule[field_idx] &= ~(0b1 << rule_idx); // delete rule
          [found_fields, found_rules, field2rule] = determine_fields(
            found_fields,
            found_rules,
            field2rule,
          );
        }
      }
    }
    if (found_fields === bitset_all_possible) {
      full_map = true;
      break;
    }
  }
  if (!full_map) throw new Error("Not found");
  return field2rule.map((x) => Math.floor(Math.log2(x)));
}

function part2(tickets, ranges, my_ticket) {
  let filtered_tickets = tickets.filter(is_ticket_valid);
  const field2rule = map_fields(filtered_tickets, ranges);
  let out = 1;
  for (let field_idx = 0; field_idx < field2rule.length; field_idx++) {
    const rule_idx = field2rule[field_idx];
    if (rule_idx < 6) out *= my_ticket[field_idx];
  }
  return out;
}

console.log("Part1: ", part1(nearby_tickets));
console.log("Part2: ", part2(nearby_tickets, ranges, my_ticket));
