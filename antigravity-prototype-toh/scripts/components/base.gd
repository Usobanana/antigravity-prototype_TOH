extends Node3D

@onready var sun = $DirectionalLight3D

func _ready() -> void:
	if TimeManager:
		TimeManager.time_updated.connect(_on_time_updated)
		_on_time_updated(TimeManager.time, TimeManager.is_night)

func _on_time_updated(current_time: float, is_night: bool) -> void:
	if not sun: return
	
	# Rotate the sun based on time
	var elevation = current_time * PI * 2.0
	sun.rotation.x = -elevation
	
	# Adjust light color and energy
	if is_night:
		sun.light_color = Color(0.5, 0.5, 0.8)
		sun.light_energy = 1.2
	else:
		if current_time > 0.5: # Evening
			sun.light_color = Color(1.0, 0.6, 0.4)
			sun.light_energy = 1.0
		else: # Morning/Day
			sun.light_color = Color(1.0, 1.0, 0.9)
			sun.light_energy = 1.2
