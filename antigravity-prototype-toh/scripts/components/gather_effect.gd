extends Node3D

var target_position: Vector3 = Vector3.ZERO
var start_position: Vector3 = Vector3.ZERO

func setup(start: Vector3, target: Vector3, texture: Texture2D) -> void:
	start_position = start
	target_position = target
	global_position = start_position
	
	if has_node("Sprite3D"):
		$Sprite3D.texture = texture
			
	_play_animation()

func _play_animation() -> void:
	var tween = create_tween()
	# 放物線を描くように上に一度跳ねてから手元に収まる動き
	var mid_point = start_position.lerp(target_position, 0.5)
	mid_point.y += 2.0
	
	tween.tween_property(self, "global_position", mid_point, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_position, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
