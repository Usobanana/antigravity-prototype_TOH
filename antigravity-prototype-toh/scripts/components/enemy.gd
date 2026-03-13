extends CharacterBody3D
class_name Enemy

@export var max_health: int = 30
var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	current_health -= amount
	# ヒットエフェクトなどをここで出す
	
	# スケールを少し変えてダメージを受けた感触などを出しても良い
	
	if current_health <= 0:
		die()

func die() -> void:
	# 死亡エフェクトやアイテムドロップ処理
	queue_free()
