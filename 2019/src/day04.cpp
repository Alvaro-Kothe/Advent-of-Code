#include "iostream"
using namespace std;
bool verify_password(string password) {
  char last_char;
  bool adj_rule = false;

  for (char ch : password) {
    if (last_char > ch) {
      return false;
    } else if (last_char == ch) {
      adj_rule = true;
    }
    last_char = ch;
  }
  return adj_rule;
}
bool verify_password2(string password) {
  char last_char;
  int ch_counter = 1;
  bool adj_rule = false;

  for (char ch : password) {
    if (last_char > ch) {
      return false;
    } else if (last_char == ch) {
      ch_counter += 1;
    } else {
      if (ch_counter == 2) {
        adj_rule = true;
      }

      ch_counter = 1;
    }
    last_char = ch;
  }
  return adj_rule || ch_counter == 2;
}

int main(int argc, char *argv[]) {
  int rangei = argc > 2 ? stoi(argv[1]) : 271973;
  int rangef = argc > 2 ? stoi(argv[2]) : 785961;
  int p1 = 0;
  int p2 = 0;
  for (int password = rangei; password <= rangef; password++) {
    string str_pass = std::to_string(password);
    p1 += verify_password(str_pass);
    p2 += verify_password2(str_pass);
  }
  cout << "Part1: " << p1 << endl;
  cout << "Part2: " << p2 << endl;
  return 0;
}
