package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	totalCodeChars := 0
	totalMemoryChars := 0
	totalEncodedChars := 0

	for scanner.Scan() {
		line := scanner.Text()
		codeChars, memoryChars := countCharacters(line)
		totalEncodedChars += len(encode(line))
		totalCodeChars += codeChars
		totalMemoryChars += memoryChars
	}

	fmt.Println("Part1:", totalCodeChars-totalMemoryChars)
	fmt.Println("Part2:", totalEncodedChars-totalCodeChars)
}

func countCharacters(s string) (int, int) {
	codeChars := len(s)
	inMemoryChars := 0
	i := 1
	for i < len(s)-1 {
		if s[i] == '\\' {
			if s[i+1] == '\\' || s[i+1] == '"' {
				i += 2
			} else if s[i+1] == 'x' {
				i += 4
			}
		} else {
			i++
		}
		inMemoryChars++
	}
	return codeChars, inMemoryChars
}

func encode(s string) string {
	result := `"`
	for _, c := range s {
		switch c {
		case '\\':
			result += `\\`
		case '"':
			result += `\"`
		default:
			result += string(c)
		}
	}
	result += `"`
	return result
}
