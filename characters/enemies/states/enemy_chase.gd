extends State
class_name EnemyChase
## Enemy chase state - pursues the player.

## Minimum distance to maintain from player (prevents overlapping)
const MIN_DISTANCE: float = 16.0
## Distance at which enemy starts circling instead of chasing
const CIRCLE_DISTANCE: float = 24.0

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	# Can't act while stunned
	if not player.can_act():
		player.velocity = Vector2.ZERO
		player.move_and_slide()
		return
	
	# Lost target
	if not player.target:
		state_machine.transition_to("Idle")
		return
	
	# Too far, lose interest
	if player.should_lose_interest():
		player.target = null
		state_machine.transition_to("Idle")
		return
	
	# In attack range and can attack
	if player.is_target_in_attack_range() and player.can_attack:
		state_machine.transition_to("Attack")
		return
	
	var distance = player.get_distance_to_target()
	var direction = player.get_direction_to_target()
	
	# Too close - back off slightly
	if distance < MIN_DISTANCE:
		player.velocity = -direction * player.chase_speed * 0.5
		player.update_facing(direction)
		player.move_and_slide()
		return
	
	# Close but can't attack - circle around player
	if distance < CIRCLE_DISTANCE and not player.can_attack:
		# Move perpendicular to player (circling)
		var circle_dir = Vector2(-direction.y, direction.x)
		# Randomly pick left or right circle direction (seeded by position)
		if fmod(player.global_position.x + player.global_position.y, 2.0) < 1.0:
			circle_dir = -circle_dir
		player.velocity = circle_dir * player.chase_speed * 0.6
		player.update_facing(direction)
		player.move_and_slide()
		return
	
	# Normal chase with separation from other enemies
	var separation = player.get_separation_force() * 40.0
	player.velocity = direction * player.chase_speed + separation
	player.update_facing(direction)
	player.move_and_slide()
