import java.util.Scanner;

public class day12 {
  public static void main(String[] args) {
    long p1 = 0;

    Scanner scanner = new Scanner(System.in);

    while (scanner.hasNextLine()) {
      String line = scanner.nextLine().trim();
      if (line.isEmpty())
        continue;

      if (line.contains("x")) {
        String[] parts = line.split(": ");
        String[] widthHeight = parts[0].split("x");
        int width = Integer.parseInt(widthHeight[0]);
        int height = Integer.parseInt(widthHeight[1]);

        String[] shapeQuantities = parts[1].split(" ");

        int shapeAmmount = 0;
        for (String s : shapeQuantities) {
          shapeAmmount += Integer.parseInt(s);
        }

        if (width * height >= 9 * shapeAmmount) {
          p1 += 1;
        }
      }
    }
    scanner.close();

    System.out.println(p1);
  }
}
