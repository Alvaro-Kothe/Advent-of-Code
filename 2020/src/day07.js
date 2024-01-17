const fs = require("fs");

const data = fs
  .readFileSync("input/day07.txt")
  .toString()
  .split("\n")
  .filter(Boolean);

const reSubBag = /(\d+) (.+?) bags?[,.]/g;
let bagConnections = new Map();

for (const rule of data) {
  const color = rule.match(/(.+?) bags contain/)[1];
  !bagConnections.has(color) && bagConnections.set(color, []);

  while ((m = reSubBag.exec(rule)) !== null) {
    const amount = +m[1];
    const innerColor = m[2];
    bagConnections.get(color).push([innerColor, amount]);
  }
}

let part1 = 0;

function searchMap(map, key, searchFor) {
  if (key === searchFor) return true;

  for (const [subColor, amount] of map.get(key)) {
    if (searchMap(map, subColor, searchFor)) return true;
  }
  return false;
}

for (const [key, value] of bagConnections) {
  if (key === "shiny gold") continue;
  for (const [subColor, _] of value) {
    if (searchMap(bagConnections, subColor, "shiny gold")) {
      part1++;
      break;
    }
  }
}

function countBags(map, key) {
  let total = 0;

  for (const [subColor, amount] of map.get(key)) {
    total += amount * (countBags(map, subColor) + 1);
  }
  return total;
}

console.log(part1);
console.log(countBags(bagConnections, "shiny gold"));
