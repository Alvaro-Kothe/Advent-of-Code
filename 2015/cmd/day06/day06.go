package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	boolGrid := make([][]bool, 1000)
	brightnessGrid := make([][]int, 1000)
	for i := range boolGrid {
		boolGrid[i] = make([]bool, 1000)
		brightnessGrid[i] = make([]int, 1000)
	}

	for scanner.Scan() {
		line := scanner.Text()
		instruction := parseInstruction(line)
		executeInstruction(instruction, &boolGrid)
		adjustBrightness(instruction, &brightnessGrid)
	}
	p1 := countOn(boolGrid)
	p2 := sumMatrix(brightnessGrid)
	fmt.Println("Part1:", p1)
	fmt.Println("Part2:", p2)
}

type Instruction struct {
	action         string
	x0, x1, y0, y1 int
}

func parseInstruction(s string) Instruction {
	var result Instruction
	parts := strings.Fields(s)
	var start, end string
	if parts[0] == "turn" {
		result.action = parts[1]
		start = parts[2]
		end = parts[4]
	} else {
		result.action = parts[0]
		start = parts[1]
		end = parts[3]
	}
	fmt.Sscanf(start, "%d,%d", &result.x0, &result.y0)
	fmt.Sscanf(end, "%d,%d", &result.x1, &result.y1)
	return result
}

func executeInstruction(instruction Instruction, grid *[][]bool) {
	for i := instruction.x0; i <= instruction.x1; i++ {
		for j := instruction.y0; j <= instruction.y1; j++ {
			switch instruction.action {
			case "on":
				(*grid)[i][j] = true
			case "off":
				(*grid)[i][j] = false
			case "toggle":
				(*grid)[i][j] = !(*grid)[i][j]
			}
		}
	}
}

func adjustBrightness(instruction Instruction, grid *[][]int) {
	for i := instruction.x0; i <= instruction.x1; i++ {
		for j := instruction.y0; j <= instruction.y1; j++ {
			switch instruction.action {
			case "on":
				(*grid)[i][j]++
			case "off":
				(*grid)[i][j] = max(0, (*grid)[i][j]-1)
			case "toggle":
				(*grid)[i][j] += 2
			}
		}
	}
}

func countOn(grid [][]bool) int {
	count := 0
	for _, row := range grid {
		for _, v := range row {
			if v {
				count++
			}
		}
	}
	return count
}

func sumMatrix(grid [][]int) int {
	result := 0
	for _, row := range grid {
		for _, v := range row {
			result += v
		}
	}
	return result
}
