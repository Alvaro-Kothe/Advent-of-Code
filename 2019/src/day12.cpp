#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <ostream>
#include <string>

struct Moon {
  std::array<int32_t, 3> pos, vel{{0, 0, 0}};

  Moon(){};
  Moon(int x, int y, int z) {
    pos[0] = x;
    pos[1] = y;
    pos[2] = z;
  }
};

std::array<Moon, 4> parse_data(std::istream &fh) {
  char c;
  int x, y, z;
  std::array<Moon, 4> moons{};
  int i = 0;
  while (fh >> c >> c >> c >> x >> c >> c >> c >> y >> c >> c >> c >> z >> c) {
    moons[i] = Moon(x, y, z);
    i++;
  }
  return moons;
}

int sign(int x) {
  if (x > 0) return 1;
  if (x < 0) return -1;
  return 0;
}

void apply_gravity(std::array<Moon, 4> &moons) {
  for (int i = 0; i < 4; ++i) {
    for (int j = i + 1; j < 4; ++j) {
      for (int k = 0; k < 3; ++k) {
        int pos_dif_sign = sign(moons[i].pos[k] - moons[j].pos[k]);
        moons[i].vel[k] -= pos_dif_sign;
        moons[j].vel[k] += pos_dif_sign;
      }
    }
  }
}

void apply_velocity(std::array<Moon, 4> &moons) {
  for (int i = 0; i < 4; ++i) {
    for (int k = 0; k < 3; ++k) {
      moons[i].pos[k] += moons[i].vel[k];
    }
  }
}

int compute_energy(const std::array<int, 3> arr) {
  int out = 0;
  for (int k = 0; k < 3; ++k) {
    out += std::abs(arr[k]);
  }
  return out;
}

int compute_system_energy(const std::array<Moon, 4> moons) {
  unsigned long int out = 0;
  for (int i = 0; i < 4; ++i) {
    out += compute_energy(moons[i].pos) * compute_energy(moons[i].vel);
  }
  return out;
}

std::array<int, 3> get_cycle(std::array<Moon, 4> moons) {
  std::array<Moon, 4> zero_state = moons;
  std::array<int, 3> out = {-1, -1, -1};
  int step = 0;
  auto looped_coord = [zero_state, &moons](int k) -> bool {
    for (int i = 0; i < 4; ++i) {
      if (zero_state[i].pos[k] != moons[i].pos[k] ||
          zero_state[i].vel[k] != moons[i].vel[k])
        return false;
    }
    return true;
  };
  while ((out[0] < 0 || out[1] < 0 || out[2] < 0)) {
    apply_gravity(moons);
    apply_velocity(moons);
    step++;
    for (int k = 0; k < 3; ++k) {
      if (looped_coord(k) && out[k] < 0) {
        out[k] = step;
      }
    }
  }
  return out;
}

uint64_t gcd(uint64_t a, uint64_t b) {
  if (b == 0) return a;
  return gcd(b, a % b);
}

uint64_t lcm(uint64_t a, uint64_t b) { return a * b / gcd(a, b); }

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day12.txt";
  std::ifstream fh(filepath);
  if (!fh.is_open()) {
    std::cerr << "File not found\n";
    return 1;
  }
  std::array<Moon, 4> moons = parse_data(fh);
  std::array<Moon, 4> moons_copy = moons;
  /* std::array<Moon, 4> moons = {Moon(-8, -10, 0), Moon(5, 5, 10), Moon(2, -7,
     3), Moon(9, -8, -3)}; */
  for (int step = 0; step < 1000; ++step) {
    apply_gravity(moons);
    apply_velocity(moons);
  }
  int p1 = compute_system_energy(moons);
  std::cout << "Part1: " << p1 << std::endl;
  std::array<int, 3> coord_cycles = get_cycle(moons_copy);
  unsigned long int p2 = lcm(coord_cycles[0], coord_cycles[1]);
  p2 = lcm(p2, coord_cycles[2]);
  std::cout << "Part2: " << p2 << std::endl;
  return 0;
}
