extends Area3D
class_name SurvivorCage

@export var rescue_cost_wood: int = 0
@export var rescue_cost_stone: int = 0

var is_rescued: bool = false

@onready var label_3d = $Label3D

func _ready() -> void:
	_update_label()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _update_label() -> void:
	if is_rescued:
		label_3d.text = "Rescued!"
	else:
		if GameStateManager.current_party_size >= GameStateManager.max_party_size:
			label_3d.text = "Party Full\n(Upgrade Base)"
		elif rescue_cost_wood > 0 or rescue_cost_stone > 0:
			label_3d.text = "Rescue Survivor\nCost: W %d / S %d" % [rescue_cost_wood, rescue_cost_stone]
		else:
			label_3d.text = "Rescue Survivor"

func _on_body_entered(body: Node3D) -> void:
	if is_rescued: return
	if body.is_in_group("Player"):
		_show_rescue_ui()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		_hide_rescue_ui()

func _show_rescue_ui() -> void:
	var huds = get_tree().get_nodes_in_group("HUD")
	if huds.size() > 0:
		var hud = huds[0]
		if hud.has_method("show_upgrade_button"):
			hud.show_upgrade_button(self)

func _hide_rescue_ui() -> void:
	var huds = get_tree().get_nodes_in_group("HUD")
	if huds.size() > 0:
		var hud = huds[0]
		if hud.has_method("hide_upgrade_button"):
			hud.hide_upgrade_button()

# HUDのボタンから呼ばれる
func try_upgrade() -> bool:
	return try_rescue()

func try_rescue() -> bool:
	if is_rescued: return false
	
	# パーティー枠のチェック
	if GameStateManager.current_party_size >= GameStateManager.max_party_size:
		# メッセージを出すなどの処理をここに追加可能
		return false
	
	if GameStateManager.spend_resources(rescue_cost_wood, rescue_cost_stone):
		is_rescued = true
		_apply_rescue_effect()
		_update_label()
		return true
	return false

func _apply_rescue_effect() -> void:
	# ランダムな職業を決定
	var random_type = randi() % 3 # 0:KNIGHT, 1:ARCHER, 2:HEALER
	
	# パーティメンバーを追加
	if GameStateManager.add_party_member(global_position, random_type):
		# 檻が消える演出
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector3.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_callback(queue_free)
		
		# パーティクルなどはField.gd側の追加スポーン処理で出しても良い
