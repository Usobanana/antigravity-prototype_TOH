extends Area3D
class_name AreaUnlocker

@export var area_name: String = "New Field"
@export var cost_wood: int = 50
@export var cost_stone: int = 30
@export var cost_iron: int = 0

# この施設が解放する霧（壁）のグループ名
@export var fog_group_name: String = "Fog_Section_1"

var is_unlocked: bool = false

@onready var label_3d = $Label3D

func _ready() -> void:
	_update_label()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _update_label() -> void:
	if is_unlocked:
		label_3d.text = area_name + " (Unlocked)"
	else:
		if cost_iron > 0:
			label_3d.text = "Unlock %s\nCost: Wood %d / Stone %d / Iron %d" % [area_name, cost_wood, cost_stone, cost_iron]
		else:
			label_3d.text = "Unlock %s\nCost: Wood %d / Stone %d" % [area_name, cost_wood, cost_stone]

func _on_body_entered(body: Node3D) -> void:
	if is_unlocked: return
	if body.is_in_group("Player"):
		_show_unlock_ui()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		_hide_unlock_ui()

func _show_unlock_ui() -> void:
	var huds = get_tree().get_nodes_in_group("HUD")
	if huds.size() > 0:
		var hud = huds[0]
		# Facilityと同じボタンを流用
		if hud.has_method("show_upgrade_button"):
			hud.show_upgrade_button(self)

func _hide_unlock_ui() -> void:
	var huds = get_tree().get_nodes_in_group("HUD")
	if huds.size() > 0:
		var hud = huds[0]
		if hud.has_method("hide_upgrade_button"):
			hud.hide_upgrade_button()

# Facility.gd との互換性のために try_upgrade を定義
func try_upgrade() -> bool:
	return try_unlock()

func try_unlock() -> bool:
	if is_unlocked: return false
	
	if GameStateManager.spend_resources(cost_wood, cost_stone, cost_iron):
		is_unlocked = true
		_apply_unlock_effect()
		_update_label()
		return true
	return false

func _apply_unlock_effect() -> void:
	# 霧を消す
	var fogs = get_tree().get_nodes_in_group(fog_group_name)
	for fog in fogs:
		if fog.has_method("clear_fog"):
			fog.clear_fog()
		else:
			# メソッドがない場合は単純に削除
			fog.queue_free()
	
	# アンロック演出（パーティクルなど）をここに追加しても良い
	print("Area Unlocked: " + area_name)
