const fs = require("fs");

function isSubset(subset, set) {
  for (var elem of subset) {
    if (!set.has(elem)) {
      return false;
    }
  }
  return true;
}

const data = fs
  .readFileSync("input/day04.txt")
  .toString()
  .split("\n\n")
  .filter(Boolean);

const required_fields = new Set([
  "byr",
  "iyr",
  "eyr",
  "hgt",
  "hcl",
  "ecl",
  "pid",
  // "cid",
]);

let valid_passports = 0;
let valid_passports2 = 0;
const re = /(\S+):(\S+)/g;

for (let i = 0; i < data.length; i++) {
  const passport = data[i];
  let present_fields = new Set();
  let present_fields2 = new Set();

  while ((m = re.exec(passport)) !== null) {
    const key = m[1];
    let value = m[2];
    present_fields.add(key);

    switch (key) {
      case "byr":
        value = Number(value);
        value >= 1920 && value <= 2002 && present_fields2.add(key);
        break;
      case "iyr":
        value = Number(value);
        value >= 2010 && value <= 2020 && present_fields2.add(key);
        break;
      case "eyr":
        value = Number(value);
        value >= 2020 && value <= 2030 && present_fields2.add(key);
        break;
      case "hgt":
        if (value.split("cm").length == 2) {
          value = Number(value.split("cm")[0]);
          value >= 150 && value <= 193 && present_fields2.add(key);
        } else if (value.split("in").length == 2) {
          value = Number(value.split("in")[0]);
          value >= 59 && value <= 76 && present_fields2.add(key);
        }
        break;
      case "hcl":
        /#[a-f0-9]{6}/.test(value) && present_fields2.add(key);
        break;
      case "ecl":
        ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"].includes(value) &&
          present_fields2.add(key);
        break;
      case "pid":
        /\d{9}/.test(value) && present_fields2.add(key);
        break;
    }
  }

  valid_passports += isSubset(required_fields, present_fields);
  valid_passports2 += isSubset(required_fields, present_fields2);
}

console.log(valid_passports);
console.log(valid_passports2);
