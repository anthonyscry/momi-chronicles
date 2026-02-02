extends "res://characters/enemies/states/enemy_death.gd"
class_name RatDeath

## Roof Rat death state - falls down and fades out.

const FALL_DURATION: float = 0.5
var fall_time: float = 0.0

func enter() -> void:
	player.velocity = Vector2.ZERO
	
	if player.sprite:
		player.sprite.play("death")
	
	if player.hitbox:
		player.hitbox.monitoring = false
		player.hitbox.monitorable = false
	
	fall_time = 0.0

func update(delta: float) -> void:
	fall_time += delta
	
	if fall_time < FALL_DURATION:
		player.global_position.y += delta * 150
	else:
		player.queue_free()

func exit() -> void:
	pass
