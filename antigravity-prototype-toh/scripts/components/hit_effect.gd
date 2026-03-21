extends Node3D

@onready var sprite = $Sprite3D

func _ready() -> void:
	# スケールを0から開始
	sprite.scale = Vector3.ZERO
	sprite.modulate = Color(1, 1, 0, 1) # 黄色
	
	var tween = create_tween().set_parallel(true)
	
	# パッと大きくして、フェードアウトしながら消える
	tween.tween_property(sprite, "scale", Vector3(1.5, 1.5, 1.5), 0.1).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate", Color(1, 0.5, 0, 0), 0.3).set_delay(0.1).set_trans(Tween.TRANS_LINEAR)
	
	# アニメーションが終わったら削除
	tween.chain().tween_callback(queue_free)

func setup(pos: Vector3) -> void:
	global_position = pos
	# 少しランダムに位置をずらす
	global_position += Vector3(randf_range(-0.3, 0.3), randf_range(0.5, 1.5), randf_range(-0.3, 0.3))
