package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)

	niceCount := 0
	niceCount2 := 0
	for scanner.Scan() {
		line := scanner.Text()
		if isNice(line) {
			niceCount++
		}
		if isNice2(line) {
			niceCount2++
		}
	}

	fmt.Println("Part1:", niceCount)
	fmt.Println("Part2:", niceCount2)
}

func isNice(s string) bool {
	vowelCount := 0
	for _, ch := range s {
		switch ch {
		case 'a', 'e', 'i', 'o', 'u':
			vowelCount++
		}
		if vowelCount >= 3 {
			break
		}
	}
	if vowelCount < 3 {
		return false
	}

	hasDouble := false
	for i := 0; i < len(s)-1; i++ {
		if s[i] == s[i+1] {
			hasDouble = true
			break
		}
	}
	if !hasDouble {
		return false
	}

	disallowed := []string{"ab", "cd", "pq", "xy"}
	for _, substr := range disallowed {
		if strings.Contains(s, substr) {
			return false
		}
	}

	return true
}

func isNice2(s string) bool {
	return repeatWithOneBetween(s) && containsPairTwice(s)
}

func repeatWithOneBetween(s string) bool {
	for i := 0; i < len(s)-2; i++ {
		if s[i] == s[i+2] {
			return true
		}
	}
	return false
}

func containsPairTwice(s string) bool {
	for i := 0; i < len(s)-1; i++ {
		pair := s[i : i+2]
		if findPairAfter(s, pair, i+2) {
			return true
		}
	}
	return false
}

func findPairAfter(s, pair string, idx int) bool {
	for i := idx; i < len(s)-len(pair)+1; i++ {
		if s[i:i+len(pair)] == pair {
			return true
		}
	}
	return false
}
