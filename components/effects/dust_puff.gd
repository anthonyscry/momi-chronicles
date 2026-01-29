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
	if params.has("direction") and particles:
		var dir: Vector2 = params["direction"]
		if dir != Vector2.ZERO:
			# Emit opposite to movement direction
			particles.direction = -dir.normalized()
	if params.has("color") and particles:
		particles.color = params["color"]
	if params.has("scale"):
		scale = Vector2.ONE * params["scale"]
	if params.has("amount") and particles:
		particles.amount = params["amount"]
