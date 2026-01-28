extends State
class_name EnemyHurt
## Enemy hurt state - reaction to taking damage.

const HURT_DURATION: float = 0.25
var hurt_timer: float = 0.0

func enter() -> void:
	hurt_timer = 0.0
	
	# Flash effect
	player.flash_damage()
	
	# Brief invincibility
	if player.hurtbox:
		player.hurtbox.start_invincibility(0.3)

func physics_update(delta: float) -> void:
	hurt_timer += delta
	
	# Apply knockback velocity decay
	player.velocity = player.velocity.move_toward(Vector2.ZERO, 200 * delta)
	player.move_and_slide()
	
	if hurt_timer >= HURT_DURATION:
		# Return to chase if target exists, else idle
		if player.target:
			state_machine.transition_to("Chase")
		else:
			state_machine.transition_to("Idle")
