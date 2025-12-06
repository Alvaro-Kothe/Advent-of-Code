import java.util.Scanner;

public class day01 {
  public static void main(String[] args) {
    int dial_point = 50;
    int p1 = 0;
    int p2 = 0;
    Scanner scanner = new Scanner(System.in);

    while (scanner.hasNextLine()) {
      String s = scanner.nextLine().trim();
      if (s.length() == 0) {
        continue;
      }

      char direction = s.charAt(0);
      int distance = Integer.parseInt(s.substring(1));

      p2 += distance / 100;
      distance %= 100;

      int old_position = dial_point;
      switch (direction) {
        case 'L':
          dial_point -= distance;
          break;
        case 'R':
          dial_point += distance;
          break;
      }

      if (old_position != 0 && (dial_point <= 0 || dial_point >= 100)) {
        p2 += 1;
      }

      dial_point = (dial_point + 100) % 100;

      p1 += dial_point == 0 ? 1 : 0;
    }
    scanner.close();

    System.out.println(p1);
    System.out.println(p2);
  }
}
