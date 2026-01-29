extends State
class_name ShadowPhase
## Shadow phase state — the shadow creature drifts while phased out,
## detects targets, and transitions to ranged attack when phased in.

## Slow drift speed while in phase state
var drift_speed: float = 15.0
var drift_direction: Vector2 = Vector2.ZERO
var drift_timer: float = 0.0
var drift_change_interval: float = 2.0


func enter() -> void:
	# Start phased out
	if player.has_method("_phase_out"):
		player._phase_out()
		player.phase_timer = 0.0

	# Pick random drift direction
	_pick_drift_direction()


func physics_update(delta: float) -> void:
	# Can't act while stunned
	if not player.can_act():
		player.velocity = Vector2.ZERO
		player.move_and_slide()
		return

	# Slow random drift
	drift_timer += delta
	if drift_timer >= drift_change_interval:
		drift_timer = 0.0
		_pick_drift_direction()

	player.velocity = drift_direction * drift_speed
	player.move_and_slide()

	# Check for target
	if player.target and player.is_target_in_detection_range():
		# If phased in (visible), transition to ranged attack
		if not player.is_phased_out and player.can_attack:
			state_machine.transition_to("ShadowRangedAttack")
			return

		# If phased out but target detected, drift toward target slowly
		if player.is_phased_out:
			var dir = player.get_direction_to_target()
			player.velocity = dir * drift_speed * 1.5
			player.update_facing(dir)
			player.move_and_slide()


func _pick_drift_direction() -> void:
	var angle = randf() * TAU
	drift_direction = Vector2(cos(angle), sin(angle))
