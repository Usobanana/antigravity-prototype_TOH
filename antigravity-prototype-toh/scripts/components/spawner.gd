extends Node3D
class_name Spawner

@export var spawn_scene: PackedScene
@export var respawn_time: float = 5.0 # 消滅後再出現するまでの秒数

var current_instance: Node3D = null
var spawn_timer: float = 0.0
var is_waiting_respawn: bool = false

func _ready() -> void:
	_spawn()

func _process(delta: float) -> void:
	if is_waiting_respawn:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			_spawn()
			
	# 子ノードとして存在していたインスタンスが削除（queue_free）されたか監視
	elif not is_instance_valid(current_instance):
		is_waiting_respawn = true
		spawn_timer = respawn_time

func _spawn() -> void:
	if not spawn_scene: return
	
	current_instance = spawn_scene.instantiate()
	# Spawner自身の子として追加・位置はSpawnerの原点
	add_child(current_instance)
	current_instance.position = Vector3.ZERO
	
	is_waiting_respawn = false
