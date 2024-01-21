const fs = require("fs");

const filename_ = process.argv[2] || "tst";
const data = fs.readFileSync(filename_).toString().trim().split("\n\n");

const rule_raw = data[0];
const messages = data[1].trim().split("\n");

function parse_rules(str) {
  const out = new Map();
  for (const line of str.trim().split("\n")) {
    const [k, rule] = line.split(": ");
    if (rule[0] === '"') out.set(k, rule[1]);
    else {
      const subrules = rule.split(" | ").map((x) => x.split(" "));
      out.set(k, subrules);
    }
  }
  return out;
}

const rules = parse_rules(rule_raw);

function match_sequence(rules, seq, message) {
  let rest = message;
  for (const ruleid of seq) {
    rest = match_rule(rules, ruleid, rest);
    if (rest === null) return null;
  }
  return rest;
}

function match_option(rules, options, message) {
  for (const seq of options) {
    const rest_str = match_sequence(rules, seq, message);
    if (rest_str !== null) return rest_str;
  }
  return null;
}

function match_rule(rules, ruleid, message) {
  const rule = rules.get(ruleid);
  if (typeof rule === "string")
    return message.startsWith(rule) ? message.slice(rule.length) : null;
  return match_option(rules, rule, message);
}

console.log(
  "Part1: ",
  messages.reduce((acc, msg) => acc + (match_rule(rules, "0", msg) === ""), 0),
);
console.log("Part2: ", -1);
