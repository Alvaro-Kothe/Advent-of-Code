package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	instructions := readInstructions()
	computer := newComputer(instructions)
	computer.runProgram()
	fmt.Println("Part1:", computer.registers["b"])
	computer = newComputer(instructions)
	computer.registers["a"] = 1
	computer.runProgram()
	fmt.Println("Part2:", computer.registers["b"])
}

type Instruction struct {
	operation string
	args      []string
}

type Computer struct {
	ip           int
	registers    map[string]uint
	instructions []Instruction
}

func newComputer(instructions []Instruction) *Computer {
	return &Computer{
		ip: 0, registers: map[string]uint{"a": 0, "b": 0}, instructions: instructions,
	}
}

func (c *Computer) runProgram() {
	for c.ip >= 0 && c.ip < len(c.instructions) {
		c.runInstruction()
	}
}

func (c *Computer) runInstruction() {
	instruction := c.instructions[c.ip]
	switch instruction.operation {
	case "hlf":
		c.registers[instruction.args[0]] /= 2
		c.ip++
	case "tpl":
		c.registers[instruction.args[0]] *= 3
		c.ip++
	case "inc":
		c.registers[instruction.args[0]]++
		c.ip++
	case "jmp":
		offset, _ := strconv.Atoi(instruction.args[0])
		c.ip += offset
	case "jie":
		offset, _ := strconv.Atoi(instruction.args[1])
		if c.registers[instruction.args[0]]%2 == 0 {
			c.ip += offset
		} else {
			c.ip++
		}
	case "jio":
		offset, _ := strconv.Atoi(instruction.args[1])
		if c.registers[instruction.args[0]] == 1 {
			c.ip += offset
		} else {
			c.ip++
		}
	}
}

func readInstructions() []Instruction {
	result := make([]Instruction, 0, 50)

	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		parts := strings.Fields(scanner.Text())
		op := parts[0]
		if op == "jie" || op == "jio" {
			parts[1] = strings.Replace(parts[1], ",", "", 1)
		}
		args := parts[1:]
		result = append(result, Instruction{op, args})
	}
	return result
}
