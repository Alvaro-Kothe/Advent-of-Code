#include <fstream>
#include <iostream>
#include <limits>
#include <vector>

using image_matrix = std::vector<std::vector<int>>;
using image_layers = std::vector<image_matrix>;

const int width = 25, height = 6;
image_layers parse_data(std::istream &fh) {
  image_layers out;
  int i = 0, j = 0;
  image_matrix img(height, std::vector<int>(width));
  char ch;
  while (fh >> ch) {
    img[i][j] = ch - '0';
    j++;
    if (j >= width) {
      i++;
      j = 0;
    }
    if (i >= height) {
      out.push_back(img);
      i = 0;
    }
  }
  return out;
}

int part1(const image_layers layers) {
  int min_zero = std::numeric_limits<int>::max();
  int zero_count, one_count, two_count, ans;
  for (int layer = 0; layer < layers.size(); ++layer) {
    zero_count = one_count = two_count = 0;
    for (int i = 0; i < height; ++i) {
      for (int j = 0; j < width; ++j) {
        switch (layers[layer][i][j]) {
          case 0:
            zero_count++;
            break;
          case 1:
            one_count++;
            break;
          case 2:
            two_count++;
            break;
        }
      }
    }
    if (zero_count < min_zero) {
      min_zero = zero_count;
      ans = one_count * two_count;
    }
  }
  return ans;
}

void print_image(const image_matrix image) {
  for (int i = 0; i < height; ++i) {
    for (int j = 0; j < width; ++j) {
      char ch = image[i][j] == 0 ? ' ' : '#';
      std::cout << ch;
    }
    std::cout << '\n';
  }
}

image_matrix render_image(const image_layers layers) {
  image_matrix out = layers[0];
  for (int layer = 1; layer < layers.size(); ++layer) {
    for (int i = 0; i < height; ++i) {
      for (int j = 0; j < width; ++j) {
        if (out[i][j] == 2) {
          out[i][j] = layers[layer][i][j];
        }
      }
    }
  }
  return out;
}

int main(int argc, char **argv) {
  std::string filepath = argc > 1 ? argv[1] : "input/day08.txt";
  std::ifstream fh(filepath);
  image_layers layers = parse_data(fh);
  std::cout << "Part1: " << part1(layers) << std::endl;
  std::cout << "Part2: " << std::endl;
  print_image(render_image(layers));
  return 0;
}
