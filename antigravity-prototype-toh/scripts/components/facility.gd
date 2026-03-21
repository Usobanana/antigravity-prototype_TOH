extends Area3D
class_name Facility

@export var facility_name: String = "Tent"
@export var base_cost_wood: int = 10
@export var base_cost_stone: int = 5
@export var base_cost_iron: int = 0
@export var level: int = 1
@export var grid_size: int = 2 # 基本2x2マス

var current_level: int = 1

@onready var label_3d = $Label3D
@onready var upgrade_button_hud: Button = null

func _ready() -> void:
	_update_visuals()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _update_label() -> void:
	var req_wood = get_current_wood_cost()
	var req_stone = get_current_stone_cost()
	var req_iron = get_current_iron_cost()
	
	if req_iron > 0:
		label_3d.text = "%s Lv.%d\nCost: Wood %d / Stone %d / Iron %d" % [facility_name, current_level, req_wood, req_stone, req_iron]
	else:
		label_3d.text = "%s Lv.%d\nCost: Wood %d / Stone %d" % [facility_name, current_level, req_wood, req_stone]

func get_current_wood_cost() -> int:
	return base_cost_wood * current_level

func get_current_stone_cost() -> int:
	return base_cost_stone * current_level

func get_current_iron_cost() -> int:
	return base_cost_iron * current_level

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		_show_upgrade_ui()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		_hide_upgrade_ui()

func _show_upgrade_ui() -> void:
	var huds = get_tree().get_nodes_in_group("HUD")
	if huds.size() > 0:
		var hud = huds[0]
		if hud.has_method("show_upgrade_button"):
			hud.show_upgrade_button(self)

func _hide_upgrade_ui() -> void:
	var huds = get_tree().get_nodes_in_group("HUD")
	if huds.size() > 0:
		var hud = huds[0]
		if hud.has_method("hide_upgrade_button"):
			hud.hide_upgrade_button()

func try_upgrade() -> bool:
	var req_wood = get_current_wood_cost()
	var req_stone = get_current_stone_cost()
	var req_iron = get_current_iron_cost()
	
	if GameStateManager.spend_resources(req_wood, req_stone, req_iron):
		current_level += 1
		_apply_upgrade_effect()
		_update_label()
		_update_visuals() # ビジュアル更新
		return true
	return false

func _update_visuals() -> void:
	# レベルが上がるごとに少しずつ大きくする（10%ずつ）
	var new_scale = 1.0 + (current_level - 1) * 0.1
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(new_scale, new_scale, new_scale), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# レベル5以上で豪華な色（ゴールド）を混ぜる演出
	if current_level >= 5:
		if label_3d:
			label_3d.modulate = Color(1, 0.84, 0) # Gold

func _apply_upgrade_effect() -> void:
	if facility_name == "Tent":
		GameStateManager.upgrade_party_size()
	elif facility_name == "Blacksmith":
		GameStateManager.upgrade_damage()
	elif facility_name == "Storage":
		GameStateManager.upgrade_bag_capacity()
	elif facility_name == "Palace":
		# 王宮のアップグレードは全リソースを少し増やす「贅沢」なボーナス
		GameStateManager.add_resource("wood", 100 * current_level)
		GameStateManager.add_resource("stone", 100 * current_level)
		GameStateManager.add_resource("iron", 50 * current_level)
		GameStateManager.upgrade_party_size() # パーティ枠も増える
