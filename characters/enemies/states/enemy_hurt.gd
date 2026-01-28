extends State
class_name EnemyHurt
## Enemy hurt state - reaction to taking damage.

const HURT_DURATION: float = 0.25
var hurt_timer: float = 0.0

func enter() -> void:
	hurt_timer = 0.0
	
	# Flash effect
	player.flash_damage()
	
	# Visual stagger - quick squash/stretch and shake
	_apply_hit_stagger()
	
	# Brief invincibility
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
	
	# Apply knockback velocity decay
	player.velocity = player.velocity.move_toward(Vector2.ZERO, 200 * delta)
	player.move_and_slide()
	
	if hurt_timer >= HURT_DURATION:
		# Return to chase if target exists, else idle
		if player.target:
			state_machine.transition_to("Chase")
		else:
			state_machine.transition_to("Idle")
