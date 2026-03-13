extends Node

var wood: int = 0
var stone: int = 0

var bag_wood: int = 0
var bag_stone: int = 0
var max_bag_capacity: int = 20

var max_party_size: int = 1
var player_damage_bonus: int = 0

signal resources_changed(wood: int, stone: int, bag_wood: int, bag_stone: int, max_bag: int)

func add_to_bag(type: String, amount: int) -> bool:
	if bag_wood + bag_stone + amount > max_bag_capacity:
		return false
		
	if type == "wood":
		bag_wood += amount
	else:
		bag_stone += amount
		
	resources_changed.emit(wood, stone, bag_wood, bag_stone, max_bag_capacity)
	return true

func deposit_all() -> void:
	if bag_wood == 0 and bag_stone == 0:
		return
		
	wood += bag_wood
	stone += bag_stone
	bag_wood = 0
	bag_stone = 0
	
	resources_changed.emit(wood, stone, bag_wood, bag_stone, max_bag_capacity)


func spend_resources(cost_wood: int, cost_stone: int) -> bool:
	if wood >= cost_wood and stone >= cost_stone:
		wood -= cost_wood
		stone -= cost_stone
		resources_changed.emit(wood, stone, bag_wood, bag_stone, max_bag_capacity)
		return true
	return false

# 拠点拡張関連のアップグレード
func upgrade_party_size() -> void:
	max_party_size += 1

func upgrade_damage() -> void:
	player_damage_bonus += 5

func upgrade_bag_capacity() -> void:
	max_bag_capacity += 10
	resources_changed.emit(wood, stone, bag_wood, bag_stone, max_bag_capacity)
