const fs = require("fs");

const filename_ = process.argv[2] || "input/day21.txt";
const data = fs.readFileSync(filename_).toString().split("\n").filter(Boolean);

function parse_data(strs) {
  const allergen_ingredients = new Map(),
    ingredients = [],
    allergens = [];
  const re_ing = /^(.+?)\s+\(/,
    re_al = /\(contains (.+?)\)/;

  for (const line of strs) {
    const ing = line.match(re_ing)[1].split(" "),
      aller = line.match(re_al)[1].split(", ");
    ingredients.push(ing);
    allergens.push(aller);
    aller.forEach((itm) => {
      if (allergen_ingredients.has(itm))
        allergen_ingredients.get(itm).push(ing);
      else allergen_ingredients.set(itm, [ing]);
    });
  }
  return { allergen_ingredients, ingredients, allergens };
}

const { allergen_ingredients, ingredients, _ } = parse_data(data);

function determine_allergen(ing, aller_ing, ingset) {
  for (const [key, ingredients] of aller_ing) {
    if (!Array.isArray(ingredients)) continue;
    const ing_idx = ingredients.indexOf(ing);
    if (ing_idx > -1) {
      ingredients.splice(ing_idx, 1);
    }
    if (Array.isArray(ingredients) && ingredients.length === 1) {
      aller_ing.set(key, ingredients[0]);
      ingset.add(ingredients[0]);
      determine_allergen(ingredients[0], aller_ing, ingset);
    }
  }
}

function find_allergens(allergen_ingredients) {
  const out = new Map();
  const det_ing = new Set();
  for (const [allergen, ingredients] of allergen_ingredients) {
    let ing_intersec = ingredients[0].filter((ing) => !det_ing.has(ing));
    for (const ing_lst of ingredients) {
      ing_intersec = ing_intersec.filter((ing) => ing_lst.includes(ing));
    }
    if (ing_intersec.length === 1) {
      out.set(allergen, ing_intersec[0]);
      det_ing.add(ing_intersec[0]);
      determine_allergen(ing_intersec[0], out, det_ing);
    } else out.set(allergen, ing_intersec);
  }
  return out;
}

function part1(allergen_ingredients, ing_lists) {
  const allergen_map = find_allergens(allergen_ingredients);
  const ings = Array.from(allergen_map.values());
  let out = 0;
  for (const inglst of ing_lists)
    for (const ing of inglst) if (!ings.includes(ing)) out++;
  return out;
}

function part2(allergen_ingredients) {
  const allergen_map = find_allergens(allergen_ingredients);
  const allergen_list = [];
  for (const [_, aller] of [...allergen_map.entries()].sort())
    allergen_list.push(aller);
  return allergen_list.join(",");
}

console.log("Part1: ", part1(allergen_ingredients, ingredients));
console.log("Part2: ", part2(allergen_ingredients));
