extends Node2D
## Hit spark effect - plays when attack connects with target.
## Auto-hides after animation completes.

@onready var particles: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	# Hide by default (pooled)
	hide()
	particles.emitting = false


func play() -> void:
	show()
	particles.restart()
	particles.emitting = true
	
	# Auto-hide after particles finish
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	hide()
	particles.emitting = false


func setup(params: Dictionary) -> void:
	# Adjust color based on damage intensity
	if params.has("color") and particles:
		particles.color = params["color"]
	if params.has("scale"):
		scale = Vector2.ONE * params["scale"]
	if params.has("amount") and particles:
		particles.amount = params["amount"]
