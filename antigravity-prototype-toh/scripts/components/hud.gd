extends CanvasLayer
class_name HUD

@onready var virtual_pad = $VirtualPad
@onready var party_label = $UIContainer/BottomArea/HBoxContainer/PartyLabel
@onready var resource_label = $UIContainer/BottomArea/HBoxContainer/ResourceLabel
@onready var return_button = $UIContainer/BottomArea/HBoxContainer/ReturnButton
@onready var upgrade_button = $UIContainer/UpgradeButton

var current_facility: Node3D = null

func _ready() -> void:
	if virtual_pad:
		virtual_pad.stick_moved.connect(_on_stick_moved)
	if return_button:
		return_button.pressed.connect(_on_return_pressed)
	if upgrade_button:
		upgrade_button.pressed.connect(_on_upgrade_pressed)
		
	# シーンに応じてボタンの文字を変更
	if get_tree().current_scene and get_tree().current_scene.name == "Base":
		return_button.text = "Go Field"
	else:
		return_button.text = "Return"
		
	# GameStateManagerからのリソース更新シグナルに接続
	if GameStateManager:
		GameStateManager.resources_changed.connect(_on_resources_changed)
		_on_resources_changed(GameStateManager.wood, GameStateManager.stone, GameStateManager.bag_wood, GameStateManager.bag_stone, GameStateManager.max_bag_capacity)
		
		# パーティ数の更新表示
		update_party_count(GameStateManager.max_party_size)

func update_party_count(max_val: int) -> void:
	party_label.text = "Party Size: %d" % max_val

func _on_resources_changed(wood: int, stone: int, bag_wood: int, bag_stone: int, max_bag: int) -> void:
	if get_tree().current_scene and get_tree().current_scene.name == "Field":
		var total_bag = bag_wood + bag_stone
		resource_label.text = "Bag: %d/%d (W:%d S:%d)" % [total_bag, max_bag, bag_wood, bag_stone]
	else:
		resource_label.text = "Storage: Wood %d / Stone %d" % [wood, stone]
		
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
