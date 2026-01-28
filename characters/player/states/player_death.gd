extends State
class_name PlayerDeath

const DEATH_DURATION: float = 0.8
var death_timer: float = 0.0

func enter() -> void:
	player.velocity = Vector2.ZERO
	death_timer = 0.0
	
	if player.hitbox:
		player.hitbox.disable()
	if player.hurtbox:
		player.hurtbox.is_invincible = true
	
	player.set_collision_layer_value(2, false)
	_death_animation()

func physics_update(delta: float) -> void:
	death_timer += delta

func _death_animation() -> void:
	if player.sprite:
		var tween = player.create_tween()
		tween.tween_property(player.sprite, "color", Color(1, 0.2, 0.2, 1), 0.2)
		tween.tween_property(player.sprite, "color", Color(1, 0.2, 0.2, 0), 0.6)
