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
		
	# GameStateManagerのcurrent_party_size分だけFollowerを生成
	var spawn_count = GameStateManager.current_party_size
	
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
		
	if GameStateManager:
		GameStateManager.party_member_added.connect(_on_party_member_added)

func _on_party_member_added(_new_count: int, spawn_pos: Vector3, hero_type: int) -> void:
	var follower = FollowerScene.instantiate()
	allies_container.add_child(follower)
	
	if follower.has_method("setup_hero_type"):
		follower.setup_hero_type(hero_type)
	
	if spawn_pos != Vector3.ZERO:
		follower.global_position = spawn_pos
	elif player:
		# プレイヤーの少し後ろに配置
		var offset = -player.global_transform.basis.z * 2.0
		follower.global_position = player.global_position + offset

func _on_time_updated(current_time: float, is_night: bool) -> void:
	if not sun: return
	
	# Rotate the sun based on time (X axis for elevation)
	# 0.0 to 1.0 maps to a full day rotation
	var elevation = current_time * PI * 2.0
	sun.rotation.x = -elevation # Rotate around X
	
	# Adjust light color and energy
	if is_night:
		# Night colors (brighter blue-grey for better visibility)
		sun.light_color = Color(0.5, 0.5, 0.8)
		sun.light_energy = 1.2
	else:
		# Day colors (warm/bright)
		if current_time > 0.5: # Evening
			sun.light_color = Color(1.0, 0.6, 0.4)
			sun.light_energy = 1.0
		else: # Morning/Day
			sun.light_color = Color(1.0, 1.0, 0.9)
			sun.light_energy = 1.2
