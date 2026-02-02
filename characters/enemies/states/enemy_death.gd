extends State
class_name EnemyDeath

const DEATH_DURATION: float = 0.5
var death_timer: float = 0.0

func enter() -> void:
	player.velocity = Vector2.ZERO
	death_timer = 0.0
	if player.sprite:
		player.sprite.play("death")
	
	if player.hitbox:
		player.hitbox.disable()
	if player.hurtbox:
		player.hurtbox.is_invincible = true
	
	player.set_collision_layer_value(3, false)
	_fade_out()

func physics_update(delta: float) -> void:
	death_timer += delta
	if death_timer >= DEATH_DURATION:
		player.queue_free()

func _fade_out() -> void:
	if player.sprite:
		var tween = player.create_tween()
		tween.tween_property(player.sprite, "modulate:a", 0.0, DEATH_DURATION)
