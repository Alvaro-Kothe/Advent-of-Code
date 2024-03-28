package main

import (
	"encoding/json"
	"fmt"
	"os"
)

func main() {
	var inp map[string]interface{}
	json.NewDecoder(os.Stdin).Decode(&inp)
	p1 := sumJson(inp, false)
	fmt.Println("Part1:", p1)

	p2 := sumJson(inp, true)
	fmt.Println("Part2:", p2)
}

func sumJson(data interface{}, ignoreRed bool) float64 {
	switch el := data.(type) {
	case float64:
		return el
	case []interface{}:
		sum := 0.0
		for _, v := range el {
			sum += sumJson(v, ignoreRed)
		}
		return sum
	case map[string]interface{}:
		if ignoreRed {
			for _, v := range el {
				if s, ok := v.(string); ok {
					if s == "red" {
						return 0.0
					}
				}
			}
		}

		sum := 0.0
		for _, v := range el {
			sum += sumJson(v, ignoreRed)
		}
		return sum
	default:
		return 0.0
	}
}
