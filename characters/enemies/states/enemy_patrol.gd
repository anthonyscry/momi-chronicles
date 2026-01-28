extends State
class_name EnemyPatrol
## Enemy patrol state - moves between waypoints.

var target_point: Vector2
var reached_threshold: float = 8.0
var is_temporary_wander: bool = false

func enter() -> void:
	target_point = player.get_current_patrol_point()
	# Check if this is a temporary wander (single point)
	is_temporary_wander = player.patrol_points.size() == 1

func physics_update(delta: float) -> void:
	# Check for stun
	if player.has_method("can_act") and not player.can_act():
		player.velocity = Vector2.ZERO
		return
	
	# Check for player
	if player.target and player.is_target_in_detection_range():
		_clear_temp_wander()
		state_machine.transition_to("Chase")
		return
	
	# Move toward patrol point
	var direction = (target_point - player.global_position).normalized()
	var distance = player.global_position.distance_to(target_point)
	
	if distance <= reached_threshold:
		# Reached point
		if is_temporary_wander:
			# Clear temporary point and go back to idle
			_clear_temp_wander()
			state_machine.transition_to("Idle")
		else:
			# Get next patrol point
			target_point = player.get_next_patrol_point()
			state_machine.transition_to("Idle")
		return
	
	player.velocity = direction * player.patrol_speed
	player.update_facing(direction)
	player.move_and_slide()

func _clear_temp_wander() -> void:
	if is_temporary_wander:
		player.patrol_points.clear()
		is_temporary_wander = false
