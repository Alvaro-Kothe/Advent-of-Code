#include <limits.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define MAX_SIZE 2000

typedef struct {
  int p[3];
  int v[3];
  int a[3];
} Particle;

int distance(int arr[]) {
  int res = 0;
  for (int i = 0; i < 3; ++i) res += abs(arr[i]);
  return res;
}

/** Solutions for Bhashkara system, number of solutions is in roots
 * negative value means any solution. If the solution would be a non natural
 * number its disconsidered*/
typedef struct {
  int roots;
  double solutions[2];
} RootSolutions;

int is_whole(double x) {
  int x_int = (int)x;
  return x_int == x;
}

/** Compute solutions for quadratic / linear equation
 *  the solutions will be floats.
 */
RootSolutions bhaskara(double a, double b, double c) {
  RootSolutions result;
  result.roots = 0;
  if (a == 0 && b == 0 && c == 0) {
    result.roots = -1;
    return result;
  }
  if (a == 0 && b == 0) {
    return result;
  }
  if (a == 0) {
    result.roots = 1;
    result.solutions[0] = -c / b;
    return result;
  }

  double delta = (b * b) - (4 * a * c);
  if (delta < 0) return result;
  if (delta == 0) {
    result.solutions[0] = -b / (2 * a);
    result.roots = 1;
    return result;
  }
  double delta_sqrt = sqrt(delta);

  double nums[] = {-b - delta_sqrt, -b + delta_sqrt};
  double den = 2 * a;

  for (int i = 0; i < 2; ++i) {
    double sol = nums[i] / den;
    if (sol >= 0) result.solutions[result.roots++] = sol;
  }

  return result;
}

RootSolutions reduce_sol(RootSolutions a, RootSolutions b) {
  if (a.roots == -1) return b;
  if (b.roots == -1) return a;
  RootSolutions result;
  result.roots = 0;
  for (int i = 0; i < a.roots; ++i)
    for (int j = 0; j < b.roots; j++)
      if (fabs(a.solutions[i] - b.solutions[j]) < 1e-3)
        result.solutions[result.roots++] = a.solutions[i];
  return result;
}

/** $s(t) = s0 + sum_{i = 1}^{t} v(t), t = 1, 2, ...
 *  v(t) = at + v0
 *  s(t) = s0 + v0t + a t (t + 1) / 2 t = 0, 1, ...
 *  2 s(t) = 2 s0 + 2 v0t + a t² + at
 *  2 s (t) = 2 s0 + t (2 v0 + a) + t² a$
 *
 * It will collide if all coordinates meet at the same time.
 * If a solution has one or more valid solutions return the minimum collision
 * time, if has any solution return 0, no solution -1*/
int collision_time(Particle a, Particle b) {
  RootSolutions result;
  result.roots = -1;
  for (int i = 0; i < 3; ++i) {
    double ad = a.a[i] - b.a[i];
    double vd = a.v[i] - b.v[i];
    double pd = a.p[i] - b.p[i];

    result = reduce_sol(result, bhaskara(ad, 2 * vd + ad, 2 * pd));
    if (result.roots == 0) return -1;
  }
  if (result.roots < 0) {
    printf("Should not happen\n");
    return 0;
  }

  for (int i = 0; i < result.roots; ++i) {
    if (result.solutions[i] >= 0 && is_whole(result.solutions[i]))
      return (int)result.solutions[i];
  }
  return -1;
}

Particle particles[MAX_SIZE];
int nparticles = 0;

int main() {
  int p1 = -1;
  int min_acel = INT_MAX;
  while (!feof(stdin)) {
    Particle part;
    if (fscanf(stdin, "p=<%d,%d,%d>, v=<%d,%d,%d>, a=<%d,%d,%d>\n", &part.p[0],
               &part.p[1], &part.p[2], &part.v[0], &part.v[1], &part.v[2],
               &part.a[0], &part.a[1], &part.a[2]) != 9)
      printf("Fail to parse line\n");
    particles[nparticles] = part;
    int part_acel = distance(part.a);
    if (part_acel < min_acel) {
      min_acel = part_acel;
      p1 = nparticles;
    }
    nparticles++;
  }

  int collided[MAX_SIZE] = {0};
  for (int i = 0; i < nparticles; ++i) {
    if (collided[i]) continue;

    int collision_times[MAX_SIZE] = {0};
    int min_time = INT_MAX;
    for (int j = i + 1; j < nparticles; ++j) {
      if (collided[j]) continue;
      int col_time = collision_time(particles[i], particles[j]);
      collision_times[j] = col_time;
      if (col_time >= 0 && col_time <= min_time) {
        min_time = col_time;
      }
    }

    if (min_time < INT_MAX) {
      collided[i] = 1;
      for (int j = i + 1; j < nparticles; ++j)
        if (collision_times[j] == min_time) collided[j] = 1;
    }
  }

  int p2 = 0;
  for (int i = 0; i < nparticles; ++i) p2 += !collided[i];

  printf("Part1: %d\n", p1);
  printf("Part2: %d\n", p2);
  return 0;
}
