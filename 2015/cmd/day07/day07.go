package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Gate struct {
	Operation, Target string
	Args              []string
}

func main() {
	wires := make(map[string]uint16)
	circuit := make(map[string]Gate)
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		instruction := parseGate(scanner.Text())
		circuit[instruction.Target] = instruction
	}
	p1 := evaluate("a", wires, circuit)
	wires = make(map[string]uint16)
	wires["b"] = p1
	p2 := evaluate("a", wires, circuit)
	fmt.Println("Part1:", p1)
	fmt.Println("Part2:", p2)
}

func evaluate(wire string, wires map[string]uint16, circuit map[string]Gate) uint16 {
	if val, ok := wires[wire]; ok {
		return val
	}
	gate := circuit[wire]
	numArgs := make([]uint16, len(gate.Args))
	for i, v := range gate.Args {
		n, err := strconv.ParseUint(v, 10, 16)
		var num uint16
		if err != nil {
			num = evaluate(v, wires, circuit)
		} else {
			num = uint16(n)
		}
		numArgs[i] = num
	}

	applyInstruction(gate, numArgs, wires)
	return wires[wire]
}

func applyInstruction(gate Gate, numArgs []uint16, wires map[string]uint16) {
	switch gate.Operation {
	case "ASSIGNMENT":
		wires[gate.Target] = numArgs[0]
	case "NOT":
		wires[gate.Target] = ^numArgs[0]
	case "AND":
		wires[gate.Target] = numArgs[0] & numArgs[1]
	case "OR":
		wires[gate.Target] = numArgs[0] | numArgs[1]
	case "LSHIFT":
		wires[gate.Target] = numArgs[0] << numArgs[1]
	case "RSHIFT":
		wires[gate.Target] = numArgs[0] >> numArgs[1]
	default:
		fmt.Printf("Invalid Operation %q\n", gate.Operation)
		return
	}
}

func parseGate(s string) Gate {
	parts := strings.Fields(s)
	switch len(parts) {
	case 3:
		return Gate{Operation: "ASSIGNMENT", Args: []string{parts[0]}, Target: parts[2]}
	case 4:
		return Gate{Operation: "NOT", Args: []string{parts[1]}, Target: parts[3]}
	case 5:
		return Gate{Operation: parts[1], Args: []string{parts[0], parts[2]}, Target: parts[4]}
	}
	fmt.Println("Invalid string", s)
	return Gate{}
}
