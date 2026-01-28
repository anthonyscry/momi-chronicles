extends Control
class_name GuardBar
## Displays player guard meter as a bar. Fades when full, solid when depleting.

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label

func _ready() -> void:
	# Connect to guard events
	Events.guard_changed.connect(_on_guard_changed)
	
	# Initialize with full guard (faded)
	_update_display(100.0, 100.0)

func _on_guard_changed(current: float, max_guard: float) -> void:
	_update_display(current, max_guard)

func _update_display(current: float, max_guard: float) -> void:
	if progress_bar:
		progress_bar.max_value = max_guard
		progress_bar.value = current
	
	if label:
		label.text = "%d" % int(current)
	
	# Fade when full, solid when depleting
	var percent = current / max_guard if max_guard > 0 else 1.0
	if percent >= 1.0:
		modulate.a = 0.3  # Faded when full
	else:
		modulate.a = 1.0  # Solid when depleting
	
	# Color based on guard percentage (blue/cyan theme)
	if progress_bar:
		if percent > 0.5:
			progress_bar.modulate = Color(0.3, 0.7, 1.0)  # Blue
		elif percent > 0.25:
			progress_bar.modulate = Color(0.2, 0.5, 0.9)  # Darker blue
		else:
			progress_bar.modulate = Color(0.4, 0.3, 0.8)  # Purple-ish (danger)
