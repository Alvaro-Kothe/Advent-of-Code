import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Queue;
import java.util.Scanner;

public class day10 {
  public static void main(String[] args) {
    long p1 = 0;
    long p2 = 0;

    Scanner scanner = new Scanner(System.in);

    while (scanner.hasNextLine()) {
      String line = scanner.nextLine().trim();
      if (line.isEmpty())
        break;

      String[] parts = line.split(" ");

      int targetState = 0;

      int n = parts[0].length() - 2;
      for (int i = 0; i < n; i++) {
        if (parts[0].charAt(i + 1) == '#')
          targetState |= 1 << i;
      }

      ArrayList<Integer> buttons = new ArrayList<>();
      for (int i = 1; i < parts.length - 1; i++) {
        String s = parts[i];
        Integer mask = 0;
        String[] toggles = s.substring(1, s.length() - 1).split(",");
        for (String idx : toggles) {
          int toggle_idx = Integer.parseInt(idx);
          mask |= 1 << toggle_idx;
        }
        buttons.add(mask);
      }
      String joltString = parts[parts.length - 1];
      String[] joltParts = joltString.substring(1, joltString.length() - 1).split(",");
      int[] joltage = new int[n];
      for (int i = 0; i < joltParts.length; i++) {
        joltage[i] = Integer.parseInt(joltParts[i]);
      }

      p1 += findMinPresses(targetState, n, buttons);
      p2 += solveJoltage(buttons, joltage);
    }
    scanner.close();

    System.out.println(p1);
    System.out.println(p2);
  }

  private static int solveJoltage(ArrayList<Integer> buttons, int[] targetJoltage) {
    // I have a system of equations.
    // A represents the joltage increase when I press a button.
    // x is the number of times that I pressed the button.
    // b is the target joltage (solution).
    // A = [
    // [0, 0, 0, 1]
    // [0, 1, 0, 1]
    // [0, 0, 1, 0]
    // [0, 0, 1, 1]
    // [1, 0, 1, 0]
    // [1, 1, 0, 0]
    // ]
    //
    // I need to solve A^t x = b
    // subject to x >= 0; x is integer
    // I also need to minimize sum(x);
    int ncols = buttons.size();
    int[][] augmentedMatrix = new int[targetJoltage.length][ncols + 1];
    for (int j = 0; j < ncols; j++) {
      for (int i = 0, n = buttons.get(j); n > 0; n >>= 1, i++) {
        augmentedMatrix[i][j] += n & 1;
      }
    }
    for (int i = 0; i < targetJoltage.length; i++) {
      augmentedMatrix[i][ncols] = targetJoltage[i];
    }

    convertToRowEchelon(augmentedMatrix);

    int[] solution = new int[ncols];
    Arrays.fill(solution, -1);

    int upperBound = 0;
    for (int val : targetJoltage) {
      upperBound += val;
    }

    int result = solve(augmentedMatrix, solution, augmentedMatrix.length - 1, 0, upperBound);
    return result;
  }

