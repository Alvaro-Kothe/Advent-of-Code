import java.util.ArrayList;
import java.util.PriorityQueue;
import java.util.Scanner;

public class day09 {
  private static class Point {
    long x, y;

    Point(long x, long y) {
      this.x = x;
      this.y = y;
    }
  }

  private static class Rectangle {
    long x1, x2, y1, y2, area;

    Rectangle(long x1, long x2, long y1, long y2) {
      if (x2 < x1) {
        long tmp = x1;
        x1 = x2;
        x2 = tmp;
      }
      if (y2 < y1) {
        long tmp = y1;
        y1 = y2;
        y2 = tmp;
      }
      this.x1 = x1;
      this.y1 = y1;
      this.x2 = x2;
      this.y2 = y2;
      this.area = (x2 - x1 + 1) * (y2 - y1 + 1);
    }
  }

  public static void main(String[] args) {
    long p1 = 0;
    long p2 = 0;

    Scanner scanner = new Scanner(System.in);

    ArrayList<Point> polygon = new ArrayList<>();
    PriorityQueue<Rectangle> rectangles = new PriorityQueue<>((a, b) -> Long.compare(b.area, a.area));
    while (scanner.hasNextLine()) {
      String line = scanner.nextLine().trim();
      if (line.isEmpty())
        break;

      String[] coordStr = line.split(",");

      long x = Long.parseLong(coordStr[0]);
      long y = Long.parseLong(coordStr[1]);
      Point point = new Point(x, y);

      for (int i = 0; i < polygon.size(); i++) {
        Point polPoint = polygon.get(i);
        Rectangle rectangle = new Rectangle(polPoint.x, point.x, polPoint.y, point.y);
        rectangles.add(rectangle);
      }

      polygon.add(point);
    }
    scanner.close();

    p1 = rectangles.peek().area;

    while (!rectangles.isEmpty() && !isContained(rectangles.peek(), polygon)) {
      rectangles.remove();
    }
    p2 = rectangles.peek().area;

    System.out.println(p1);
    System.out.println(p2);
  }

  private static boolean isContained(Rectangle rectangle, ArrayList<Point> polygon) {
    for (int i = 0; i < polygon.size(); i++) {
      int j = (i + 1) % polygon.size();
      Point edge1 = polygon.get(i);
      Point edge2 = polygon.get(j);

      if (Math.max(edge1.x, edge2.x) > rectangle.x1 && rectangle.x2 > Math.min(edge1.x, edge2.x) &&
          Math.max(edge1.y, edge2.y) > rectangle.y1 && rectangle.y2 > Math.min(edge1.y, edge2.y)) {
        return false;
      }
    }
    return true;
  }
}
