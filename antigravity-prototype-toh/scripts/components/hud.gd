extends CanvasLayer
class_name HUD

@onready var virtual_pad = $VirtualPad
@onready var party_label = $UIContainer/BottomArea/HBoxContainer/PartyLabel
@onready var resource_label = $UIContainer/BottomArea/HBoxContainer/ResourceLabel
@onready var return_button = $UIContainer/BottomArea/HBoxContainer/ReturnButton

func _ready() -> void:
	if virtual_pad:
		virtual_pad.stick_moved.connect(_on_stick_moved)
	if return_button:
		return_button.pressed.connect(_on_return_pressed)

func update_party_count(current: int, max_val: int) -> void:
	party_label.text = "Party: %d/%d" % [current, max_val]

func update_resources(wood: int, stone: int) -> void:
	resource_label.text = "Wood: %d  Stone: %d" % [wood, stone]

func _on_return_pressed() -> void:
	print("Return to base!")
	# get_tree().change_scene_to_file("res://scenes/levels/Base.tscn")

func _on_stick_moved(direction: Vector2) -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		players[0].set_input_vector(direction)
