import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

public class day11 {
  private static Map<String, Long> memo = new HashMap<>();

  public static void main(String[] args) {
    long p1 = 0;
    long p2 = 0;

    Scanner scanner = new Scanner(System.in);

    HashMap<String, String[]> connections = new HashMap<>();

    while (scanner.hasNextLine()) {
      String line = scanner.nextLine().trim();
      if (line.isEmpty())
        break;

      String[] parts = line.split(": ");
      String origin = parts[0];
      String[] destinations = parts[1].split(" ");

      connections.put(origin, destinations);
    }
    scanner.close();

    p1 = countConnections(connections, "you", "out", true, true);
    p2 = countConnections(connections, "svr", "out", false, false);

    System.out.println(p1);
    System.out.println(p2);
  }

  private static long countConnections(HashMap<String, String[]> connections, String from, String to,
      boolean visitedDac, boolean visitedFft) {
    if (from.equals(to)) {
      return visitedDac && visitedFft ? 1L : 0L;
    }

    String key = from + (visitedDac ? "1" : "0") + (visitedFft ? "1" : "0");
    if (memo.containsKey(key)) {
      return memo.get(key);
    }

    if (from.equals("dac")) {
      visitedDac = true;
    } else if (from.equals("fft")) {
      visitedFft = true;
    }

    long result = 0L;
    for (String neighbor : connections.get(from)) {
      result += countConnections(connections, neighbor, to, visitedDac, visitedFft);
    }

    memo.put(key, result);

    return result;
  }
}
