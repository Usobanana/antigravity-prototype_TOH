extends Area3D
class_name LootChest

@export var min_wood: int = 5
@export var max_wood: int = 15
@export var min_stone: int = 3
@export var max_stone: int = 10
@export var min_iron: int = 0
@export var max_iron: int = 3

const GatherEffectScene = preload("res://scenes/objects/GatherEffect.tscn")
const WoodTexture = preload("res://assets/placeholders/tree.png")
const StoneTexture = preload("res://assets/placeholders/stone.png")
const IronTexture = preload("res://assets/placeholders/iron_ore.png")

var is_opened: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# 少し浮かせて回転させる演出
	var tween = create_tween().set_loops()
	tween.tween_property($CSGBox3D, "position:y", 0.2, 1.0).as_relative().set_trans(Tween.TRANS_SINE)
	tween.tween_property($CSGBox3D, "position:y", -0.2, 1.0).as_relative().set_trans(Tween.TRANS_SINE)
	
	var r_tween = create_tween().set_loops()
	r_tween.tween_property($CSGBox3D, "rotation:y", deg_to_rad(360), 4.0).as_relative()

func _on_body_entered(body: Node3D) -> void:
	if is_opened: return
	if body.is_in_group("Player"):
		open(body)

func open(player: Node3D) -> void:
	is_opened = true
	
	var w = randi_range(min_wood, max_wood)
	var s = randi_range(min_stone, max_stone)
	var i = randi_range(min_iron, max_iron)
	
	# リソースを追加（バッグがいっぱいの可能性もあるが、戦利品は強制追加か、演出だけ出す）
	if GameStateManager:
		# 簡易的に直接ストレージではなくバッグにいれることを試みる
		_spawn_gather_effects(player, w, s, i)
		# 宝箱は消滅
		queue_free()

func _spawn_gather_effects(player: Node3D, w: int, s: int, i: int) -> void:
	if not GatherEffectScene: return
	
	# 木材
	if w > 0:
		for j in range(3): # ヒット感を出すため3つのエフェクトに分ける
			var effect = GatherEffectScene.instantiate()
			get_tree().current_scene.add_child(effect)
			effect.setup(global_position, player.global_position, WoodTexture)
			GameStateManager.add_to_bag("wood", ceil(float(w)/3.0))

	# 石材
	if s > 0:
		var effect = GatherEffectScene.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.setup(global_position, player.global_position, StoneTexture)
		GameStateManager.add_to_bag("stone", s)

	# 鉄
	if i > 0:
		var effect = GatherEffectScene.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.setup(global_position, player.global_position, IronTexture)
		GameStateManager.add_to_bag("iron", i)
