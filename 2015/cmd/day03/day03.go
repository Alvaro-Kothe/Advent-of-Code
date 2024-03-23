package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
)

type Position struct {
	x, y int
}

func main() {
	reader := bufio.NewReader(os.Stdin)
	visited := map[Position]bool{{0, 0}: true}
	visited2 := map[Position]bool{{0, 0}: true}
	x, y := 0, 0
	positions := [2]Position{{0, 0}, {0, 0}}
	move_idx := 0
	for {
		if c, _, err := reader.ReadRune(); err != nil {
			if err == io.EOF {
				break
			} else {
				fmt.Println(err)
			}
		} else {
			dx, dy := getDir(c)
			x += dx
			y += dy
			positions[move_idx].x += dx
			positions[move_idx].y += dy

			visited[Position{x, y}] = true
			visited2[positions[move_idx]] = true

			move_idx++
			move_idx %= 2
		}
	}

	fmt.Println("Part1:", len(visited))
	fmt.Println("Part2:", len(visited2))
}

func getDir(ch rune) (int, int) {
	switch ch {
	case '^':
		return -1, 0
	case 'v':
		return 1, 0
	case '<':
		return 0, -1
	case '>':
		return 0, 1
	default:
		return 0, 0
	}
}
