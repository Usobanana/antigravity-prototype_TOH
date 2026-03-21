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
const HitEffectScene = preload("res://scenes/objects/HitEffect.tscn")
const HealthBarScene = preload("res://scenes/ui/HealthBar.tscn")
const LootChestScene = preload("res://scenes/objects/LootChest.tscn")

var health_bar: Node3D = null

@onready var sprite = $Sprite3D

func _ready() -> void:
	current_health = max_health
	
	# HPバーの生成
	if HealthBarScene:
		health_bar = HealthBarScene.instantiate()
		add_child(health_bar)
		if health_bar.has_method("update_health"):
			health_bar.update_health(current_health, max_health)

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
	
	# HPバーの更新
	if health_bar and health_bar.has_method("update_health"):
		health_bar.update_health(current_health, max_health)
	
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
		get_tree().current_scene.add_child(text_node)
		text_node.global_position = global_position + Vector3(0, 1.5, 0)
		if text_node.has_method("set_value"):
			text_node.set_value(amount)
			
	# ヒットエフェクトの生成
	if HitEffectScene:
		var effect = HitEffectScene.instantiate()
		get_tree().current_scene.add_child(effect)
		if effect.has_method("setup"):
			effect.setup(global_position)
	
	if current_health <= 0:
		die()

func die() -> void:
	# 死亡エフェクトやアイテムドロップ処理
	if LootChestScene:
		var chest = LootChestScene.instantiate()
		get_tree().current_scene.add_child(chest)
		chest.global_position = global_position
		
	if QuestManager:
		QuestManager.notify_progress(1, 1) # KILL_ENEMIES
		
	queue_free()
