package main

import "fmt"

func main() {
	var password string
	fmt.Scanln(&password)
	p1 := getNextValidPassword(password)
	p2 := getNextValidPassword(p1)
	fmt.Println("Part1:", p1)
	fmt.Println("Part2:", p2)
}

func getNextValidPassword(s string) string {
	for {
		s = getNextPassword(s)
		if isValidPassword(s) {
			return s
		}
	}
}

func getNextPassword(s string) string {
	result := []byte(s)
	for i := len(result) - 1; i >= 0; i-- {
		if result[i] == 'z' {
			result[i] = 'a'
		} else {
			result[i]++
			break
		}
	}
	return string(result)
}

func isValidPassword(s string) bool {
	return !containsBlackListed(s) && countUniquePairs(s) >= 2 && containsSequence(s)
}

func containsSequence(s string) bool {
	for i := 0; i < len(s)-2; i++ {
		if s[i]+1 == s[i+1] && s[i+1]+1 == s[i+2] {
			return true
		}
	}
	return false
}

func countUniquePairs(s string) int {
	seen := make(map[byte]bool)
	for i := 0; i < len(s)-1; i++ {
		if s[i] == s[i+1] {
			seen[s[i]] = true
			i++
		}
	}
	return len(seen)
}

func containsBlackListed(s string) bool {
	for _, c := range s {
		if c == 'l' || c == 'o' || c == 'i' {
			return true
		}
	}
	return false
}
