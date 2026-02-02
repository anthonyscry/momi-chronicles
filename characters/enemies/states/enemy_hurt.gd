extends State
class_name EnemyHurt
## Enemy hurt state - reaction to taking damage.

const HURT_DURATION: float = 0.25
var hurt_timer: float = 0.0

func enter() -> void:
	hurt_timer = 0.0
	if player.sprite:
		player.sprite.play("hurt")
	player.flash_damage()
	
	_apply_hit_stagger()
	
	if player.hurtbox:
		player.hurtbox.start_invincibility(0.3)


## Apply visual stagger effect on hit
func _apply_hit_stagger() -> void:
	# Get sprite or visual node
	var sprite = player.get_node_or_null("Sprite2D")
	if sprite == null:
		sprite = player.get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		sprite = player.get_node_or_null("ColorRect")  # Placeholder visuals
	if sprite == null:
		return
	
	# Save original values
	var original_scale = sprite.scale
	var original_rotation = sprite.rotation
	
	# Quick squash on impact
	var tween = player.create_tween()
	tween.tween_property(sprite, "scale", original_scale * Vector2(1.3, 0.7), 0.04)
	tween.tween_property(sprite, "scale", original_scale * Vector2(0.8, 1.2), 0.04)
	tween.tween_property(sprite, "scale", original_scale, 0.06)
	
	# Slight rotation shake
	var shake_tween = player.create_tween()
	shake_tween.tween_property(sprite, "rotation", original_rotation + 0.15, 0.03)
	shake_tween.tween_property(sprite, "rotation", original_rotation - 0.1, 0.03)
	shake_tween.tween_property(sprite, "rotation", original_rotation, 0.04)

func physics_update(delta: float) -> void:
	hurt_timer += delta
	
	# Curved knockback decay: fast at start, smooth stop
	# Using exponential decay for snappy feel (higher = faster decay)
	var decay_rate = 8.0
	player.velocity *= exp(-decay_rate * delta)
	
	# Snap to zero when very slow (avoid endless drift)
	if player.velocity.length() < 5.0:
		player.velocity = Vector2.ZERO
	
	player.move_and_slide()
	
	if hurt_timer >= HURT_DURATION:
		# Return to chase if target exists, else idle
		if player.target:
			state_machine.transition_to("Chase")
		else:
			state_machine.transition_to("Idle")
