extends Camera3D
class_name CameraController

@export var follow_speed: float = 5.0
@export var offset: Vector3 = Vector3(0, 8, 8) # カメラの基本位置（対象からY方向+8, Z方向+8の斜め上）

var target: Node3D = null

func _ready() -> void:
	# 初期向きの設定 (X軸を中心に-45度回転した見下ろし視点を想定)
	rotation_degrees = Vector3(-45, 0, 0)

func _physics_process(delta: float) -> void:
	if not target:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			target = players[0]
			# 初期位置を一気に合わせる
			global_position = target.global_position + offset
			
	if target:
		var target_pos = target.global_position + offset
		global_position = global_position.lerp(target_pos, follow_speed * delta)
