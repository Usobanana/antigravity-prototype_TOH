extends Enemy
class_name BossEnemy

func _ready() -> void:
	# ボス特有のパラメータ設定
	max_health = 150
	move_speed = 1.0
	attack_damage = 15
	attack_range = 3.0
	aggro_range = 15.0
	
	super._ready()

func die() -> void:
	# 倒した時に特別な報酬やイベントを発生させる
	if GameStateManager:
		# 例：倒すと木が100、石が100ストレージに直接入る（バッグ容量は無視）
		GameStateManager.wood += 100
		GameStateManager.stone += 100
		GameStateManager.resources_changed.emit(
			GameStateManager.wood,
			GameStateManager.stone,
			GameStateManager.iron,
			GameStateManager.bag_wood,
			GameStateManager.bag_stone,
			GameStateManager.bag_iron,
			GameStateManager.max_bag_capacity
		)
		
		# ボス討伐メッセージなど（簡易的）
		print("Boss Defeated! Earned Wood x100, Stone x100")
		
		if FloatingTextScene:
			var txt_origin = FloatingTextScene.instantiate()
			get_tree().current_scene.add_child(txt_origin)
			txt_origin.global_position = global_position
			txt_origin.global_position.y += 2.0
			# "Boss Defeated!"などのテキストを表示できるメソッドがあれば呼び出す（今回はset_valueが数値用なので流用か改造が必要）
			if txt_origin.has_method("set_message"):
				txt_origin.set_message("Boss Defeated!")
			elif txt_origin.has_method("set_value"):
				# 仮
				txt_origin.set_value(9999)

	super.die()
