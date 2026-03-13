extends Sprite3D
class_name TargetMarker

# サイズ固定か、少しアニメーション(点滅・回転など)させたい場合ここで処理
func _process(delta: float) -> void:
	rotation_degrees.y += 90.0 * delta # くるくる回る
