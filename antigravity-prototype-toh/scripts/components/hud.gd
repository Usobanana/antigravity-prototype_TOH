extends CanvasLayer
class_name HUD

@onready var virtual_pad = $VirtualPad
@onready var party_label = $UIContainer/BottomArea/HBoxContainer/PartyLabel
@onready var time_label = $UIContainer/BottomArea/HBoxContainer/TimeLabel
@onready var resource_label = $UIContainer/BottomArea/HBoxContainer/ResourceLabel
@onready var return_button = $UIContainer/BottomArea/HBoxContainer/ReturnButton
@onready var upgrade_button = $UIContainer/UpgradeButton

@onready var skill_area = $UIContainer/SkillArea
@onready var skill_progress = $UIContainer/SkillArea/SkillProgress
@onready var skill_button = $UIContainer/SkillArea/SkillButton

var current_facility: Node3D = null

func _ready() -> void:
	if virtual_pad:
		virtual_pad.stick_moved.connect(_on_stick_moved)
	if return_button:
		return_button.pressed.connect(_on_return_pressed)
	if upgrade_button:
		upgrade_button.pressed.connect(_on_upgrade_pressed)
	if skill_button:
		skill_button.pressed.connect(_on_skill_pressed)
		
	# シーンに応じてボタンの文字を変更
	if get_tree().current_scene and get_tree().current_scene.name == "Base":
		return_button.text = "Go Field"
	else:
		return_button.text = "Return"
		
	# GameStateManagerからのリソース更新シグナルに接続
	if GameStateManager:
		GameStateManager.resources_changed.connect(_on_resources_changed)
		_on_resources_changed(GameStateManager.wood, GameStateManager.stone, GameStateManager.iron, GameStateManager.bag_wood, GameStateManager.bag_stone, GameStateManager.bag_iron, GameStateManager.max_bag_capacity)
		
		# パーティ数の更新表示
		update_party_count(GameStateManager.max_party_size)
		
	if TimeManager:
		TimeManager.time_updated.connect(_on_time_updated)
		_on_time_updated(TimeManager.time, TimeManager.is_night)

func _on_time_updated(_current_time: float, is_night: bool) -> void:
	if time_label:
		time_label.text = "Time: " + ("Night" if is_night else "Day")
		if is_night:
			time_label.modulate = Color(0.6, 0.6, 1.0)
		else:
			time_label.modulate = Color(1.0, 1.0, 0.6)

func _process(_delta: float) -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0 and skill_progress and skill_button:
		var p = players[0]
		if "skill_energy" in p and "max_skill_energy" in p:
			skill_progress.value = (float(p.skill_energy) / float(p.max_skill_energy)) * 100.0
			
			if p.skill_energy >= p.max_skill_energy:
				skill_button.disabled = false
				skill_button.modulate = Color(1.0, 0.5, 0.0) # 準備完了はオレンジ色
			else:
				skill_button.disabled = true
				skill_button.modulate = Color(1.0, 1.0, 1.0, 0.5)

func update_party_count(max_val: int) -> void:
	party_label.text = "Party Size: %d" % max_val

func _on_resources_changed(wood: int, stone: int, iron: int, bag_wood: int, bag_stone: int, bag_iron: int, max_bag: int) -> void:
	if get_tree().current_scene and get_tree().current_scene.name == "Field":
		var total_bag = bag_wood + bag_stone + bag_iron
		resource_label.text = "Bag: %d/%d (W:%d S:%d I:%d)" % [total_bag, max_bag, bag_wood, bag_stone, bag_iron]
	else:
		resource_label.text = "Storage: Wood %d / Stone %d / Iron %d" % [wood, stone, iron]
		
	# 更新時にラベルをバウンス（跳ねる）させるTweenアニメーション
	if is_inside_tree():
		var tween = create_tween()
		# Pivotを中心に確実に拡縮させるため
		resource_label.pivot_offset = resource_label.size / 2
		tween.tween_property(resource_label, "scale", Vector2(1.2, 1.2), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(resource_label, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func _on_return_pressed() -> void:
	var current_scene = get_tree().current_scene.name
	if current_scene == "Field":
		if GameStateManager:
			GameStateManager.deposit_all()
		get_tree().change_scene_to_file("res://scenes/levels/Base.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/levels/Field.tscn")

func _on_upgrade_pressed() -> void:
	if current_facility and current_facility.has_method("try_upgrade"):
		current_facility.try_upgrade()

func show_upgrade_button(facility: Node3D) -> void:
	current_facility = facility
	if upgrade_button:
		upgrade_button.visible = true

func hide_upgrade_button() -> void:
	current_facility = null
	if upgrade_button:
		upgrade_button.visible = false

func _on_stick_moved(direction: Vector2) -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		players[0].set_input_vector(direction)

func _on_skill_pressed() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		if players[0].has_method("use_skill"):
			players[0].use_skill()
