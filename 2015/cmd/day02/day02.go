package main

import (
	"fmt"
	"slices"
)

func main() {
	var l int
	var w int
	var h int

	p1 := 0
	p2 := 0

	for {
		if _, err := fmt.Scanf("%dx%dx%d", &l, &w, &h); err != nil {
			break
		} else {
			p1 += neededWrappingPaper(l, w, h)
			p2 += neededRibbon(l, w, h)
		}
	}
	fmt.Println("Part1:", p1)
	fmt.Println("Part2:", p2)
}

func sum(args ...int) int {
	result := 0
	for _, v := range args {
		result += v
	}
	return result
}

func computeSideAreas(l, w, h int) []int {
	return []int{l * w, w * h, h * l}
}

func neededWrappingPaper(l, w, h int) int {
	sideAreas := computeSideAreas(l, w, h)
	return 2*sum(sideAreas...) + slices.Min(sideAreas)
}

func neededRibbon(l, w, h int) int {
	return 2*min(l+w, l+h, w+h) + (l * w * h)
}
