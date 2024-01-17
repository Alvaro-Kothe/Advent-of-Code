const fs = require("fs");

function uniqueLettersCount(str) {
  let uniqueChars = new Set(str.replaceAll(/\s/g, ""));

  return uniqueChars.size;
}

function intersect(a, b) {
  var t;
  if (b.length > a.length) (t = b), (b = a), (a = t); // indexOf to loop over shorter
  return a.filter(function (e) {
    return b.indexOf(e) > -1;
  });
}

function arraysIntersect(str) {
  let answers = str
    .split("\n")
    .filter(Boolean)
    .map((x) => x.split(""));
  console.log(answers);

  const common_answers = answers.reduce(
    intersect,
    "qwertyuiopasdfghjklzxcvbnm".split(""),
  );

  return common_answers.length;
}

const filename_ = process.argv[2] || "input/day06.txt";
const data = fs
  .readFileSync(filename_)
  .toString()
  .split("\n\n")
  .filter(Boolean);

let count = 0;
let count2 = 0;

for (let i = 0; i < data.length; i++) {
  const group = data[i];
  count += uniqueLettersCount(group);

  count2 += arraysIntersect(group);
}

console.log(count);
console.log(count2);
