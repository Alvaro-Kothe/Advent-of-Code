package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	grid := parseGrid()
	grid1 := generateNextState(grid, false)
	for i := 1; i < 100; i++ {
		grid1 = generateNextState(grid1, false)
	}
	grid2 := generateNextState(grid, true)
	for i := 1; i < 100; i++ {
		grid2 = generateNextState(grid2, true)
	}
	fmt.Println("Part1:", countOn(grid1))
	fmt.Println("Part2:", countOn(grid2))
}

func countOn(grid [][]bool) int {
	totalOn := 0
	for _, row := range grid {
		for _, isOn := range row {
			if isOn {
				totalOn++
			}
		}
	}
	return totalOn
}

func generateNextState(grid [][]bool, part2 bool) [][]bool {
	nextState := make([][]bool, len(grid))
	for i, row := range grid {
		nextState[i] = make([]bool, len(row))
		for j := range row {
			nextState[i][j] = getLightNextState(grid, i, j, part2)
		}
	}
	return nextState
}

func countNeighborsOn(grid [][]bool, x, y int) int {
	count := 0
	for nx := x - 1; nx <= x+1; nx++ {
		for ny := y - 1; ny <= y+1; ny++ {
			if (nx == x && ny == y) || nx < 0 || nx >= len(grid) ||
				ny < 0 || ny >= len(grid[nx]) {
				continue
			}
			if grid[nx][ny] {
				count++
			}
		}
	}
	return count
}

func getLightNextState(grid [][]bool, x, y int, part2 bool) bool {
	if part2 {
		isXCorner := x == 0 || x == len(grid)-1
		isYCorner := y == 0 || y == len(grid)-1
		if isXCorner && isYCorner {
			return true
		}
	}
	neighborsOn := countNeighborsOn(grid, x, y)
	if grid[x][y] {
		return neighborsOn == 2 || neighborsOn == 3
	} else {
		return neighborsOn == 3
	}
}

func displayGrid(grid [][]bool) {
	for _, row := range grid {
		for _, v := range row {
			if v {
				fmt.Print("#")
			} else {
				fmt.Print(".")
			}
		}
		fmt.Println()
	}
}

func parseGrid() [][]bool {
	var grid [][]bool
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		elements := scanner.Text()
		row := make([]bool, len(elements))
		for i, el := range elements {
			row[i] = el == '#'
		}
		grid = append(grid, row)
	}
	return grid
}
