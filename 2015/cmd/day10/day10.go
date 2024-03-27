package main

import (
	"fmt"
	"strings"
)

func main() {
	inp := "1113222113"
	var p1 int
	for i := 0; i < 50; i++ {
		inp = rlEncode(inp)
		if i == 39 {
			p1 = len(inp)
			fmt.Println("Part1:", p1)
		}
	}
	fmt.Println("Part2:", len(inp))
}

func rlEncode(s string) string {
	counter := 1
	var prev rune
	var buffer strings.Builder
	for _, c := range s {
		if c != prev {
			if prev != 0 {
				buffer.WriteString(fmt.Sprintf("%d%c", counter, prev))
			}
			counter = 1
			prev = c
		} else {
			counter++
		}
	}
	buffer.WriteString(fmt.Sprintf("%d%c", counter, prev))
	return buffer.String()
}
