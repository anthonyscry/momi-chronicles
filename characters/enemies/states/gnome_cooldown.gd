extends State

## Gnome cooldown state - waits before next attack cycle.
## Monitors if player is still in range to decide next state.

var cooldown_timer: float = 0.0
var player_in_range: bool = false

func enter() -> void:
	player.velocity = Vector2.ZERO
	
	if player.sprite:
		player.sprite.play("idle")
	
	cooldown_timer = 0.0
	player_in_range = false


func update(delta: float) -> void:
	cooldown_timer += delta
	
	_check_player_proximity()
	
	if cooldown_timer >= player.COOLDOWN_DURATION:
		if player_in_range:
			state_machine.transition_to("GnomeTelegraph")
		else:
			state_machine.transition_to("GnomeIdle")


func _check_player_proximity() -> void:
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		var dist = player.global_position.distance_to(player_node.global_position)
		player_in_range = dist < player.ATTACK_RANGE
	else:
		player_in_range = false


func exit() -> void:
	cooldown_timer = 0.0
