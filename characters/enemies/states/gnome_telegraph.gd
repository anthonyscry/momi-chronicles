extends State

## Gnome telegraph state - shows orange pulsing "!" before throwing bomb.
## Gives player warning to dodge.

var telegraph_time: float = 0.0

func enter() -> void:
	player.velocity = Vector2.ZERO
	
	if player.sprite:
		player.sprite.play("telegraph")
	
	player.show_telegraph()
	player.pulse_phase = 0.0
	telegraph_time = 0.0


func update(delta: float) -> void:
	telegraph_time += delta
	
	# Animate the telegraph pulsing
	player.update_telegraph_pulse(delta)
	
	if telegraph_time >= player.TELEGRAPH_DURATION:
		state_machine.transition_to("GnomeThrow")


func exit() -> void:
	player.hide_telegraph()
	player.reset_telegraph()
	telegraph_time = 0.0
