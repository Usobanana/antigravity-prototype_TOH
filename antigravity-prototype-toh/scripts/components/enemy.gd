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
@export var move_speed: float = 2.0
@export var attack_damage: int = 5
@export var attack_range: float = 2.0
@export var aggro_range: float = 8.0

var current_health: int

const FloatingTextScene = preload("res://scenes/ui/FloatingText.tscn")

@onready var sprite = $Sprite3D

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
		_process_ai(delta)

func _process_ai(_delta: float) -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() == 0:
		current_state = State.IDLE
		velocity = Vector3.ZERO
		return
		
	var target = players[0]
	var dist = global_position.distance_to(target.global_position)
	
	if dist <= attack_range:
		# 攻撃範囲内なら停止（実際の攻撃はPlayer側のArea3Dで衝突判定など行っている想定に合わせるか、独自タイマーを設ける）
		current_state = State.ATTACK
		velocity = Vector3.ZERO
	elif dist <= aggro_range:
		# 追跡範囲内なら近づく
		current_state = State.MOVE
		var dir = (target.global_position - global_position).normalized()
		dir.y = 0
		velocity = dir * move_speed
		move_and_slide()
		
		# 向きの反転
		if sprite and dir.x != 0:
			sprite.flip_h = dir.x < 0
	else:
		# 範囲外なら停止
		current_state = State.IDLE
		velocity = Vector3.ZERO

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
