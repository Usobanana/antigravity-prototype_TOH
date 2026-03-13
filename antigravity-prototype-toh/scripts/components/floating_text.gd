extends Label3D
class_name FloatingText

@export var move_speed: float = 2.0
@export var life_time: float = 1.0

var elapsed: float = 0.0

func _ready() -> void:
	# 少しランダムに散らす(X/Z方向)
	var offset = Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5))
	position += offset

func _process(delta: float) -> void:
	# 上方向へ移動させる
	position.y += move_speed * delta
	
	elapsed += delta
	# フェードアウト
	var alpha = 1.0 - (elapsed / life_time)
	modulate.a = max(0.0, alpha)
	outline_modulate.a = max(0.0, alpha)
	
	if elapsed >= life_time:
		queue_free()

func set_value(amount: int) -> void:
	text = str(amount)

func set_text(msg: String) -> void:
	text = msg
