extends CharacterBody3D
class_name Follower

enum HeroType { KNIGHT, ARCHER, HEALER }

@export var hero_type: HeroType = HeroType.KNIGHT
@export var follow_speed: float = 4.5
@export var min_distance: float = 2.0

var attack_range: float = 2.0
var attack_damage: int = 5
var attack_interval: float = 1.0
var attack_timer: float = 0.0

var max_health: int = 50
var current_health: int = 50

var target: Node3D = null
var current_enemy: Node3D = null

@onready var sprite = $Sprite3D
const FloatingTextScene = preload("res://scenes/ui/FloatingText.tscn")
const HealthBarScene = preload("res://scenes/ui/HealthBar.tscn")
var health_bar: Node3D = null

func _ready() -> void:
	current_health = max_health
	if HealthBarScene:
		health_bar = HealthBarScene.instantiate()
		add_child(health_bar)
		health_bar.position.y = 1.5
		if health_bar.has_method("update_health"):
			health_bar.update_health(current_health, max_health)
	
	_apply_type_stats()

func setup_hero_type(type: int) -> void:
	hero_type = type as HeroType
	_apply_type_stats()

func _apply_type_stats() -> void:
	match hero_type:
		HeroType.KNIGHT:
			attack_range = 2.0
			attack_damage = 8
			attack_interval = 1.2
			max_health = 80
			sprite.modulate = Color(1, 0.5, 0.5) # 薄い赤
		HeroType.ARCHER:
			attack_range = 8.0
			attack_damage = 4
			attack_interval = 0.8
			max_health = 40
			sprite.modulate = Color(0.5, 0.5, 1) # 薄い青
		HeroType.HEALER:
			attack_range = 5.0 # 回復範囲
			attack_damage = 10 # 回復量
			attack_interval = 2.0
			max_health = 50
			sprite.modulate = Color(0.5, 1, 0.5) # 薄い緑
	
	current_health = max_health
	if health_bar and health_bar.has_method("update_health"):
		health_bar.update_health(current_health, max_health)

func _physics_process(delta: float) -> void:
	if not target:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			target = players[0]
			
	if target:
		var dist = global_position.distance_to(target.global_position)
		if dist > min_distance:
			_move_to_target(target.global_position, delta)
		else:
			velocity = Vector3.ZERO
			_process_combat(delta)

func _move_to_target(pos: Vector3, _delta: float) -> void:
	var dir = global_position.direction_to(pos)
	dir.y = 0
	velocity = dir.normalized() * follow_speed
	move_and_slide()
	
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

func _process_combat(delta: float) -> void:
	attack_timer -= delta
	if attack_timer > 0: return
	
	if hero_type == HeroType.HEALER:
		_heal_allies()
	else:
		_attack_enemies()
	
	attack_timer = attack_interval

func _attack_enemies() -> void:
	# プレイヤーの近くの敵、または自分に近い敵を探す
	var enemy = _find_closest_enemy()
	if enemy and global_position.distance_to(enemy.global_position) <= attack_range:
		if enemy.has_method("take_damage"):
			var hit_dir = enemy.global_position - global_position
			enemy.take_damage(attack_damage, hit_dir)
			
			# クナイや矢のエフェクトを出すのは将来の課題とする

func _heal_allies() -> void:
	var allies = get_tree().get_nodes_in_group("Follower")
	allies.append_array(get_tree().get_nodes_in_group("Player"))
	
	for ally in allies:
		if ally != self and global_position.distance_to(ally.global_position) <= attack_range:
			if ally.has_method("heal"):
				ally.heal(attack_damage)
			elif "current_health" in ally:
				# 直接回復
				ally.current_health = min(ally.current_health + attack_damage, ally.max_health)
				if ally.has_node("HealthBar") or (ally.has_method("update_health_ui")):
					# 簡易的にFloatingText
					_show_heal_text(ally, attack_damage)

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	if health_bar and health_bar.has_method("update_health"):
		health_bar.update_health(current_health, max_health)
	_show_heal_text(self, amount)

func _show_heal_text(node: Node3D, amount: int) -> void:
	if FloatingTextScene:
		var txt = FloatingTextScene.instantiate()
		get_tree().current_scene.add_child(txt)
		txt.global_position = node.global_position + Vector3(0, 2, 0)
		txt.modulate = Color(0, 1, 0)
		if txt.has_method("set_value"):
			txt.set_value(amount)

func _find_closest_enemy() -> Node3D:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var closest = null
	var min_dist = INF
	for enemy in enemies:
		var d = global_position.distance_to(enemy.global_position)
		if d < min_dist:
			min_dist = d
			closest = enemy
	return closest

func take_damage(amount: int, _dir: Vector3 = Vector3.ZERO) -> void:
	current_health -= amount
	if health_bar and health_bar.has_method("update_health"):
		health_bar.update_health(current_health, max_health)
	
	const HitEffectScene = preload("res://scenes/objects/HitEffect.tscn")
	if HitEffectScene:
		var effect = HitEffectScene.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = global_position
		
	if current_health <= 0:
		queue_free()
