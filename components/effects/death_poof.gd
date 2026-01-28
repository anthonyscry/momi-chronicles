extends Node2D
## Death poof effect - plays when enemy is defeated.
## Larger, more dramatic particle burst.

@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var flash: ColorRect = $Flash

func _ready() -> void:
	hide()
	particles.emitting = false
	if flash:
		flash.hide()


func play() -> void:
	show()
	
	# Brief white flash
	if flash:
		flash.show()
		var tween = create_tween()
		tween.tween_property(flash, "modulate:a", 0.0, 0.15)
		tween.tween_callback(flash.hide)
	
	particles.restart()
	particles.emitting = true
	
	await get_tree().create_timer(particles.lifetime + 0.2).timeout
	hide()
	particles.emitting = false


func setup(_params: Dictionary) -> void:
	pass
