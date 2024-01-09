#include <algorithm>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <ostream>
#include <queue>
#include <sstream>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

using recipe_map_t = std::unordered_map<
    std::string,
    std::pair<uint32_t, std::vector<std::pair<uint32_t, std::string>>>>;

std::vector<std::pair<uint32_t, std::string>>
parse_ractants(std::string reactants_str) {
  std::vector<std::pair<uint32_t, std::string>> reactants;
  reactants_str.erase(
      std::remove(reactants_str.begin(), reactants_str.end(), ','),
      reactants_str.end());
  std::stringstream ss(reactants_str);
  uint32_t quantity;
  std::string element;
  while (ss >> quantity >> element) {
    reactants.push_back({quantity, element});
  }
  return reactants;
}

recipe_map_t parse_data(std::istream &fh) {
  recipe_map_t reaction_map;
  std::string line;
  while (std::getline(fh, line)) {
    std::string delimiter = " => ";
    int pos = line.find(delimiter);
    std::string reactants_str = line.substr(0, pos);
    std::string output_chem =
        line.substr(pos + delimiter.length(), line.length());
    auto reactants = parse_ractants(reactants_str);
    std::stringstream oss(output_chem);
    uint32_t quantity;
    std::string element;
    oss >> quantity >> element;
    reaction_map[element] = std::make_pair(quantity, reactants);
  }
  return reaction_map;
}

uint64_t get_required_ore(recipe_map_t reaction_map,
                          std::unordered_map<std::string, uint64_t> &deposit,
                          const int fuel_amount = 1) {
  uint64_t req_ore = 0;
  std::queue<std::pair<uint64_t, std::string>> needed_ingredients;
  needed_ingredients.push({fuel_amount, "FUEL"});
  auto get_from_deposit = [&deposit](const std::string material,
                                     uint64_t &needed_qnt) -> void {
    auto it = deposit.find(material);
    if (it == deposit.end()) {
      deposit[material] = 0;
      return;
    }
    uint64_t used_material = it->second > needed_qnt ? needed_qnt : it->second;
    it->second -= used_material;
    needed_qnt -= used_material;
  };
  while (!needed_ingredients.empty()) {
    auto [necessary_qnt, ingredient] = needed_ingredients.front();
    needed_ingredients.pop();
    if (ingredient == "ORE") {
      get_from_deposit(ingredient, necessary_qnt);
      req_ore += necessary_qnt;
    } else {
      get_from_deposit(ingredient, necessary_qnt);
      if (necessary_qnt > 0) {
        auto [out_qnt, reagents] = reaction_map[ingredient];
        uint64_t needed_reactions = ((necessary_qnt - 1) / out_qnt) + 1;
        uint64_t extra_qnt = needed_reactions * out_qnt - necessary_qnt;
        for (auto [reagent_qnt, reagent] : reagents) {
          needed_ingredients.push({needed_reactions * reagent_qnt, reagent});
        }
        deposit[ingredient] += extra_qnt;
      }
    }
  }
  return req_ore;
}

int part1(recipe_map_t recipe) {
  std::unordered_map<std::string, uint64_t> deposit;
  return get_required_ore(recipe, deposit, 1);
}

int part2(recipe_map_t recipe) {
  std::unordered_map<std::string, uint64_t> deposit;
  int64_t ore_stack = 1000000000000;
  auto ore_per_fuel = get_required_ore(recipe, deposit);
  uint64_t produced_fuel = 1;
  ore_stack -= ore_per_fuel;
  uint64_t required_ore = 0;
  while (ore_stack > 0) {
    uint64_t fuel_lower_limit = ore_stack / ore_per_fuel;
    if (fuel_lower_limit == 0)
      fuel_lower_limit = 1;
    required_ore = get_required_ore(recipe, deposit, fuel_lower_limit);
    ore_stack -= required_ore;
    if (ore_stack < 0)
      return produced_fuel;
    produced_fuel += fuel_lower_limit;
  }
  return produced_fuel;
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day14.txt";
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  auto recipe = parse_data(fh);
  std::cout << "Part1: " << part1(recipe) << std::endl;
  std::cout << "Part2: " << part2(recipe) << std::endl;
  return 0;
}
