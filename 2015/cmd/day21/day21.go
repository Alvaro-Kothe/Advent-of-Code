package main

import (
	"fmt"
	"math"
)

func main() {
	boss := Entity{hp: 100, attack: 8, armor: 2}
	p1 := findMinCost(boss)
	fmt.Println("Part1:", p1)
	p2 := findMaxCostAndLose(boss)
	fmt.Println("Part2:", p2)
}

func findMaxCostAndLose(boss Entity) int {
	bestCost := 0
	buyCombinations := genItemCombinations()
	for bought := range buyCombinations {
		if bought.cost > bestCost {
			player := Entity{hp: 100, attack: bought.damage, armor: bought.armor}
			bossCopy := boss
			if !simulateBattle(&player, &bossCopy) {
				bestCost = bought.cost
			}
		}
	}
	return bestCost
}

func findMinCost(boss Entity) int {
	bestCost := math.MaxInt
	buyCombinations := genItemCombinations()
	for bought := range buyCombinations {
		if bought.cost < bestCost {
			player := Entity{hp: 100, attack: bought.damage, armor: bought.armor}
			bossCopy := boss
			if simulateBattle(&player, &bossCopy) {
				bestCost = bought.cost
			}
		}
	}
	return bestCost
}

type Entity struct {
	hp, attack, armor int
}

type Item struct {
	cost, damage, armor int
}

var weapons = []Item{
	{8, 4, 0}, {10, 5, 0}, {25, 6, 0}, {40, 7, 0}, {74, 8, 0},
}
var armors = []Item{
	{0, 0, 0}, {13, 0, 1}, {31, 0, 2}, {53, 0, 3}, {75, 0, 4}, {102, 0, 5},
}
var rings = []Item{
	{0, 0, 0}, {0, 0, 0},
	{25, 0, 1}, {50, 0, 2}, {100, 3, 0}, {20, 0, 1}, {40, 0, 2}, {80, 0, 3},
}

func genItemCombinations() <-chan Item {
	items := make(chan Item)
	go func() {
		defer close(items)
		shop(items)
	}()
	return items
}

func shop(ch chan<- Item) {
	for _, weapon := range weapons {
		for _, armor := range armors {
			for ring1Idx, ring1 := range rings {
				for ring2Idx := ring1Idx + 1; ring2Idx < len(rings); ring2Idx++ {
					ring2 := rings[ring2Idx]

					cost := weapon.cost + armor.cost + ring1.cost + ring2.cost
					damage := weapon.damage + ring1.damage + ring2.damage
					defense := armor.armor + ring1.armor + ring2.armor

					ch <- Item{cost, damage, defense}
				}
			}
		}
	}
}

func attack(a, b *Entity) {
	damage := max(1, a.attack-b.armor)
	b.hp -= damage
}

func simulateBattle(player, boss *Entity) bool {
	if player.hp <= 0 {
		return false
	}
	attack(player, boss)
	return !simulateBattle(boss, player)
}
