extends Node3D

const FollowerScene = preload("res://scenes/actors/Follower.tscn")

@onready var allies_container = $Allies
@onready var player = $Player
@onready var sun = $DirectionalLight3D

func _ready() -> void:
	if not GameStateManager: return
	
	# エディタで配置されているAlliesを一旦クリア（必要に応じて）
	for child in allies_container.get_children():
		child.queue_free()
		
	# GameStateManagerのmax_party_size分だけFollowerを生成
	# Playerの周囲に散らして配置する
	var spawn_count = GameStateManager.max_party_size
	
	for i in range(spawn_count):
		var follower = FollowerScene.instantiate()
		allies_container.add_child(follower)
		
		# 位置を少しばらけさせる
		var angle = i * (PI * 2.0 / spawn_count)
		var offset = Vector3(cos(angle), 0, sin(angle)) * 2.0
		if player:
			follower.global_position = player.global_position + offset
			
	if TimeManager:
		TimeManager.time_updated.connect(_on_time_updated)

func _on_time_updated(current_time: float, is_night: bool) -> void:
	if not sun: return
	
	# Rotate the sun based on time (X axis for elevation)
	# 0.0 to 1.0 maps to a full day rotation
	var elevation = current_time * PI * 2.0
	sun.rotation.x = -elevation # Rotate around X
	
	# Adjust light color and energy
	if is_night:
		# Night colors (slightly brighter blue-grey for better visibility)
		sun.light_color = Color(0.4, 0.4, 0.7)
		sun.light_energy = 0.8
	else:
		# Day colors (warm/bright)
		if current_time > 0.5: # Evening
			sun.light_color = Color(1.0, 0.6, 0.4)
			sun.light_energy = 0.8
		else: # Morning/Day
			sun.light_color = Color(1.0, 1.0, 0.9)
			sun.light_energy = 1.0
