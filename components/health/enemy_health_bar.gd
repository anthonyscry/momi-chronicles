extends Control
class_name EnemyHealthBar
## Small health bar that floats above enemies.
## Only shows when enemy is damaged, fades out after a delay.

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var background: ColorRect = $Background

## How long to show the health bar after taking damage
const SHOW_DURATION: float = 3.0

## Fade out time
const FADE_TIME: float = 0.5

var show_timer: float = 0.0
var is_showing: bool = false

func _ready() -> void:
	# Start hidden
	modulate.a = 0.0
	is_showing = false


func _process(delta: float) -> void:
	if show_timer > 0:
		show_timer -= delta
		if show_timer <= 0:
			_fade_out()


func update_health(current: int, max_health: int) -> void:
	if progress_bar == null:
		return
	
	progress_bar.max_value = max_health
	progress_bar.value = current
	
	# Color based on health percentage
	var percent = float(current) / float(max_health) if max_health > 0 else 0.0
	if percent > 0.5:
		progress_bar.modulate = Color(0.2, 0.9, 0.2)  # Green
	elif percent > 0.25:
		progress_bar.modulate = Color(0.95, 0.75, 0.1)  # Yellow/Orange
	else:
		progress_bar.modulate = Color(0.95, 0.2, 0.2)  # Red
	
	# Show the bar when health changes (but not at full health on spawn)
	if current < max_health:
		_show_bar()


func _show_bar() -> void:
	if not is_showing:
		is_showing = true
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.1)
	
	# Reset hide timer
	show_timer = SHOW_DURATION


func _fade_out() -> void:
	is_showing = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)


## Force show (for bosses or always-visible bars)
func show_always() -> void:
	is_showing = true
	modulate.a = 1.0
	show_timer = 999999.0  # Never hide
