extends "res://characters/enemies/states/enemy_hurt.gd"
class_name RatHurt

## Roof Rat hurt state - brief pause then returns to stealth.

const PAUSE_DURATION: float = 0.25

var pause_time: float = 0.0

func enter() -> void:
	player.velocity = Vector2.ZERO
	
	if player.sprite:
		player.sprite.play("hurt")
	
	pause_time = 0.0

func update(delta: float) -> void:
	pause_time += delta
	
	if player.sprite and not player.sprite.is_playing():
		if player.health.current_health <= 0:
			state_machine.transition_to("Death")
		else:
			state_machine.transition_to("WallStealth")
	
	if pause_time >= PAUSE_DURATION:
		state_machine.transition_to("WallStealth")

func exit() -> void:
	pause_time = 0.0
