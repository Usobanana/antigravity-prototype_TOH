extends Control
class_name VirtualPad

signal stick_moved(direction: Vector2)

var is_dragging := false
var start_pos := Vector2.ZERO
var current_pos := Vector2.ZERO
@export var max_radius := 100.0 # Pixels

func _ready() -> void:
	# Clicks outside of specific UI elements can be caught if mouse filter is stop/pass
	# By default Control has STOP, so it will catch input.
	pass

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			is_dragging = true
			start_pos = event.position
			current_pos = event.position
			queue_redraw()
		else:
			is_dragging = false
			start_pos = Vector2.ZERO
			current_pos = Vector2.ZERO
			stick_moved.emit(Vector2.ZERO)
			queue_redraw()
			
	elif event is InputEventScreenDrag or event is InputEventMouseMotion:
		if is_dragging:
			current_pos = event.position
			var drag_vector = current_pos - start_pos
			if drag_vector.length() > max_radius:
				drag_vector = drag_vector.normalized() * max_radius
				
			var normalized_dir = drag_vector / max_radius
			stick_moved.emit(normalized_dir)
			queue_redraw()

func _draw() -> void:
	if is_dragging:
		# 半透明の黒い円（ベース）
		draw_circle(start_pos, max_radius, Color(0.0, 0.0, 0.0, 0.4))
		# 白い円（スティック）
		var drag_vector = current_pos - start_pos
		if drag_vector.length() > max_radius:
			drag_vector = drag_vector.normalized() * max_radius
		draw_circle(start_pos + drag_vector, 30.0, Color(1.0, 1.0, 1.0, 0.8))