  private static int solve(int[][] matrix, int[] x, int rowIndex, int currentSum, int best) {
    if (rowIndex < 0) {
      return currentSum;
    }
    if (currentSum >= best) {
      return currentSum;
    }

    int nVars = matrix[0].length - 1;
    int resultIndex = nVars;
    int varToAssign = resultIndex - 1;

    while (varToAssign >= 0 && (x[varToAssign] >= 0 || matrix[rowIndex][varToAssign] == 0)) {
      varToAssign--;
    }

    int partialSum = 0;
    for (int varIdx = 0; varIdx < x.length; varIdx++) {
      if (x[varIdx] >= 0) {
        partialSum += matrix[rowIndex][varIdx] * x[varIdx];
      }
    }

    if (varToAssign < 0) {
      if (partialSum != matrix[rowIndex][resultIndex]) {
        return Integer.MAX_VALUE;
      }
      return solve(matrix, x, rowIndex - 1, currentSum, best);
    }

    boolean isPivot = true;
    for (int col = varToAssign - 1; col >= 0 && isPivot; col--) {
      if (matrix[rowIndex][col] != 0) {
        isPivot = false;
      }
    }

    int numerator = matrix[rowIndex][resultIndex] - partialSum;

    if (isPivot) {
      // backward substitution
      if (numerator % matrix[rowIndex][varToAssign] != 0) {
        return Integer.MAX_VALUE;
      }

      x[varToAssign] = numerator / matrix[rowIndex][varToAssign];
      if (x[varToAssign] < 0) {
        return Integer.MAX_VALUE;
      }

      int result = solve(matrix, x, rowIndex - 1, currentSum + x[varToAssign], best);

      x[varToAssign] = -1;
      return result;
    }

    boolean hasOppositeSign = false;
    for (int col = varToAssign - 1; col >= 0; col--) {
      if (x[col] < 0 && matrix[rowIndex][col] != 0 && (matrix[rowIndex][col] ^ matrix[rowIndex][varToAssign]) < 0) {
        hasOppositeSign = true;
        break;
      }
    }

    if (!hasOppositeSign) {
      if (matrix[rowIndex][varToAssign] > 0 && numerator < 0) {
        return Integer.MAX_VALUE;
      }
      if (matrix[rowIndex][varToAssign] < 0 && numerator > 0) {
        return Integer.MAX_VALUE;
      }
    }

    int maxValue = hasOppositeSign ? best : numerator / matrix[rowIndex][varToAssign];

    if (maxValue < 0) {
      maxValue = -maxValue;
    }

    for (int value = 0; value <= maxValue; value++) {
      x[varToAssign] = value;
      int branchValue = solve(matrix, x, rowIndex, currentSum + value, best);
      if (branchValue < best) {
        best = branchValue;
      }
    }
    x[varToAssign] = -1;

    return best;
  }

  private static void convertToRowEchelon(int[][] matrix) {
    int rows = matrix.length;
    int cols = matrix[0].length;

    int pivotCol = 0;

    for (int i = 0; i < rows; i++) {
      if (pivotCol >= cols - 1) {
        break;
      }

      int pivot = i;
      while (pivot < rows && matrix[pivot][pivotCol] == 0) {
        pivot++;
      }

      if (pivot >= rows) {
        pivotCol++;
        i--; // keep looking at same row
        continue;
      }

      swapRows(matrix, pivot, i);

      for (int row = i + 1; row < rows; row++) {
        if (matrix[row][pivotCol] == 0)
          continue;

        int pivotValue = matrix[i][pivotCol];
        int rowValue = matrix[row][pivotCol];

        for (int col = pivotCol; col < cols; col++) {
          matrix[row][col] = matrix[row][col] * pivotValue - matrix[i][col] * rowValue;
        }
      }

      pivotCol++;
    }
  }

  private static void swapRows(int[][] matrix, int r1, int r2) {
    if (r1 == r2)
      return;

    for (int i = 0; i < matrix[r1].length; i++) {
      int tmp = matrix[r1][i];
      matrix[r1][i] = matrix[r2][i];
      matrix[r2][i] = tmp;
    }
  }

  private static int findMinPresses(int target, int nLights, ArrayList<Integer> buttons) {
    Queue<Integer> queue = new ArrayDeque<>();
    int[] stepsToState = new int[1 << nLights];
    for (int i = 1; i < stepsToState.length; i++) {
      stepsToState[i] = -1;
    }

    queue.add(0);

    while (!queue.isEmpty()) {
      int currentState = queue.poll();

      if (currentState == target) {
        return stepsToState[currentState];
      }

      for (Integer button : buttons) {
        int nextState = currentState ^ button;
        if (stepsToState[nextState] < 0) {
          stepsToState[nextState] = stepsToState[currentState] + 1;
          queue.add(nextState);
        }
      }
    }

    return -1;
  }
}
