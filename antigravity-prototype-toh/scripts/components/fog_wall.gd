extends Node3D

func clear_fog() -> void:
	# 霧が晴れる演出（スケールダウンとアルファ値を下げる）
	var sprites = $Sprites
	if not sprites: return
	
	var tween = create_tween().set_parallel()
	tween.tween_property(sprites, "scale", Vector3.ZERO, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# Sprite3D個別の透明度を操作
	for sprite in sprites.get_children():
		if sprite is Sprite3D:
			tween.tween_property(sprite, "modulate:a", 0.0, 1.0)
			
	tween.chain().tween_callback(queue_free)
