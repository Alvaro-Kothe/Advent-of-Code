import java.util.Scanner;

public class day02 {
  public static void main(String[] args) {
    long p1 = 0;
    long p2 = 0;
    Scanner scanner = new Scanner(System.in);

    scanner.useDelimiter(",");

    while (scanner.hasNext()) {
      String token = scanner.next().trim();
      if (token.isEmpty())
        continue;

      String[] parts = token.split("-");
      long start = Long.parseLong(parts[0]);
      long end = Long.parseLong(parts[1]);
      long[] result = processRange(start, end);
      p1 += result[0];
      p2 += result[1];
    }
    scanner.close();

    System.out.println(p1);
    System.out.println(p2);
  }

  private static long[] processRange(long start, long end) {
    long[] result = new long[] { 0, 0 };
    for (long i = start; i <= end; i++) {
      int ndigits = 0;
      for (long n = i; n > 0; n /= 10)
        ndigits++;

      for (int subSeqSize = ndigits / 2; subSeqSize > 0; subSeqSize--) {
        if (ndigits % subSeqSize != 0)
          continue;

        long p10 = 1;
        for (int j = 0; j < subSeqSize; j++)
          p10 *= 10;

        long subseq = i % p10;
        long n = i;
        while (n % p10 == subseq)
          n /= p10;

        if (n == 0) {
          result[0] += ndigits % 2 == 0 && subSeqSize == ndigits / 2 ? i : 0;
          result[1] += i;
          break;
        }
      }
    }
    return result;
  }
}
