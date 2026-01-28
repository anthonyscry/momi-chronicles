extends Node2D
## Floating damage number that pops up and fades out.

@onready var label: Label = $Label

const FLOAT_DISTANCE: float = 20.0
const FLOAT_DURATION: float = 0.8
const SPREAD_RANGE: float = 10.0

var start_position: Vector2

func _ready() -> void:
	hide()


func play() -> void:
	show()
	start_position = global_position
	
	# Add random horizontal spread
	var spread = randf_range(-SPREAD_RANGE, SPREAD_RANGE)
	
	# Animate floating up and fading
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Float up with slight arc
	tween.tween_property(self, "global_position", 
		start_position + Vector2(spread, -FLOAT_DISTANCE), FLOAT_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	# Scale pop
	label.scale = Vector2(0.5, 0.5)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1)\
		.set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Fade out near end
	tween.tween_property(label, "modulate:a", 0.0, FLOAT_DURATION * 0.4)\
		.set_delay(FLOAT_DURATION * 0.6)
	
	tween.set_parallel(false)
	tween.tween_callback(_on_complete)


func _on_complete() -> void:
	hide()
	label.modulate.a = 1.0
	label.scale = Vector2.ONE


func setup(params: Dictionary) -> void:
	var amount: int = params.get("amount", 0)
	var is_critical: bool = params.get("is_critical", false)
	
	label.text = str(amount)
	
	if is_critical:
		label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
		label.add_theme_font_size_override("font_size", 12)
	else:
		label.add_theme_color_override("font_color", Color(1, 1, 1))
		label.add_theme_font_size_override("font_size", 8)
