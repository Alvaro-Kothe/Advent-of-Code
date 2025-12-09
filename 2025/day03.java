import java.util.Scanner;

public class day03 {
  public static void main(String[] args) {
    long p1 = 0;
    long p2 = 0;
    Scanner scanner = new Scanner(System.in);

    while (scanner.hasNextLine()) {
      String line = scanner.nextLine().trim();
      if (line.isEmpty())
        continue;
      p1 += findMaxJoltage(line, 2, 0);
      p2 += findMaxJoltage(line, 12, 0);
    }
    scanner.close();

    System.out.println(p1);
    System.out.println(p2);
  }

  private static long findMaxJoltage(String bank, int level, long acc) {
    if (level == 0 || bank.length() < level)
      return acc;
    long p = 1;
    for (int i = 0; i < level - 1; i++) {
      p *= 10;
    }

    int max_idx = 0;
    long max_digit = bank.charAt(0) - '0';
    for (int i = 1; i <= bank.length() - level; i++) {
      int digit = bank.charAt(i) - '0';
      if (digit > max_digit) {
        max_idx = i;
        max_digit = digit;
      }
    }

    return findMaxJoltage(bank.substring(max_idx + 1), level - 1, acc + p * max_digit);
  }
}
