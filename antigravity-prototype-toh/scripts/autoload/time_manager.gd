extends Node

# 0.0 to 1.0 (0.0 = Morning, 0.5 = Evening, 1.0 = Night/Cycle End)
var time: float = 0.2 # Start at 0.2 (Daytime)
var day_duration: float = 60.0 # 60 seconds for a full cycle (adjust as needed)

var is_night: bool = false

signal time_updated(current_time: float, is_night: bool)

func _process(delta: float) -> void:
	time += delta / day_duration
	if time >= 1.0:
		time = 0.0
		
	# Determine if it's night (e.g., between 0.7 and 1.0, or before 0.2)
	# For simplicity: 0.0-0.6 = Day, 0.6-1.0 = Night
	var new_night = (time > 0.6 or time < 0.1)
	if new_night != is_night:
		is_night = new_night
		
	time_updated.emit(time, is_night)

func get_time_string() -> String:
	if is_night:
		return "Night"
	return "Day"
