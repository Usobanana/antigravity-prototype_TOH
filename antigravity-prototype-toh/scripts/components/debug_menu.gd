extends CanvasLayer

@onready var add_wood_btn = $Control/Panel/VBox/AddWood
@onready var add_stone_btn = $Control/Panel/VBox/AddStone
@onready var add_iron_btn = $Control/Panel/VBox/AddIron
@onready var max_party_btn = $Control/Panel/VBox/MaxParty
@onready var toggle_grid_btn = $Control/Panel/VBox/ToggleGrid
@onready var toggle_frames_btn = $Control/Panel/VBox/ToggleFrames
@onready var toggle_collision_btn = $Control/Panel/VBox/ToggleCollision
@onready var clear_enemies_btn = $Control/Panel/VBox/ClearEnemies
@onready var reset_game_btn = $Control/Panel/VBox/ResetGame
@onready var close_btn = $Control/Panel/VBox/Close

func _ready():
	hide()
	
	add_wood_btn.pressed.connect(_on_add_wood)
	add_stone_btn.pressed.connect(_on_add_stone)
	add_iron_btn.pressed.connect(_on_add_iron)
	max_party_btn.pressed.connect(_on_max_party)
	toggle_grid_btn.pressed.connect(_on_toggle_grid)
	toggle_frames_btn.pressed.connect(_on_toggle_frames)
	toggle_collision_btn.pressed.connect(_on_toggle_collision)
	clear_enemies_btn.pressed.connect(_on_clear_enemies)
	reset_game_btn.pressed.connect(_on_reset_game)
	close_btn.pressed.connect(hide)

func toggle():
	if visible:
		hide()
	else:
		show()

func _on_add_wood():
	GameStateManager.add_resource("wood", 100)
	print("Debug: Added 100 Wood")

func _on_add_stone():
	GameStateManager.add_resource("stone", 100)
	print("Debug: Added 100 Stone")

func _on_add_iron():
	GameStateManager.add_resource("iron", 100)
	print("Debug: Added 100 Iron")

func _on_max_party():
	GameStateManager.max_party_size += 1
	print("Debug: Max Party Size is now ", GameStateManager.max_party_size)

func _on_clear_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for e in enemies:
		e.queue_free()
	print("Debug: Cleared all enemies")

func _on_reset_game():
	if GameStateManager:
		GameStateManager.wood = 0
		GameStateManager.stone = 0
		GameStateManager.iron = 0
		GameStateManager.bag_wood = 0
		GameStateManager.bag_stone = 0
		GameStateManager.bag_iron = 0
		GameStateManager.max_party_size = 1
		GameStateManager.current_party_size = 1
		GameStateManager.resources_changed.emit(0,0,0,0,0,0, GameStateManager.max_bag_capacity)
		
	get_tree().reload_current_scene()
	print("Debug: Game State Reset")

func _on_toggle_grid():
	var grid = get_tree().current_scene.get_node_or_null("Grid")
	if not grid:
		# NavigationRegion3Dの下にある可能性も考慮
		grid = get_tree().current_scene.get_node_or_null("World/NavigationRegion3D/Grid")
		if not grid:
			grid = get_tree().current_scene.get_node_or_null("NavigationRegion3D/Grid")
			
	if grid:
		grid.visible = !grid.visible
		print("Debug: Grid visibility toggled to ", grid.visible)
	else:
		print("Debug: Grid not found in current scene: ", get_tree().current_scene.name)

func _on_toggle_frames():
	# 全てのSprite3Dを探して枠（MeshInstance3D）を追加/表示切替
	var sprites = get_tree().get_nodes_in_group("Sprite3D_Container") # 後でグループ追加
	# もしくは全ノードからSprite3Dを探す
	_toggle_wireframes(get_tree().root)
	print("Debug: Frames toggled")

func _toggle_wireframes(node: Node):
	if node is Sprite3D:
		var wire = node.get_node_or_null("DebugWire")
		if not wire:
			wire = MeshInstance3D.new()
			wire.name = "DebugWire"
			var mesh = BoxMesh.new()
			# 画像サイズに合わせたMesh作成（1024 * 0.005 = 5.12）
			mesh.size = Vector3(5.12, 5.12, 0.1)
			wire.mesh = mesh
			var mat = StandardMaterial3D.new()
			mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
			mat.albedo_color = Color(1, 1, 0) # 黄色
			mat.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = 0.3
			wire.material_override = mat
			node.add_child(wire)
		else:
			wire.visible = !wire.visible
			
	for child in node.get_children():
		_toggle_wireframes(child)

func _on_toggle_collision():
	# 注: get_tree().debug_collisions_hint は実行時に変更しても既存のものは変わらない場合が多い。
	# シーンをリロードして反映させる。
	var hint = get_tree().debug_collisions_hint
	get_tree().debug_collisions_hint = !hint
	print("Debug: Collision hint toggled to ", !hint, ". (Reload scene to reflect accurately)")
	# 既存のものをなんとか表示させるには、RuntimeでShapeを表示するスクリプトが必要だが
	# Godot4ではこれを切り替えると反映されるはず。
