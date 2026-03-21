extends Node3D

@onready var progress_bar = $SubViewport/ProgressBar

@onready var sprite_3d = $Sprite3D

func _ready() -> void:
	# ViewportTextureを動的に設定
	if $SubViewport and sprite_3d:
		sprite_3d.texture = $SubViewport.get_texture()
	
	# 初期状態では少し上の方に配置することを想定
	position.y = 1.8

func update_health(current: int, max_val: int) -> void:
	if progress_bar:
		progress_bar.max_value = max_val
		progress_bar.value = current
		
		# 残りHPが少なくなると色を変えるなどの演出も可能
		if current <= max_val * 0.2:
			progress_bar.modulate = Color(1, 0, 0) # 赤
		elif current <= max_val * 0.5:
			progress_bar.modulate = Color(1, 1, 0) # 黄色
		else:
			progress_bar.modulate = Color(0, 1, 0) # 緑
