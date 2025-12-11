import java.util.ArrayList;
import java.util.Scanner;

public class day06 {
  public static void main(String[] args) {
    long p1 = 0;
    long p2 = 0;
    Scanner scanner = new Scanner(System.in);

    String[] operations = null;
    ArrayList<ArrayList<Long>> part1Values = new ArrayList<ArrayList<Long>>();
    ArrayList<String> rows = new ArrayList<String>();

    while (scanner.hasNextLine()) {
      String line = scanner.nextLine();
      if (line.trim().isEmpty())
        continue;
      rows.add(line);
      String[] parts = line.trim().split("\\s+");

      if (parts[0].equals("+") || parts[0].equals("*")) {
        operations = parts;
      } else {
        if (part1Values.isEmpty()) {
          for (int i = 0; i < parts.length; i++)
            part1Values.add(new ArrayList<>());
        }

        for (int i = 0; i < parts.length; i++) {
          part1Values.get(i).add(Long.parseLong(parts[i]));
        }
      }
    }
    scanner.close();

    for (int i = 0; i < operations.length; i++) {
      long acc;
      switch (operations[i]) {
        case "+":
          acc = 0;
          for (long value : part1Values.get(i)) {
            acc += value;
          }
          break;
        case "*":
          acc = 1;
          for (long value : part1Values.get(i)) {
            acc *= value;
          }
          break;
        default:
          acc = 0;
          break;
      }
      p1 += acc;
    }

    int[] blocksizes = computeBlockSizes(operations.length, rows);
    p2 = computePart2(blocksizes, operations, rows);

    System.out.println(p1);
    System.out.println(p2);
  }

  private static long computePart2(int[] blocksizes, String[] operations, ArrayList<String> rows) {
    int offset = 0;
    long result = 0;
    for (int k = 0; k < blocksizes.length; k++) {
      long acc = operations[k].equals("+") ? 0 : 1;

      for (int i = 0; i < blocksizes[k]; i++) {
        long value = 0;
        for (int j = 0; j < rows.size() - 1; j++) {
          char c = rows.get(j).charAt(offset + i);
          if (Character.isDigit(c)) {
            value *= 10;
            value += c - '0';
          }
        }
        if (operations[k].equals("+")) {
          acc += value;
        } else {
          acc *= value;
        }
      }
      offset += blocksizes[k] + 1;
      result += acc;
    }
    return result;
  }

  private static int[] computeBlockSizes(int nblocks, ArrayList<String> rows) {
    int[] blocksizes = new int[nblocks];
    int size = 0;
    int block = 0;
    String opRow = rows.get(rows.size() - 1);
    for (int i = 1; i < opRow.length(); i++) {
      switch (opRow.charAt(i)) {
        case '+':
        case '*':
          blocksizes[block] = size;
          block++;
          size = 0;
          break;
        case ' ':
          size++;
          break;
        default:
          break;
      }
    }
    blocksizes[block] = size + 1;

    return blocksizes;
  }
}
