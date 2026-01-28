extends State
class_name EnemyIdle
## Enemy idle state - waits and looks for player.

@export var idle_duration: float = 2.0
var idle_timer: float = 0.0

## Random wander settings
var wander_range: float = 50.0  # How far to wander from spawn
var spawn_position: Vector2 = Vector2.ZERO

func enter() -> void:
	player.velocity = Vector2.ZERO
	idle_timer = 0.0
	# Remember spawn position for wandering
	if spawn_position == Vector2.ZERO:
		spawn_position = player.global_position

func physics_update(delta: float) -> void:
	# Can't act while stunned
	if not player.can_act():
		return
	
	# Check for target
	if player.target and player.is_target_in_detection_range():
		state_machine.transition_to("Chase")
		return
	
	# Wait then patrol or wander
	idle_timer += delta
	if idle_timer >= idle_duration:
		if not player.patrol_points.is_empty():
			state_machine.transition_to("Patrol")
		else:
			# No patrol points - do random wander
			_start_random_wander()

func _start_random_wander() -> void:
	# Generate a random point near spawn position
	var random_offset = Vector2(
		randf_range(-wander_range, wander_range),
		randf_range(-wander_range, wander_range)
	)
	var wander_target = spawn_position + random_offset
	
	# Temporarily add as patrol point and go patrol
	var points: Array[Vector2] = [wander_target]
	player.patrol_points = points
	state_machine.transition_to("Patrol")
