extends State
class_name EnemyChase
## Enemy chase state - pursues the player.

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
	
	# In attack range
	if player.is_target_in_attack_range() and player.can_attack:
		state_machine.transition_to("Attack")
		return
	
	# Chase player
	var direction = player.get_direction_to_target()
	player.velocity = direction * player.chase_speed
	player.update_facing(direction)
	player.move_and_slide()
