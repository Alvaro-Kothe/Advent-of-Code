package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strings"
)

type Replacement struct {
	Old, New string
}

func main() {
	transitions, initialMolecule := parseData()
	p1 := len(getDistinctMolecules(transitions, initialMolecule))
	flippedReplacements := flipReplacements(transitions)
	sort.Slice(flippedReplacements, func(i, j int) bool { return len(flippedReplacements[i].Old) > len(flippedReplacements[j].Old) })
	p2 := stepsToMedicine(initialMolecule, "e", flippedReplacements, 0)

	fmt.Println("Part1:", p1)
	fmt.Println("Part2:", p2)
}

func flipReplacements(transitions []Replacement) []Replacement {
	result := make([]Replacement, len(transitions))
	for i, rule := range transitions {
		result[i] = Replacement{Old: rule.New, New: rule.Old}
	}
	return result
}

type State struct {
	cur  string
	step int
}

func applyRuleOnce(s string, rule Replacement) (string, bool) {
	idxRule := strings.Index(s, rule.Old)
	if idxRule == -1 {
		return "", false
	}
	substituted := s[:idxRule] + rule.New + s[idxRule+len(rule.Old):]
	return substituted, true
}

// Assume that rules is ordered in an optimal setup that validates the dfs answer
// and there is no need to verify every other combination
func stepsToMedicine(start, target string, rules []Replacement, steps int) int {
	if start == target {
		return steps
	}
	minSteps := -1
	for _, rule := range rules {
		substitutedString, replaced := applyRuleOnce(start, rule)
		if replaced {
			replacedSteps := stepsToMedicine(substitutedString, target, rules, steps+1)
			if (replacedSteps > 0 && replacedSteps < minSteps) || minSteps == -1 {
				minSteps = replacedSteps
			}
		}
		if minSteps != -1 {
			return minSteps
		}
	}
	return minSteps
}

func getDistinctMolecules(rules []Replacement, molecule string) []string {
	distinctMolecules := make(map[string]bool)
	for _, rule := range rules {
		replacements := applyReplacements(rule, molecule)
		for newMolecule := range replacements {
			distinctMolecules[newMolecule] = true
		}
	}
	result := make([]string, len(distinctMolecules))
	i := 0
	for nm := range distinctMolecules {
		result[i] = nm
		i++
	}
	return result
}

func applyReplacements(rule Replacement, s string) <-chan string {
	ch := make(chan string)
	go func() {
		defer close(ch)
		start := 0
		for {
			idxRule := strings.Index(s[start:], rule.Old)
			if idxRule == -1 {
				break
			}
			idxRule += start
			substituted := s[:idxRule] + rule.New + s[idxRule+len(rule.Old):]
			ch <- substituted
			start = idxRule + 1
		}
	}()
	return ch
}

func parseData() ([]Replacement, string) {
	var transitions []Replacement
	var molecule string

	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		var src, dst string
		line := scanner.Text()
		_, err := fmt.Sscanf(line, "%s => %s", &src, &dst)
		if err != nil {
			molecule = line
		}
		if src != "" && dst != "" {
			transitions = append(transitions, Replacement{src, dst})
		}
	}

	return transitions, molecule
}
