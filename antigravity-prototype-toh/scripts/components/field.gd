extends Node3D

const FollowerScene = preload("res://scenes/actors/Follower.tscn")

@onready var allies_container = $Allies
@onready var player = $Player

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
