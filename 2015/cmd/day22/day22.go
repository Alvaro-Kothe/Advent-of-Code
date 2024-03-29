package main

import (
	"fmt"
	"math"
	"strings"
)

func main() {
	// player := Player{hp: 10, mana: 250}
	// boss := Boss{14, 8}
	player := Player{hp: 50, mana: 500}
	boss := Boss{hp: 58, attack: 9}
	p1, _ := simulateBattle(player, boss, true, 0, math.MaxInt, false)
	p2, _ := simulateBattle(player, boss, true, 0, math.MaxInt, true)
	fmt.Println("Part1:", p1)
	fmt.Println("Part2:", p2)
}

func simulateBattle(player Player, boss Boss, isPlayerTurn bool, manaSpent, minManaSpent int, hard bool) (int, bool) {
	if manaSpent >= minManaSpent {
		return 0, false
	}
	if hard {
		player.hp--
	}
	applyEffects(&player, &boss)
	if player.hp <= 0 {
		return 0, false
	} else if boss.hp <= 0 {
		return manaSpent, true
	}
	playerCanWin := false
	if isPlayerTurn {
		for spell := range castableSpells(&player) {
			newPlayer := player
			newBoss := boss
			newPlayer.effects = make([]Spell, len(player.effects))
			copy(newPlayer.effects, player.effects)
			newPlayer.mana -= spell.cost
			if spell.duration > 0 {
				newPlayer.effects = append(player.effects, spell)
			} else {
				castSpell(spell, &newPlayer, &newBoss)
			}
			localManaSpent, playerWon := simulateBattle(newPlayer, newBoss, !isPlayerTurn, manaSpent+spell.cost, minManaSpent, hard)

			if playerWon {
				playerCanWin = true
				minManaSpent = min(minManaSpent, localManaSpent)
			}
		}
	} else {
		damage := max(1, boss.attack-player.armor)
		player.hp -= damage
		localManaSpent, playerWon := simulateBattle(player, boss, !isPlayerTurn, manaSpent, minManaSpent, hard)
		if playerWon {
			playerCanWin = true
			minManaSpent = min(minManaSpent, localManaSpent)
		}
	}
	return minManaSpent, playerCanWin
}

func effectDurations(player *Player) string {
	s := strings.Builder{}
	for _, effect := range player.effects {
		s.WriteString(fmt.Sprintf("%s:%d,", effect.name, effect.duration))
	}
	return s.String()
}

func applyEffects(player *Player, boss *Boss) {
	player.armor = 0
	newEffects := make([]Spell, 0, len(player.effects))
	for _, effect := range player.effects {
		castSpell(effect, player, boss)
		effect.duration--
		if effect.duration > 0 {
			newEffects = append(newEffects, effect)
		}
	}
	player.effects = newEffects
}

type Player struct {
	hp, mana, armor int
	effects         []Spell
}

type Boss struct {
	hp, attack int
}

type Spell struct {
	name                                          string
	cost, damage, heal, manaHeal, armor, duration int
}

func castSpell(spell Spell, player *Player, boss *Boss) {
	player.hp += spell.heal
	player.mana += spell.manaHeal
	player.armor += spell.armor
	boss.hp -= spell.damage
}

var spells = []Spell{
	{name: "missile", cost: 53, damage: 4},
	{name: "drain", cost: 73, damage: 2, heal: 2},
	{name: "shield", cost: 113, armor: 7, duration: 6},
	{name: "poison", cost: 173, damage: 3, duration: 6},
	{name: "regen", cost: 229, manaHeal: 101, duration: 5},
}

func castableSpells(player *Player) <-chan Spell {
	castableSpells := make(chan Spell)
	go func() {
		defer close(castableSpells)
		for _, spell := range spells {
			if spell.cost <= player.mana {
				if spell.duration == 0 || !isEffectActive(player, &spell) {
					castableSpells <- spell
				}
			}
		}
	}()
	return castableSpells
}

func isEffectActive(player *Player, spell *Spell) bool {
	for _, effect := range player.effects {
		if effect.name == spell.name {
			return true
		}
	}
	return false
}
