package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
)

func main() {
	floor := 0
	i := 0
	basementFloorPos := -1
	reader := bufio.NewReader(os.Stdin)

	for {
		i++
		if c, _, err := reader.ReadRune(); err != nil {
			if err == io.EOF {
				break
			} else {
				fmt.Println(err)
			}
		} else {
			floor = moveFloor(c, floor)
			if basementFloorPos < 0 && floor == -1 {
				basementFloorPos = i
			}
		}
	}

	fmt.Println("Part1:", floor)
	fmt.Println("Part2:", basementFloorPos)
}

func moveFloor(instruction rune, currentFloor int) int {
	switch instruction {
	case '(':
		return currentFloor + 1
	case ')':
		return currentFloor - 1
	default:
		return currentFloor
	}
}
