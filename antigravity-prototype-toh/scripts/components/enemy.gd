extends CharacterBody3D
class_name Enemy

enum State {
	IDLE,
	MOVE,
	ATTACK,
	KNOCKBACK
}

var current_state: State = State.IDLE
var knockback_timer: float = 0.0
var knockback_velocity: Vector3 = Vector3.ZERO


@export var max_health: int = 30
var current_health: int

const FloatingTextScene = preload("res://scenes/ui/FloatingText.tscn")

func _ready() -> void:
	current_health = max_health

func _physics_process(delta: float) -> void:
	if current_state == State.KNOCKBACK:
		knockback_timer -= delta
		velocity = knockback_velocity
		move_and_slide()
		if knockback_timer <= 0.0:
			current_state = State.IDLE
	else:
		# プレイヤーを追跡する等の基本AIロジックをここに追加可能
		pass

func take_damage(amount: int, hit_direction: Vector3 = Vector3.ZERO) -> void:
	current_health -= amount
	
	# ノックバック処理
	current_state = State.KNOCKBACK
	knockback_timer = 0.2
	if hit_direction != Vector3.ZERO:
		knockback_velocity = hit_direction.normalized() * 5.0
	else:
		# 方向指定がなければ後ろへ飛ぶように
		knockback_velocity = -global_transform.basis.z * 5.0
	
	# ダメージポップアップの生成
	if FloatingTextScene:
		var text_node = FloatingTextScene.instantiate()
		add_child(text_node)
		if text_node.has_method("set_value"):
			text_node.set_value(amount)
			
	# スケールを少し変えてダメージを受けた感触などを出しても良い
	
	if current_health <= 0:
		die()

func die() -> void:
	# 死亡エフェクトやアイテムドロップ処理
	queue_free()
