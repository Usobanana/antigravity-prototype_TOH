extends CharacterBody3D
class_name Player

enum State {
	IDLE,
	MOVE,
	ATTACK,
	GATHER,
	KNOCKBACK
}

@export var move_speed: float = 5.0
@export var attack_interval: float = 1.0
@export var gather_interval: float = 1.5
@export var attack_damage: int = 10

var current_state: State = State.IDLE
var input_vector: Vector2 = Vector2.ZERO

var attack_timer: float = 0.0
var gather_timer: float = 0.0

var knockback_timer: float = 0.0
var knockback_velocity: Vector3 = Vector3.ZERO

const TargetMarkerScene = preload("res://scenes/ui/TargetMarker.tscn")
const GatherProgressScene = preload("res://scenes/ui/GatherProgress.tscn")
const GatherEffectScene = preload("res://scenes/objects/GatherEffect.tscn")
var active_marker: Node3D = null
var active_progress: Node3D = null

@onready var sprite = $Sprite3D
@onready var enemy_detector: Area3D = $EnemyDetectionRange
@onready var gather_detector: Area3D = $GatheringRange

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_update_state(delta)

# 外部（バーチャルパッド等）から入力を受け取る
func set_input_vector(v: Vector2) -> void:
	input_vector = v

func _handle_movement(delta: float) -> void:
	if current_state == State.KNOCKBACK:
		knockback_timer -= delta
		velocity = knockback_velocity
		move_and_slide()
		if knockback_timer <= 0.0:
			_change_state(State.IDLE)
		return

	if input_vector.length() > 0:
		# 2Dの入力を3D空間(X, Z)へ変換（Yは高さ）
		var direction = Vector3(input_vector.x, 0, input_vector.y).normalized()
		# スティックの倒れ具合（length）で速度を調整
		velocity = direction * move_speed * input_vector.length()
		move_and_slide()
		
		# 入力があれば強制的にMOVE状態
		if current_state != State.MOVE:
			_change_state(State.MOVE)
			
		# 移動方向に応じてSpriteの向きを反転(Flip h)させる（2Dアクションの基本）
		if input_vector.x != 0:
			sprite.flip_h = input_vector.x < 0
	else:
		# 入力がない場合
		velocity = Vector3.ZERO
		if current_state == State.MOVE:
			_change_state(State.IDLE)

func _change_state(new_state: State) -> void:
	if current_state == new_state:
		return
		
	# 状態を抜ける時の処理
	_clear_ui_markers()
	
	current_state = new_state
	
	# 状態に入った時の処理
	if current_state == State.IDLE:
		_scan_surroundings()

func _clear_ui_markers() -> void:
	if is_instance_valid(active_marker):
		active_marker.queue_free()
		active_marker = null
	if is_instance_valid(active_progress):
		active_progress.queue_free()
		active_progress = null

func _update_state(delta: float = 0.0) -> void:
	match current_state:
		State.IDLE:
			_scan_surroundings()
		State.MOVE:
			attack_timer = 0.0
			gather_timer = 0.0
		State.ATTACK:
			var target = _get_closest_enemy()
			if not target:
				_change_state(State.IDLE)
			else:
				if not is_instance_valid(active_marker):
					active_marker = TargetMarkerScene.instantiate()
					target.add_child(active_marker)
				
				attack_timer -= delta
				if attack_timer <= 0.0:
					if target.has_method("take_damage"):
						var hit_dir = target.global_position - global_position
						hit_dir.y = 0
						var total_damage = attack_damage
						if GameStateManager:
							total_damage += GameStateManager.player_damage_bonus
						target.take_damage(total_damage, hit_dir)
					attack_timer = attack_interval
		State.GATHER:
			if _get_closest_enemy() != null:
				_change_state(State.ATTACK)
				return
				
			var target = _get_closest_gatherable()
			if not target:
				_change_state(State.IDLE)
			else:
				if not is_instance_valid(active_progress):
					active_progress = GatherProgressScene.instantiate()
					target.add_child(active_progress)
					# 追加：対象が変わったら古いマーカーを消すため、ここで初期化
					var pbar = active_progress.get_node("SubViewport/ProgressBar")
					if pbar: pbar.value = 0
					
				gather_timer -= delta
				
				# プログレスバーUIの更新
				var pbar = active_progress.get_node("SubViewport/ProgressBar")
				if pbar:
					# 1.0がMax, 0.0が完了とするような割合計算
					pbar.value = 1.0 - (gather_timer / gather_interval)
				
				if gather_timer <= 0.0:
					var can_gather = false
					if target.name.begins_with("Tree"):
						can_gather = GameStateManager.add_to_bag("wood", 1)
					elif target.name.begins_with("IronOre") or target.is_in_group("IronOre"):
						can_gather = GameStateManager.add_to_bag("iron", 1)
					else:
						# Stone または その他
						can_gather = GameStateManager.add_to_bag("stone", 1)
						
					if can_gather:
						if target.has_method("gather"):
							target.gather()
							
						# 獲得したアイテムが自身に飛んでくるエフェクトの生成
						if GatherEffectScene:
							var effect = GatherEffectScene.instantiate()
							get_tree().current_scene.add_child(effect)
							
							var tex = preload("res://icon.svg")
							if target.name.begins_with("Stone"):
								tex = preload("res://icon.svg")
								effect.setup(target.global_position, global_position, tex)
							elif target.name.begins_with("IronOre") or target.is_in_group("IronOre"):
								tex = preload("res://icon.svg")
								effect.setup(target.global_position, global_position, tex)
							else:
								effect.setup(target.global_position, global_position, tex)
					else:
						# バッグが満タンの場合は採取を中断してIDLEへ
						_change_state(State.IDLE)
						return

					gather_timer = gather_interval

func _scan_surroundings() -> void:
	if current_state == State.MOVE:
		return
		
	# 1. 敵の存在チェック（戦闘優先）
	if _get_closest_enemy() != null:
		_change_state(State.ATTACK)
		return
		
	# 2. バッグがいっぱいでないか、素材の存在チェック（採取は安全圏で）
	if GameStateManager.bag_wood + GameStateManager.bag_stone + GameStateManager.bag_iron < GameStateManager.max_bag_capacity:
		if _get_closest_gatherable() != null:
			_change_state(State.GATHER)
			return

func _get_closest_enemy() -> Node3D:
	if not enemy_detector: return null
	var enemies = enemy_detector.get_overlapping_bodies() # または get_overlapping_areas() 構成による
	var closest = null
	var min_dist = INF
	for enemy in enemies:
		if enemy.is_in_group("Enemy"):
			var dist = global_position.distance_to(enemy.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = enemy
	return closest

func _get_closest_gatherable() -> Node3D:
	if not gather_detector: return null
	var items = gather_detector.get_overlapping_bodies()
	var closest = null
	var min_dist = INF
	for item in items:
		if item.is_in_group("Gatherable"):
			var dist = global_position.distance_to(item.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = item
	return closest
