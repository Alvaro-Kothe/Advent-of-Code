const fs = require("fs");

const filename_ = process.argv[2] || "input/day22.txt";
const data = fs
  .readFileSync(filename_)
  .toString()
  .split("\n\n")
  .filter(Boolean)
  .map((player) => player.split("\n").slice(1).filter(Boolean).map(Number));

const [hand1, hand2] = data;

function play_game(hand1, hand2) {
  if (hand1.length === 0) return hand2;
  else if (hand2.length === 0) return hand1;
  const card1 = hand1.shift(),
    card2 = hand2.shift();
  if (card1 > card2) {
    hand1.push(card1);
    hand1.push(card2);
  } else {
    hand2.push(card2);
    hand2.push(card1);
  }
  return play_game(hand1, hand2);
}

function score(hand) {
  const n = hand.length;
  let out = 0;
  for (let i = 0; i < n; i++) {
    out += hand[i] * (n - i);
  }
  return out;
}

function part1(hand1, hand2) {
  hand1 = hand1.slice();
  hand2 = hand2.slice();
  const winner_hand = play_game(hand1, hand2);
  return score(winner_hand);
}

function hash_state(x, y) {
  return x.join(" ") + "," + y.join(" ");
}

function play_recursive_combat(hand1, hand2, seen) {
  const n1 = hand1.length,
    n2 = hand2.length;
  if (n1 === 0) return { winner: 2, hand: hand2 };
  const hash = hash_state(hand1, hand2);
  if (n2 === 0 || seen.has(hash)) return { winner: 1, hand: hand1 };
  seen.add(hash);
  const card1 = hand1.shift(),
    card2 = hand2.shift();
  let p1win = card1 > card2;
  if (n1 > card1 && n2 > card2) {
    // recurse
    // if p1 has the highest card and there is no way to remove this card from him
    // (only way to lose with highest card is to lose subgame)
    // so it wins if there would be no subgame while holding the highest card
    const rec_h1 = hand1.slice(0, card1),
      rec_h2 = hand2.slice(0, card2);
    const p1_max_card = Math.max(...rec_h1),
      p2_max_card = Math.max(...rec_h2);
    if (p1_max_card > p2_max_card && p1_max_card > card1 + card2 - 2)
      p1win = true;
    else {
      const subgame_seen = new Set();
      const result = play_recursive_combat(rec_h1, rec_h2, subgame_seen);
      p1win = result.winner === 1;
    }
  }
  if (p1win) {
    hand1.push(card1);
    hand1.push(card2);
  } else {
    hand2.push(card2);
    hand2.push(card1);
  }
  return play_recursive_combat(hand1, hand2, seen);
}

function part2(hand1, hand2) {
  hand1 = hand1.slice();
  hand2 = hand2.slice();
  let seen = new Set();
  const winner_hand = play_recursive_combat(hand1, hand2, seen).hand;
  return score(winner_hand);
}

console.log("Part1: ", part1(hand1, hand2));
console.log("Part2: ", part2(hand1, hand2));
