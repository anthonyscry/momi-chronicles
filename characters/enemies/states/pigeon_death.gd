extends State
class_name PigeonDeath

## Pigeon death state - falls, fades out, removed from flock.

# ==============================================================================
# SETTINGS
# ==============================================================================

const FALL_DURATION: float = 0.4
const FADE_DURATION: float = 0.3

# ==============================================================================
# STATE
# ==============================================================================

var fall_time: float = 0.0

# ==============================================================================
# LIFECYCLE
# ==============================================================================

func enter() -> void:
	player.velocity = Vector2.ZERO
	
	if player.sprite:
		player.sprite.play("death")
	
	# Disable hitbox
	if player.hitbox:
		player.hitbox.monitoring = false
		player.hitbox.monitorable = false
		var shape = player.hitbox.get_node_or_null("CollisionShape2D")
		if shape:
			shape.disabled = true
	
	# Disable hurtbox
	if player.hurtbox:
		player.hurtbox.is_invincible = true
	
	# Remove from collision
	player.set_collision_layer_value(3, false)
	
	fall_time = 0.0
	
	# Notify flock of death
	Events.pigeon_died.emit(player.flock_id, player)

func physics_update(delta: float) -> void:
	fall_time += delta
	
	# Fall down
	if fall_time < FALL_DURATION:
		player.global_position.y += delta * 200
	
	# Fade out after falling
	elif fall_time < FALL_DURATION + FADE_DURATION:
		if player.sprite:
			var fade_progress = (fall_time - FALL_DURATION) / FADE_DURATION
			player.sprite.modulate.a = 1.0 - fade_progress
	
	# Remove from scene
	else:
		player.queue_free()
