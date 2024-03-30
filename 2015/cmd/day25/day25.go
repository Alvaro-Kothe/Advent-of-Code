package main

import "fmt"

func main() {
	targetRow, targetCol := 2981, 3075
	code := uint(20151125)
	targetIndex := getIndex(targetRow, targetCol)
	for i := 2; i <= targetIndex; i++ {
		code = computeCode(code)
	}
	fmt.Println("Part1:", code)
}

func computeCode(code uint) uint {
	return code * 252533 % 33554393
}

func getIndex(row, col int) int {
	n := row + col - 2
	return n*(n+1)/2 + col
}
