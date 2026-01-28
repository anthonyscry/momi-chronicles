extends Control
class_name HealthBar
## Displays player health as a bar.

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label

func _ready() -> void:
	# Connect to player health events
	Events.player_health_changed.connect(_on_health_changed)
	
	# Initialize with full health
	_update_display(100, 100)

func _on_health_changed(current: int, max_health: int) -> void:
	_update_display(current, max_health)

func _update_display(current: int, max_health: int) -> void:
	if progress_bar:
		progress_bar.max_value = max_health
		progress_bar.value = current
	
	if label:
		label.text = "%d / %d" % [current, max_health]
	
	# Color based on health percentage
	var percent = float(current) / float(max_health)
	if progress_bar:
		if percent > 0.5:
			progress_bar.modulate = Color(0.2, 0.8, 0.2)  # Green
		elif percent > 0.25:
			progress_bar.modulate = Color(0.9, 0.7, 0.1)  # Yellow
		else:
			progress_bar.modulate = Color(0.9, 0.2, 0.2)  # Red
