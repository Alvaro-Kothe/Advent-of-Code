package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
)

func computeDistance(route []string, distances map[string]map[string]int) int {
	distance := 0
	for i := 0; i < len(route)-1; i++ {
		src, dst := route[i], route[i+1]
		distance += distances[src][dst]
	}
	return distance
}

func main() {

	distances, places := parseData()

	permutations := generatePermutations(places)
	minDistance, maxDistance := math.MaxInt, 0
	for route := range permutations {
		minDistance = min(minDistance, computeDistance(route, distances))
		maxDistance = max(maxDistance, computeDistance(route, distances))
	}
	fmt.Println("Part1:", minDistance)
	fmt.Println("Part2:", maxDistance)
}

func parseData() (map[string]map[string]int, []string) {
	scanner := bufio.NewScanner(os.Stdin)
	distances := make(map[string]map[string]int)
	placesSet := make(map[string]bool)

	for scanner.Scan() {
		var src, dst string
		var dist int
		fmt.Sscanf(scanner.Text(), "%s to %s = %d", &src, &dst, &dist)
		if distances[src] == nil {
			distances[src] = make(map[string]int)
		}
		if distances[dst] == nil {
			distances[dst] = make(map[string]int)
		}

		distances[src][dst] = dist
		distances[dst][src] = dist
		placesSet[src] = true
		placesSet[dst] = true
	}
	placesSlice := []string{}
	for place := range placesSet {
		placesSlice = append(placesSlice, place)
	}

	return distances, placesSlice
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
