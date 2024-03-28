package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func computeDistance(arrangement []string, costs map[string]map[string]int) int {
	distance := 0
	size := len(arrangement)
	for i := 0; i < size; i++ {
		curPerson := arrangement[i]
		curPersonCosts := costs[curPerson]
		if curPersonCosts == nil {
			continue
		}
		left, right := ((i-1)%size+size)%size, (i+1)%size
		personLeft, personRight := arrangement[left], arrangement[right]
		distance += curPersonCosts[personLeft] + curPersonCosts[personRight]
	}
	return distance
}

func main() {
	costs, people := parseData()

	permutations := generatePermutations(people)
	maxCost := 0
	for arrangement := range permutations {
		maxCost = max(maxCost, computeDistance(arrangement, costs))
	}

	people = append(people, "me")
	permutations = generatePermutations(people)
	maxCost2 := 0
	for arrangement := range permutations {
		maxCost2 = max(maxCost2, computeDistance(arrangement, costs))
	}

	fmt.Println("Part1:", maxCost)
	fmt.Println("Part2:", maxCost2)
}

func parseData() (map[string]map[string]int, []string) {
	scanner := bufio.NewScanner(os.Stdin)
	costs := make(map[string]map[string]int)
	uniqueValues := make(map[string]bool)

	for scanner.Scan() {
		var src, dst, gainOrLose string
		var dist int
		fmt.Sscanf(scanner.Text(), "%s would %s %d happiness units by sitting next to %s.", &src, &gainOrLose, &dist, &dst)
		dst = strings.TrimRight(dst, ".")
		if costs[src] == nil {
			costs[src] = make(map[string]int)
		}
		if gainOrLose == "lose" {
			dist = -dist
		}

		costs[src][dst] = dist
		uniqueValues[src] = true
		uniqueValues[dst] = true
	}
	unique := []string{}
	for place := range uniqueValues {
		unique = append(unique, place)
	}

	return costs, unique
}

func generatePermutations[T any](arr []T) <-chan []T {
	permutations := make(chan []T)

	go func() {
		defer close(permutations)
		heapPermutation(len(arr), arr, permutations)
	}()

	return permutations
}

func heapPermutation[T any](size int, arr []T, permutations chan<- []T) {
	if size == 1 {
		result := make([]T, len(arr))
		copy(result, arr)
		permutations <- result
	} else {
		heapPermutation(size-1, arr, permutations)

		for i := 0; i < size-1; i++ {
			if size%2 == 1 {
				arr[0], arr[size-1] = arr[size-1], arr[0]
			} else {
				arr[i], arr[size-1] = arr[size-1], arr[i]
			}
			heapPermutation(size-1, arr, permutations)
		}
	}
}
