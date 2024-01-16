#include "intcode.h"
#include <cstdint>
#include <fstream>
#include <iostream>
#include <optional>
#include <ostream>
#include <queue>
#include <regex>
#include <set>
#include <stdexcept>
#include <string>
#include <unordered_set>
#include <vector>

using position_t = std::pair<int, int>;
void play(memory_t program) {
  Intcode::IntcodeProgram<int64_t> intcode(program);
  intcode.use_default = true;
  std::string cumulative_commands;
  while (!intcode.finished) {
    std::optional<int64_t> prun = intcode.run_program(0);
    if (!prun.has_value()) {
      std::string instructions;
      std::getline(std::cin, instructions);
      if (instructions == "quit")
        break;

      cumulative_commands += instructions + "\\n";
      instructions += '\n';
      intcode.set_queue(instructions);
    } else if (*prun >= 0 && *prun < 256)
      std::cout << (char)*prun;
    else
      std::cout << *prun << '\n';
  }
  std::cout << cumulative_commands << '\n';
}

struct State {
  std::string room;
  std::set<std::string> carried_items;
  Intcode::IntcodeProgram<int64_t> program;
  std::pair<std::string, std::set<std::string>> get_key() {
    return {room, carried_items};
  }
};

std::string get_msg(Intcode::IntcodeProgram<int64_t> &intcode) {
  std::string msg;
  for (;;) {
    std::optional<int64_t> prun = intcode.run_program(0);
    if (!prun.has_value())
      return msg;
    msg += *prun;
  }
}

struct Options_t {
  std::string room;
  std::vector<std::string> move, items;
};

Options_t parse_msg(const std::string msg) {
  Options_t result;
  std::regex name_re("== (.+) ==");
  std::smatch match;
  if (std::regex_search(msg, match, name_re)) {
    result.room = match[1].str();
  }
  std::regex item_regex(R"(\s+- (.+))");
  auto items_begin = std::sregex_iterator(msg.begin(), msg.end(), item_regex);
  auto items_end = std::sregex_iterator();
  for (auto i = items_begin; i != items_end; ++i) {
    std::smatch match = *i;
    std::string match_str = match[1].str();
    if (match_str == "east" || match_str == "south" || match_str == "north" ||
        match_str == "west")
      result.move.push_back(match_str);
    else
      result.items.push_back(match_str);
  }
  return result;
}

int bfs(const memory_t program) {
  static std::unordered_set<std::string> blacklist{
      "giant electromagnet", "infinite loop", "molten lava", "escape pod",
      "photons"};
  State initial_state, final_state;
  initial_state.program = Intcode::IntcodeProgram<int64_t>(program);
  initial_state.program.use_default = true;
  std::queue<State> queue;
  queue.push(initial_state);
  std::set<std::pair<std::string, std::set<std::string>>> seen_states;
  while (!queue.empty()) {
    auto cur_state = queue.front();
    queue.pop();
    if (cur_state.program.finished)
      continue;
    std::string msg = get_msg(cur_state.program);
    auto options = parse_msg(msg);
    cur_state.room = options.room;
    auto key = cur_state.get_key();
    if (cur_state.room == "Security Checkpoint" && // how to generalize this?
        cur_state.carried_items.size() == 8) {
      final_state = cur_state;
      break;
    }
    if (seen_states.find(key) != seen_states.end())
      continue;
    seen_states.insert(key);
    std::string next_command;
    // take items
    auto next_state_items = cur_state.carried_items;
    for (auto item : options.items)
      if (blacklist.find(item) == blacklist.end()) {
        next_command += "take " + item + '\n';
        next_state_items.insert(item);
      }
    for (auto mv_cmd : options.move) {
      auto next_state = cur_state;
      next_state.carried_items = next_state_items;
      auto key = next_state.get_key();
      next_state.program.set_queue(next_command + mv_cmd + '\n');
      queue.push(next_state);
    }
  }
  // currently in the checkpoint room with all items.
  // try every possible combination

  // turn set into vector for index access
  std::vector<std::string> carried_items(final_state.carried_items.begin(),
                                         final_state.carried_items.end());
  size_t nitems = carried_items.size();
  final_state.program.clear_queue();
  for (auto itm : carried_items)
    final_state.program.set_queue("drop " + itm + '\n');

  // Try every nCk combinations, for k = 1,...,n
  for (size_t combination = 1; combination < (size_t)1 << nitems;
       ++combination) {
    std::string takecmd, dropcmd;
    for (size_t i = 0; i < nitems; ++i)
      if ((combination >> i) & 1) {
        takecmd += "take " + carried_items[i] + '\n';
        dropcmd += "drop " + carried_items[i] + '\n';
      }
    // take needed items, go south to test weight, drop items
    final_state.program.set_queue(takecmd + "south\n" + dropcmd);
  }
  while (!final_state.program.finished) {
    std::optional<int64_t> prun = final_state.program.run_program(0);
    if (!prun.has_value()) {
      throw std::runtime_error("Can't enter");
    } else if (*prun >= 0 && *prun < 256)
      std::cout << (char)*prun;
    else
      return *prun;
  }
  return -1;
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day25.txt";
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  const memory_t program = Intcode::parse_data(fh);
  // play(program);
  std::cout << bfs(program) << '\n';
  return 0;
}
