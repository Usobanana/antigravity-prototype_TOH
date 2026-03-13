extends Node

signal resources_changed(wood: int, stone: int)

var wood: int = 0
var stone: int = 0

var max_party_size: int = 1
var player_damage_bonus: int = 0

func add_wood(amount: int) -> void:
	wood += amount
	resources_changed.emit(wood, stone)

func add_stone(amount: int) -> void:
	stone += amount
	resources_changed.emit(wood, stone)

func spend_resources(cost_wood: int, cost_stone: int) -> bool:
	if wood >= cost_wood and stone >= cost_stone:
		wood -= cost_wood
		stone -= cost_stone
		resources_changed.emit(wood, stone)
		return true
	return false

# 拠点拡張関連のアップグレード
func upgrade_party_size() -> void:
	max_party_size += 1

func upgrade_damage() -> void:
	player_damage_bonus += 5
