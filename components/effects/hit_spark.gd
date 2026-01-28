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


func setup(_params: Dictionary) -> void:
	# No special setup needed for hit sparks
	pass
