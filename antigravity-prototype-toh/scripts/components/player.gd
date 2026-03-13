extends CharacterBody3D
class_name Player

enum State {
	IDLE,
	MOVE,
	ATTACK,
	GATHER
}

@export var move_speed: float = 5.0
@export var attack_interval: float = 1.0
@export var gather_interval: float = 1.5
@export var attack_damage: int = 10

var current_state: State = State.IDLE
var input_vector: Vector2 = Vector2.ZERO

var attack_timer: float = 0.0
var gather_timer: float = 0.0

var current_wood: int = 0
var current_stone: int = 0

const TargetMarkerScene = preload("res://scenes/ui/TargetMarker.tscn")
const GatherProgressScene = preload("res://scenes/ui/GatherProgress.tscn")
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
	if is_instance_valid(active_progress):
		active_progress.queue_free()

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
						target.take_damage(attack_damage)
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
					
				gather_timer -= delta
				
				# プログレスバーUIの更新
				var pbar = active_progress.get_node("SubViewport/ProgressBar")
				if pbar:
					# 1.0がMax, 0.0が完了とするような割合計算
					pbar.value = 1.0 - (gather_timer / gather_interval)
				
				if gather_timer <= 0.0:
					if target.has_method("gather"):
						var success = target.gather()
						if success:
							if target.name.begins_with("Tree"):
								current_wood += 1
							else:
								current_stone += 1
							_update_hud()
					gather_timer = gather_interval

func _update_hud() -> void:
	var huds = get_tree().get_nodes_in_group("HUD")
	if huds.size() > 0:
		if huds[0].has_method("update_resources"):
			huds[0].update_resources(current_wood, current_stone)

func _scan_surroundings() -> void:
	if current_state == State.MOVE:
		return
		
	# 1. 敵の存在チェック（戦闘優先）
	if _get_closest_enemy() != null:
		_change_state(State.ATTACK)
		return
		
	# 2. 素材の存在チェック（採取は安全圏で）
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
