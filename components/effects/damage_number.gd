extends Node2D
## Floating damage number that pops up and fades out.

@onready var label: Label = $Label

const FLOAT_DISTANCE: float = 20.0
const FLOAT_DURATION: float = 0.8
const SPREAD_RANGE: float = 10.0

var start_position: Vector2
var is_crit: bool = false

func _ready() -> void:
	hide()


func play() -> void:
	show()
	start_position = global_position
	
	# Add random horizontal spread
	var spread = randf_range(-SPREAD_RANGE, SPREAD_RANGE)
	
	# Critical hits get more dramatic animation
	var float_dist = FLOAT_DISTANCE * (1.5 if is_crit else 1.0)
	var duration = FLOAT_DURATION * (1.2 if is_crit else 1.0)
	
	# Animate floating up and fading
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Float up with slight arc
	tween.tween_property(self, "global_position", 
		start_position + Vector2(spread, -float_dist), duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	# Scale pop - bigger for crits
	var pop_scale = 1.6 if is_crit else 1.2
	label.scale = Vector2(0.3 if is_crit else 0.5, 0.3 if is_crit else 0.5)
	tween.tween_property(label, "scale", Vector2(pop_scale, pop_scale), 0.12)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_property(label, "scale", Vector2(1.0, 1.0), 0.15)
	
	# Shake for crits
	if is_crit:
		_shake_label()
	
	# Fade out near end
	tween.tween_property(label, "modulate:a", 0.0, duration * 0.4)\
		.set_delay(duration * 0.6)
	
	tween.set_parallel(false)
	tween.tween_callback(_on_complete)


func _shake_label() -> void:
	# Quick shake animation for critical hits
	var shake_tween = create_tween()
	for i in range(4):
		var offset = Vector2(randf_range(-3, 3), randf_range(-2, 2))
		shake_tween.tween_property(label, "position", offset, 0.03)
	shake_tween.tween_property(label, "position", Vector2.ZERO, 0.03)


func _on_complete() -> void:
	hide()
	label.modulate.a = 1.0
	label.scale = Vector2.ONE


func setup(params: Dictionary) -> void:
	var amount: int = params.get("amount", 0)
	var is_critical: bool = params.get("is_critical", false)
	is_crit = is_critical
	
	if is_critical:
		label.text = str(amount) + "!"
		label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		label.add_theme_color_override("font_outline_color", Color(1, 0.8, 0.2))
		label.add_theme_constant_override("outline_size", 2)
		label.add_theme_font_size_override("font_size", 14)
	else:
		label.text = str(amount)
		label.add_theme_color_override("font_color", Color(1, 1, 1))
		label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		label.add_theme_constant_override("outline_size", 1)
		label.add_theme_font_size_override("font_size", 10)
