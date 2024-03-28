package main

import (
	"bufio"
	"fmt"
	"os"
)

type Reindeer struct {
	speed        int
	flyDuration  int
	restDuration int
}

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	var reindeers []Reindeer
	for scanner.Scan() {
		var name string
		var speed, flyDuration, restDuration int
		fmt.Sscanf(scanner.Text(), "%s can fly %d km/s for %d seconds, but then must rest for %d seconds.",
			&name, &speed, &flyDuration, &restDuration)
		reindeers = append(reindeers, Reindeer{speed, flyDuration, restDuration})
	}
	maxDistance := 0
	for _, r := range reindeers {
		distance := calculateDistance(r, 2503)
		if distance > maxDistance {
			maxDistance = distance
		}
	}

	scores := getScores(reindeers, 2503)
	p2 := maxSlice(scores)
	fmt.Println("Part1:", maxDistance)
	fmt.Println("Part2:", p2)
}

func getScores(reindeers []Reindeer, totalTime int) []int {
	scores := make([]int, len(reindeers))
	for t := 1; t <= totalTime; t++ {
		leading := []int{}
		leadingDistance := 0

		for i, r := range reindeers {
			distance := calculateDistance(r, t)
			if distance > leadingDistance {
				leading = []int{i}
				leadingDistance = distance
			} else if distance == leadingDistance {
				leading = append(leading, i)
			}
		}

		for _, leadingIdx := range leading {
			scores[leadingIdx]++
		}
	}
	return scores
}

func maxSlice(arr []int) int {
	result := arr[0]
	for i := 1; i < len(arr); i++ {
		result = max(result, arr[i])
	}
	return result
}

func calculateDistance(r Reindeer, totalTime int) int {
	cycleTime := r.flyDuration + r.restDuration
	fullCycles := totalTime / cycleTime
	remainingTime := totalTime % cycleTime

	flyTime := r.flyDuration * fullCycles
	if remainingTime > r.flyDuration {
		flyTime += r.flyDuration
	} else {
		flyTime += remainingTime
	}

	return flyTime * r.speed
}
