extends CanvasLayer
class_name HUD

@onready var virtual_pad = $VirtualPad

func _ready() -> void:
	if virtual_pad:
		virtual_pad.stick_moved.connect(_on_stick_moved)

func _on_stick_moved(direction: Vector2) -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		players[0].set_input_vector(direction)
