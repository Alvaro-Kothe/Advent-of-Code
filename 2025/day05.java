import java.util.ArrayList;
import java.util.Arrays;
import java.util.Scanner;

public class day05 {
  public static void main(String[] args) {
    long p1 = 0;
    long p2 = 0;

    Scanner scanner = new Scanner(System.in);

    long[][] ranges = parseRange(scanner);
    Long[] queries = parseQueries(scanner);

    scanner.close();

    long[][] rangesMerged = mergeRanges(ranges);

    for (long query : queries) {
      p1 += isInRange(rangesMerged, query) ? 1 : 0;
    }

    for (long[] range : rangesMerged) {
      long left = range[0];
      long right = range[1];

      p2 += right - left + 1;
    }

    System.out.println(p1);
    System.out.println(p2);
  }

  private static boolean isInRange(long[][] ranges, long query) {
    int left = 0;
    int right = ranges.length;

    while (left < right) {
      int mid = left + (right - left) / 2;

      long value = ranges[mid][0];

      if (value <= query) {
        left = mid + 1;
      } else {
        right = mid;
      }
    }

    if (right <= 0)
      return false;
    long[] range = ranges[right - 1];
    return range[0] <= query && query <= range[1];
  }

  private static long[][] mergeRanges(long[][] ranges) {
    ArrayList<long[]> result = new ArrayList<long[]>();
    Arrays.sort(ranges, (a, b) -> Long.compare(a[0], b[0]));

    for (long[] range : ranges) {
      if (result.isEmpty() || result.get(result.size() - 1)[1] < range[0]) {
        result.add(range);
      } else {
        result.get(result.size() - 1)[1] = Math.max(
            result.get(result.size() - 1)[1],
            range[1]);
      }
    }

    return result.toArray(new long[result.size()][2]);
  }

  private static long[][] parseRange(Scanner scanner) {
    ArrayList<long[]> result = new ArrayList<long[]>(100);

    while (scanner.hasNextLine()) {
      String line = scanner.nextLine().trim();
      if (line.isEmpty())
        break;

      String[] parts = line.split("-");
      long left = Long.parseLong(parts[0]);
      long right = Long.parseLong(parts[1]);

      result.add(new long[] { left, right });
    }
    return result.toArray(new long[result.size()][2]);
  }

  private static Long[] parseQueries(Scanner scanner) {
    ArrayList<Long> result = new ArrayList<>(500);

    while (scanner.hasNextLong()) {
      result.add(scanner.nextLong());
    }

    return result.toArray(new Long[result.size()]);
  }
}
