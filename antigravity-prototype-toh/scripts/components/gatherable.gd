extends StaticBody3D
class_name Gatherable

@export var max_resources: int = 3
var current_resources: int

func _ready() -> void:
	current_resources = max_resources

func gather() -> bool:
	if current_resources > 0:
		current_resources -= 1
		# 資源取得エフェクトやインベントリ追加処理などをここに記述
		
		if current_resources <= 0:
			# 採取完了時に消滅
			queue_free()
		return true
	return false
