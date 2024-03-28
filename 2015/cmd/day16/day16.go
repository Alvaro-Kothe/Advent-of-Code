package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	aunts := parseData()
	criteria := map[string]int{"children": 3, "cats": 7, "samoyeds": 2,
		"pomeranians": 3, "akitas": 0, "vizslas": 0,
		"goldfish": 5, "trees": 3, "cars": 2, "perfumes": 1}
	p1 := findAunt(aunts, criteria, false)
	p2 := findAunt(aunts, criteria, true)
	fmt.Println("Part1:", p1)
	fmt.Println("Part2:", p2)
}

func findAunt(aunts map[int]map[string]int, criteria map[string]int, realAunt bool) int {
	for i, aunt := range aunts {
		if realAunt {
			if realCriteriaMatch(aunt, criteria) {
				return i
			}
		} else {
			if criteriaMatch(aunt, criteria) {
				return i
			}
		}
	}
	return -1
}

func criteriaMatch(a, b map[string]int) bool {
	for feature, featureValue := range b {
		valueThis, ok := a[feature]
		if ok && valueThis != featureValue {
			return false
		}
	}
	return true
}

func realCriteriaMatch(a, b map[string]int) bool {
	for feature, featureValue := range b {
		valueThis, ok := a[feature]
		if !ok {
			continue
		}
		switch feature {
		case "cats", "trees":
			if valueThis <= featureValue {
				return false
			}
		case "pomeranians", "goldfish":
			if valueThis >= featureValue {
				return false
			}
		default:
			if valueThis != featureValue {
				return false
			}
		}
	}
	return true
}

func parseData() map[int]map[string]int {
	aunts := make(map[int]map[string]int)

	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		auntNumber, auntFeatures := parseAunt(scanner.Text())
		aunts[auntNumber] = auntFeatures
	}
	return aunts
}

func parseAunt(s string) (int, map[string]int) {
	aunti, auntInfo, _ := strings.Cut(s, ": ")
	auntIdx, _ := strconv.Atoi(strings.TrimPrefix(aunti, "Sue "))
	features := make(map[string]int)
	featureKeyVal := strings.Split(auntInfo, ", ")
	for _, feature := range featureKeyVal {
		key, val, _ := strings.Cut(feature, ": ")
		features[key], _ = strconv.Atoi(val)
	}
	return auntIdx, features
}
