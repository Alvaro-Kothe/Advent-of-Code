import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Scanner;
import java.util.Deque;

public class day04 {
  public static void main(String[] args) {
    ArrayList<ArrayList<Boolean>> grid = parseInput();
    Deque<int[]> stack = new ArrayDeque<int[]>(2048);

    int p1 = getAccessible(grid, stack);
    int p2 = p1;

    while (!stack.isEmpty()) {
      updateGrid(grid, stack);
      p2 += getAccessible(grid, stack);
    }

    System.out.println(p1);
    System.out.println(p2);
  }

  private static void updateGrid(ArrayList<ArrayList<Boolean>> grid, Deque<int[]> stack) {
    while (!stack.isEmpty()) {
      int[] pos = stack.pop();
      grid.get(pos[0]).set(pos[1], false);
    }
  }

  private static int getAccessible(ArrayList<ArrayList<Boolean>> grid, Deque<int[]> stack) {
    int result = 0;
    for (int i = 0; i < grid.size(); i++) {
      for (int j = 0; j < grid.get(i).size(); j++) {
        if (!grid.get(i).get(j))
          continue;
        int nNeighbors = countNeighbors(grid, i, j);

        if (nNeighbors < 4) {
          stack.add(new int[] { i, j });
          result += 1;
        }
      }
    }
    return result;
  }

  private static int countNeighbors(ArrayList<ArrayList<Boolean>> grid, int row, int col) {
    int result = 0;

    for (int i = -1; i <= 1; i++) {
      if (row + i < 0 || row + i >= grid.size())
        continue;
      for (int j = -1; j <= 1; j++) {
        if ((i == 0 && j == 0) || col + j < 0 || col + j >= grid.get(row + i).size())
          continue;

        result += grid.get(row + i).get(col + j) ? 1 : 0;
      }
    }

    return result;
  }

  private static ArrayList<ArrayList<Boolean>> parseInput() {
    ArrayList<ArrayList<Boolean>> result = new ArrayList<>();

    Scanner scanner = new Scanner(System.in);
    while (scanner.hasNextLine()) {
      String line = scanner.nextLine().trim();
      if (line.isEmpty())
        continue;

      ArrayList<Boolean> row = new ArrayList<Boolean>(line.length());

      for (int i = 0; i < line.length(); i++) {
        Boolean isRoll = line.charAt(i) == '@';
        row.add(isRoll);
      }
      result.add(row);
    }
    scanner.close();

    return result;
  }
}
