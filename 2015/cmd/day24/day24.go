package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strconv"
)

func main() {
	packages := make([]int, 0, 30)
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		num, err := strconv.Atoi(scanner.Text())
		if err != nil {
			panic(err)
		}
		packages = append(packages, num)
	}

	p1 := divideIn(packages, 3)
	fmt.Println("Part1:", p1)
	p2 := divideIn(packages, 4)
	fmt.Println("Part2:", p2)
}

func divideIn(arr []int, parts int) int {
	targetSum := sum(arr) / parts
	return findBestDivision(arr, targetSum, parts)
}

func findBestDivision(arr []int, targetSum, parts int) int {
	foundMinGroups := false
	minProd := math.MaxInt
	for elementsPerGroup := 1; elementsPerGroup <= len(arr); elementsPerGroup++ {
		if foundMinGroups {
			return minProd
		}
		for group := range getCombinations(arr, elementsPerGroup) {
			if sum(group) == targetSum && prod(group) < minProd {
				remaining := sliceDiff(group, arr)
				if canDivide(remaining, targetSum, parts-1, elementsPerGroup) {
					foundMinGroups = true
					minProd = min(minProd, prod(group))
				}
			}
		}
	}
	return minProd
}

func canDivide(arr []int, targetSum, parts, start int) bool {
	if parts == 0 || (parts == 1 && sum(arr) == targetSum) {
		return true
	}
	for i := start; i <= len(arr); i++ {
		for group := range getCombinations(arr, i) {
			if sum(group) == targetSum {
				remaining := sliceDiff(group, arr)
				if canDivide(remaining, targetSum, parts-1, i) {
					return true
				}
			}
		}
	}
	return false
}

func sliceDiff(a, b []int) []int {
	result := make([]int, len(b)-len(a))
	if len(result) == 0 {
		return result
	}
	removedElements := make(map[int]int)
	for _, v := range a {
		removedElements[v]++
	}
	i := 0
	for _, keptElement := range b {
		if removedElements[keptElement] > 0 {
			removedElements[keptElement]--
		} else {
			result[i] = keptElement
			i++
		}
	}
	return result
}

func hasElement(x int, arr []int) bool {
	for _, v := range arr {
		if v == x {
			return true
		}
	}
	return false
}

func getCombinations(arr []int, k int) <-chan []int {
	c := make(chan []int)
	go func() {
		defer close(c)
		comb := make([]int, k)
		generateCombinations(arr, k, c, comb, 0, 0)
	}()
	return c
}

func generateCombinations(arr []int, size int, c chan<- []int, combination []int, start, index int) {
	if index == size {
		result := make([]int, size)
		copy(result, combination)
		c <- result
		return
	}

	for i := start; i < len(arr); i++ {
		combination[index] = arr[i]
		generateCombinations(arr, size, c, combination, i+1, index+1)
	}
}

func prod(arr []int) int {
	result := 1
	for _, v := range arr {
		result *= v
	}
	return result
}

func sum(arr []int) int {
	result := 0
	for _, v := range arr {
		result += v
	}
	return result
}
