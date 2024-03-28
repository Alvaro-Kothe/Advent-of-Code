package main

import (
	"fmt"
	"io"
)

func main() {
	containers := []int{}
	for {
		var num int
		_, err := fmt.Scanf("%d", &num)
		if err == io.EOF {
			break
		} else if err != nil {
			panic(err)
		}
		containers = append(containers, num)
	}
	p1, minComb := countCombinations(containers, 150)
	p2 := countCombinationsWith(containers, 150, 0, minComb)
	fmt.Println("Part1:", p1)
	fmt.Println("Part2:", p2)
}

func combinationsAux(arr []int, target, index, minAmount, containers int) (int, int) {
	if target == 0 {
		return 1, containers
	}
	if target < 0 || index >= len(arr) {
		return 0, len(arr)
	}

	countTake, amountTake := combinationsAux(arr, target-arr[index], index+1, minAmount, containers+1)
	countSkip, amountSkip := combinationsAux(arr, target, index+1, minAmount, containers)
	minAmount = min(minAmount, amountSkip, amountTake)
	return countTake + countSkip, minAmount
}

func countCombinationsWith(arr []int, target, index, remaining int) int {
	if target == 0 && remaining == 0 {
		return 1
	}
	if target <= 0 || remaining <= 0 || index >= len(arr) {
		return 0
	}
	countTake := countCombinationsWith(arr, target-arr[index], index+1, remaining-1)
	countSkip := countCombinationsWith(arr, target, index+1, remaining)
	return countTake + countSkip
}

func countCombinations(arr []int, target int) (int, int) {
	return combinationsAux(arr, target, 0, len(arr), 0)
}
