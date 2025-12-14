import java.util.ArrayList;
import java.util.PriorityQueue;
import java.util.Scanner;

class Distance implements Comparable<Distance> {
  long distance;
  int index1, index2;

  Distance(long d, int i1, int i2) {
    distance = d;
    index1 = i1;
    index2 = i2;
  }

  @Override
  public int compareTo(Distance other) {
    return Long.compare(this.distance, other.distance);
  }
}

public class day08 {
  public static void main(String[] args) {
    long p1 = 0;
    long p2 = 0;

    Scanner scanner = new Scanner(System.in);

    PriorityQueue<Distance> distances = new PriorityQueue<>();
    ArrayList<int[]> coordinates = new ArrayList<>();

    int n = 0;
    while (scanner.hasNextLine()) {
      String line = scanner.nextLine().trim();
      if (line.isEmpty())
        break;

      String[] coordStr = line.split(",");

      int[] coord = new int[3];
      for (int i = 0; i < 3; i++)
        coord[i] = Integer.parseInt(coordStr[i]);

      for (int i = 0; i < coordinates.size(); i++) {
        long eucDist = 0;
        int[] point = coordinates.get(i);

        for (int dim = 0; dim < 3; dim++) {
          long d = coord[dim] - point[dim];
          eucDist += d * d;
        }

        Distance distance = new Distance(eucDist, i, n);
        distances.add(distance);
      }
      coordinates.add(coord);
      n++;
    }
    scanner.close();

    int[] clusters = new int[n];
    int[] sizes = new int[n];

    for (int i = 0; i < n; i++) {
      clusters[i] = i;
      sizes[i] = 1;
    }

    int connections = 1;
    for (int i = 0; connections < n; i++) {
      Distance distance = distances.poll();
      connections += union(clusters, sizes, distance.index1, distance.index2);
      if (i == 999) {
        p1 = prodTop3Sizes(clusters, sizes);
      }
      if (connections == n) {
        p2 = (long) coordinates.get(distance.index1)[0] * (long) coordinates.get(distance.index2)[0];
      }
    }

    System.out.println(p1);
    System.out.println(p2);
  }

  private static long prodTop3Sizes(int[] clusters, int[] sizes) {
    long a = 0;
    long b = 0;
    long c = 0;

    for (int i = 0; i < clusters.length; i++) {
      if (clusters[i] == i) {
        int size = sizes[i];
        if (size > a) {
          c = b;
          b = a;
          a = size;
        } else if (size > b) {
          c = b;
          b = size;
        } else if (size > c) {
          c = size;
        }
      }
    }

    return a * b * c;
  }

  private static int find(int[] parent, int idx) {
    while (parent[idx] != idx) {
      parent[idx] = parent[parent[idx]];
      idx = parent[idx];
    }
    return idx;
  }

  private static int union(int[] parent, int[] sizes, int idx1, int idx2) {
    int x = find(parent, idx1);
    int y = find(parent, idx2);
    if (x == y)
      return 0;

    if (sizes[x] < sizes[y]) {
      int tmp = x;
      x = y;
      y = tmp;
    }

    parent[y] = x;
    sizes[x] += sizes[y];
    return 1;
  }
}
