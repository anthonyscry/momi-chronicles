extends State
class_name PigeonHurt

## Pigeon hurt state - brief pause, checks flee condition.

# ==============================================================================
# SETTINGS
# ==============================================================================

const PAUSE_DURATION: float = 0.3

# ==============================================================================
# STATE
# ==============================================================================

var pause_time: float = 0.0

# ==============================================================================
# LIFECYCLE
# ==============================================================================

func enter() -> void:
	player.velocity = Vector2.ZERO
	
	if player.sprite:
		player.sprite.play("hurt")
	
	# Check if should flee
	_check_flee_condition()
	
	pause_time = 0.0

func exit() -> void:
	pause_time = 0.0

func physics_update(delta: float) -> void:
	pause_time += delta
	
	# Flee immediately if fleeing
	if player.is_fleeing:
		state_machine.transition_to("FlockChase")
		return
	
	# Return to previous state after pause
	if pause_time >= PAUSE_DURATION:
		if player.is_fleeing:
			state_machine.transition_to("FlockChase")
		else:
			state_machine.transition_to("FlockIdle")

# ==============================================================================
# FLEE BEHAVIOR
# ==============================================================================

func _check_flee_condition() -> void:
	if not player.health:
		return
	
	var health_percent = float(player.health.current_health) / float(player.health.max_health)
	
	if health_percent <= player.FLEE_HP_THRESHOLD:
		player.is_fleeing = true
		Events.pigeon_fled.emit(player.flock_id, player)
