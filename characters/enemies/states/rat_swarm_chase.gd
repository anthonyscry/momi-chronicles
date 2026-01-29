extends State
class_name RatSwarmChase
## Swarm chase state for Sewer Rats — coordinated pack movement.
## Rats move toward the player but gravitate slightly toward their pack center,
## with erratic jitter for a scurrying feel.

## How strongly rats are pulled toward pack center (0 = none, 1 = full)
const PACK_COHESION: float = 0.25
## Jitter re-roll interval (seconds)
const JITTER_INTERVAL: float = 0.3
## Maximum jitter magnitude
const JITTER_STRENGTH: float = 20.0

var jitter_timer: float = 0.0
var jitter_offset: Vector2 = Vector2.ZERO

func enter() -> void:
	jitter_timer = 0.0
	jitter_offset = _random_jitter()


func physics_update(delta: float) -> void:
	# Can't act while stunned
	if not player.can_act():
		player.velocity = Vector2.ZERO
		player.move_and_slide()
		return

	# Lost target — go idle
	if not player.target:
		state_machine.transition_to("Idle")
		return

	# Too far, lose interest
	if player.should_lose_interest():
		player.target = null
		state_machine.transition_to("Idle")
		return

	# In attack range — bite!
	if player.is_target_in_attack_range() and player.can_attack:
		state_machine.transition_to("RatPoisonAttack")
		return

	# --- Swarm movement ---
	var direction = player.get_direction_to_target()
	var base_velocity = direction * player.chase_speed

	# Pack cohesion: steer slightly toward average position of pack mates
	var pack_center = _get_pack_center()
	if pack_center != Vector2.ZERO:
		var to_center = (pack_center - player.global_position).normalized()
		base_velocity += to_center * player.chase_speed * PACK_COHESION

	# Erratic jitter (re-roll periodically)
	jitter_timer += delta
	if jitter_timer >= JITTER_INTERVAL:
		jitter_timer -= JITTER_INTERVAL
		jitter_offset = _random_jitter()

	base_velocity += jitter_offset

	# Separation from nearby enemies (prevents stacking)
	var separation = player.get_separation_force() * 40.0
	player.velocity = base_velocity + separation
	player.update_facing(direction)
	player.move_and_slide()


## Compute the average position of same-pack rats (excluding self).
func _get_pack_center() -> Vector2:
	var pack_positions: Array[Vector2] = []
	for enemy in player.get_tree().get_nodes_in_group("enemies"):
		if enemy == player or not is_instance_valid(enemy):
			continue
		if enemy is SewerRat and enemy.pack_id == player.pack_id:
			pack_positions.append(enemy.global_position)
	if pack_positions.is_empty():
		return Vector2.ZERO
	var center = Vector2.ZERO
	for pos in pack_positions:
		center += pos
	return center / pack_positions.size()


## Generate a small random velocity offset for scurrying feel.
func _random_jitter() -> Vector2:
	return Vector2(
		randf_range(-JITTER_STRENGTH, JITTER_STRENGTH),
		randf_range(-JITTER_STRENGTH, JITTER_STRENGTH)
	)
