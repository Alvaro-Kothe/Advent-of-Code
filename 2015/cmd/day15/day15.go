package main

import (
	"bufio"
	"fmt"
	"os"
	"reflect"
	"strings"
)

type Properties struct {
	Ingredient                                      string
	Capacity, Durability, Flavor, Texture, Calories int
}

func main() {
	ingredients := parseData()
	p1 := findMaxCookieScore(ingredients, 100, -1)
	p2 := findMaxCookieScore(ingredients, 100, 500)
	fmt.Println("Part1:", p1)
	fmt.Println("Part2:", p2)
}

func findMaxCookieScore(ingredients []Properties, teaspoons, targetCalories int) int {
	quantities := make([]int, len(ingredients))
	return findMaxScoreAux(ingredients, quantities, 0, teaspoons, targetCalories)
}

func findMaxScoreAux(ingredients []Properties, quantities []int, idx, left, targetCalories int) int {
	if idx == len(ingredients)-1 {
		quantities[idx] = left
		return computeScore(ingredients, quantities, targetCalories)
	}

	maxScore := 0
	for quant := 0; quant <= left; quant++ {
		quantities[idx] = quant
		score := findMaxScoreAux(ingredients, quantities, idx+1, left-quant, targetCalories)
		maxScore = max(maxScore, score)
	}

	return maxScore
}

func computeScore(ingredients []Properties, quantities []int, targetCalories int) int {
	fields := []string{"Capacity", "Durability", "Flavor", "Texture", "Calories"}
	totalAmount := make([]int, len(fields))
	for i, quantity := range quantities {
		ingredient := reflect.ValueOf(ingredients[i])
		for fieldIdx, fieldName := range fields {
			totalAmount[fieldIdx] += int(ingredient.FieldByName(fieldName).Int()) * quantity
		}
	}
	if targetCalories > 0 && totalAmount[4] != targetCalories {
		return 0
	}
	result := 1
	for i := 0; i < 4; i++ {
		if total := totalAmount[i]; total <= 0 {
			return 0
		} else {
			result *= total
		}
	}
	return result
}

func parseData() []Properties {
	scanner := bufio.NewScanner(os.Stdin)
	ingredients := []Properties{}

	for scanner.Scan() {
		var property Properties
		_, err := fmt.Sscanf(scanner.Text(),
			"%s capacity %d, durability %d, flavor %d, texture %d, calories %d",
			&property.Ingredient, &property.Capacity, &property.Durability,
			&property.Flavor, &property.Texture, &property.Calories)
		if err != nil {
			panic(err)
		}

		property.Ingredient = strings.TrimRight(property.Ingredient, ":")
		ingredients = append(ingredients, property)
	}

	return ingredients
}
