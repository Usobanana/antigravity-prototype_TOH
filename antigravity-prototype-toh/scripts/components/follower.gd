extends CharacterBody3D
class_name Follower

@export var follow_speed: float = 4.5
@export var min_distance: float = 1.5

var target: Node3D = null
@onready var sprite = $Sprite3D

func _physics_process(delta: float) -> void:
	if not target:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			target = players[0]
			
	if target:
		var dist = global_position.distance_to(target.global_position)
		if dist > min_distance:
			# ターゲットの方向へ移動
			var dir = global_position.direction_to(target.global_position)
			dir.y = 0 # Y軸の移動を制限
			velocity = dir.normalized() * follow_speed
			move_and_slide()
			
			if velocity.x != 0:
				sprite.flip_h = velocity.x < 0
		else:
			velocity = Vector3.ZERO
