#include "intcode.h"
#include <iostream>

memory_t Intcode::parse_data(std::istream &fh) {
  memory_t out;
  std::string str;
  int i = 0;
  while (getline(fh, str, ',')) {
    out[i] = std::stoll(str);
    i++;
  }
  return out;
}
