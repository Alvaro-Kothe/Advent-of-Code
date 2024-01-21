const fs = require("fs");

const filename_ = process.argv[2] || "input/day19.txt";
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

function* match_sequence(rules, seq, message) {
  if (seq.length === 0) yield message;
  else
    for (let rest of match_rule(rules, seq[0], message))
      yield* match_sequence(rules, seq.slice(1), rest);
}

function* match_option(rules, options, message) {
  for (const seq of options) {
    yield* match_sequence(rules, seq, message);
  }
}

function* match_rule(rules, ruleid, message) {
  const rule = rules.get(ruleid);
  if (typeof rule === "string" && message.startsWith(rule))
    yield message.slice(rule.length);
  else if (Array.isArray(rule)) yield* match_option(rules, rule, message);
}

function match(rules, rule_id, msg) {
  for (const m of match_rule(rules, rule_id, msg)) {
    if (m === "") return true;
  }
  return false;
}

function count_match0(messages, rules) {
  return messages.reduce((acc, msg) => acc + match(rules, "0", msg), 0);
}

const part2_rules = new Map(rules);
part2_rules.set("8", [["42"], ["42", "8"]]);
part2_rules.set("11", [
  ["42", "31"],
  ["42", "11", "31"],
]);

console.log("Part1: ", count_match0(messages, rules));
console.log("Part2: ", count_match0(messages, part2_rules));
