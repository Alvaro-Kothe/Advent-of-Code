const fs = require("fs");

const filename_ = process.argv[2] || "input/day12.txt";
const data = fs
  .readFileSync(filename_)
  .toString()
  .split("\n")
  .filter(Boolean)
  .map((x) => [x[0], parseInt(x.slice(1))]);

function flip_once(dx, dy, dir) {
  const tmp = dx;
  switch (dir) {
    case "L":
      dx = -dy;
      dy = tmp;
      break;
    case "R":
      dx = dy;
      dy = -tmp;
      break;
    default:
      throw new Error("Invalid direction");
  }
  return [dx, dy];
}

function flip(dx, dy, flip_direction, degrees) {
  const nrot = Math.floor(degrees / 90);
  for (let i = 0; i < nrot; i++) [dx, dy] = flip_once(dx, dy, flip_direction);
  return [dx, dy];
}

function move(instructions, waypoint = false) {
  let dx = waypoint ? -1 : 0,
    dy = waypoint ? 10 : 1,
    x = 0,
    y = 0;

  for (const [action, value] of instructions) {
    switch (action) {
      case "F":
        x += dx * value;
        y += dy * value;
        break;
      case "N":
        if (waypoint) dx -= value;
        else x -= value;
        break;
      case "S":
        if (waypoint) dx += value;
        else x += value;
        break;
      case "W":
        if (waypoint) dy -= value;
        else y -= value;
        break;
      case "E":
        if (waypoint) dy += value;
        else y += value;
        break;
      case "L":
      case "R":
        [dx, dy] = flip(dx, dy, action, value);
        break;
      default:
        throw new Error("Invalid action");
    }
  }
  return Math.abs(x) + Math.abs(y);
}

console.log("Part1: ", move(data));
console.log("Part2: ", move(data, true));
