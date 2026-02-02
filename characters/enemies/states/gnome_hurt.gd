extends State

## Gnome hurt state - reaction to taking damage.
## Interrupts telegraph/throw animations and hides telegraph sprite.

const PAUSE_DURATION: float = 0.4
var pause_time: float = 0.0

func enter() -> void:
	player.velocity = Vector2.ZERO
	
	if player.sprite:
		player.sprite.play("hurt")
	
	player.flash_damage()
	pause_time = 0.0
	_interrupt_any_action()
	
	if player.hurtbox:
		player.hurtbox.start_invincibility(0.3)


func _interrupt_any_action() -> void:
	player.hide_telegraph()


func update(delta: float) -> void:
	pause_time += delta
	
	if pause_time >= PAUSE_DURATION:
		_return_to_cycle()


func _return_to_cycle() -> void:
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		var dist = player.global_position.distance_to(player_node.global_position)
		if dist < player.ATTACK_RANGE:
			state_machine.transition_to("GnomeTelegraph")
		else:
			state_machine.transition_to("GnomeIdle")
	else:
		state_machine.transition_to("GnomeIdle")


func exit() -> void:
	pause_time = 0.0
