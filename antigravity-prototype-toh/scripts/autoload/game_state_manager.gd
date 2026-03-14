extends Node

var wood: int = 0
var stone: int = 0
var iron: int = 0

var bag_wood: int = 0
var bag_stone: int = 0
var bag_iron: int = 0
var max_bag_capacity: int = 20

var max_party_size: int = 1
var player_damage_bonus: int = 0

signal resources_changed(wood: int, stone: int, iron: int, bag_wood: int, bag_stone: int, bag_iron: int, max_bag: int)

func add_resource(type: String, amount: int) -> void:
	if type == "wood":
		wood += amount
	elif type == "stone":
		stone += amount
	elif type == "iron":
		iron += amount
	resources_changed.emit(wood, stone, iron, bag_wood, bag_stone, bag_iron, max_bag_capacity)


func add_to_bag(type: String, amount: int) -> bool:
	if bag_wood + bag_stone + bag_iron + amount > max_bag_capacity:
		return false
		
	if type == "wood":
		bag_wood += amount
	elif type == "stone":
		bag_stone += amount
	elif type == "iron":
		bag_iron += amount
		
	resources_changed.emit(wood, stone, iron, bag_wood, bag_stone, bag_iron, max_bag_capacity)
	return true

func deposit_all() -> void:
	if bag_wood == 0 and bag_stone == 0 and bag_iron == 0:
		return
		
	wood += bag_wood
	stone += bag_stone
	iron += bag_iron
	bag_wood = 0
	bag_stone = 0
	bag_iron = 0
	
	resources_changed.emit(wood, stone, iron, bag_wood, bag_stone, bag_iron, max_bag_capacity)


func spend_resources(cost_wood: int, cost_stone: int, cost_iron: int = 0) -> bool:
	if wood >= cost_wood and stone >= cost_stone and iron >= cost_iron:
		wood -= cost_wood
		stone -= cost_stone
		iron -= cost_iron
		resources_changed.emit(wood, stone, iron, bag_wood, bag_stone, bag_iron, max_bag_capacity)
		return true
	return false

# 拠点拡張関連のアップグレード
func upgrade_party_size() -> void:
	max_party_size += 1

func upgrade_damage() -> void:
	player_damage_bonus += 5

func upgrade_bag_capacity() -> void:
	max_bag_capacity += 10
	resources_changed.emit(wood, stone, iron, bag_wood, bag_stone, bag_iron, max_bag_capacity)
