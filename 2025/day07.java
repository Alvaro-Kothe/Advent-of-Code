import java.util.Scanner;

public class day07 {
  public static void main(String[] args) {
    long p1 = 0;
    long p2 = 0;
    Scanner scanner = new Scanner(System.in);

    String level = scanner.nextLine().trim();
    long[] beams = new long[level.length()];

    int startPos = level.indexOf('S');
    beams[startPos] = 1L;

    while (scanner.hasNextLine()) {
      level = scanner.nextLine().trim();
      if (level.isEmpty())
        break;

      for (int i = 0; i < level.length(); i++) {
        if (level.charAt(i) == '^') {
          p1++;
          beams[i - 1] += beams[i];
          beams[i + 1] += beams[i];

          beams[i] = 0L;
        }
      }
    }
    scanner.close();

    for (long v : beams)
      p2 += v;

    System.out.println(p1);
    System.out.println(p2);
  }
}
