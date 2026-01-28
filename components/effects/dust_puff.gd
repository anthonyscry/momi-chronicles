extends Node2D
## Dust puff effect - plays when dodging or landing.
## Auto-hides after animation completes.

@onready var particles: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	hide()
	particles.emitting = false


func play() -> void:
	show()
	particles.restart()
	particles.emitting = true
	
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	hide()
	particles.emitting = false


func setup(params: Dictionary) -> void:
	# Adjust direction if provided
	if params.has("direction"):
		var dir: Vector2 = params["direction"]
		if dir != Vector2.ZERO:
			# Emit opposite to movement direction
			particles.direction = -dir.normalized()
