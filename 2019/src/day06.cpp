#include <fstream>
#include <iostream>
#include <queue>
#include <unordered_map>
#include <unordered_set>
#include <vector>
using namespace std;
pair<unordered_map<string, vector<string>>,
     unordered_map<string, vector<string>>>
parse_data(istream &fh) {
  unordered_map<string, vector<string>> onedirec, nondirec;
  string line, planet1, planet2;
  string delimiter = ")";
  while (fh >> line) {
    int del_pos = line.find(delimiter);
    planet1 = line.substr(0, del_pos);
    planet2 = line.substr(del_pos + 1, line.length());
    onedirec[planet1].push_back(planet2);
    nondirec[planet1].push_back(planet2);
    nondirec[planet2].push_back(planet1);
  }
  return make_pair(onedirec, nondirec);
}

int count_orbits(const string key, unordered_map<string, vector<string>> graph,
                 unordered_map<string, int> &memo) {
  unordered_map<string, int>::iterator mit;
  mit = memo.find(key);
  if (mit == memo.end()) {
    int ans = 0;
    for (string child : graph[key]) {
      ans += 1 + count_orbits(child, graph, memo);
    }
    return memo[key] = ans;
  }
  return mit->second;
}

int get_total_orbits(const unordered_map<string, vector<string>> graph) {
  int out = 0;
  static unordered_map<string, int> memo;
  for (auto it = graph.begin(); it != graph.end(); ++it) {
    out += count_orbits(it->first, graph, memo);
  }
  return out;
}

int bfs(unordered_map<string, vector<string>> graph, string start,
        string target) {
  unordered_set<string> visited;
  std::queue<pair<string, int>> que;
  que.push(make_pair(start, 0));
  while (!que.empty()) {
    auto [node, dst] = que.front();
    que.pop();
    if (node == target) return dst;
    visited.insert(node);
    for (string children : graph[node]) {
      if (visited.find(children) == visited.end()) {
        que.push(make_pair(children, dst + 1));
      }
    }
  }
  throw std::runtime_error("Not found");
}

int main(int argc, char *argv[]) {
  string filepath = argc > 1 ? argv[1] : "input/day06.txt";
  std::ifstream fh(filepath);
  auto [graph, non_direc] = parse_data(fh);

  cout << "Part1: " << get_total_orbits(graph) << endl;
  cout << "Part2: " << bfs(non_direc, "YOU", "SAN") - 2 << endl;
  return 0;
}
