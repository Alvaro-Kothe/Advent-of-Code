package main

import "fmt"

func main() {
	var inp int
	inp = 33100000

	p1 := findLowestHouseWithMinPresents(inp, 10, inp)
	fmt.Println("Part1:", p1)
	p2 := findLowestHouseWithMinPresents(inp, 11, 50)
	fmt.Println("Part2:", p2)
}

func presentsReceived(n, multiplier, maxPrev int) int {
	return sumFactors(n, maxPrev) * multiplier
}

func findLowestHouseWithMinPresents(target, multiplier, maxPrev int) int {
	for i := 1; ; i++ {
		if presentsReceived(i, multiplier, maxPrev) >= target {
			return i
		}
	}
}

func sumFactors(n, maxPrev int) int {
	result := 0

	i := 1
	for ; i*i < n; i++ {
		if n%i == 0 {
			if i*maxPrev >= n {
				result += i
			}
			if (n/i)*maxPrev >= n {
				result += n / i
			}
		}
	}
	if i*i == n {
		result += i
	}
	return result
}
