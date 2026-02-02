extends State

## Gnome idle state - waits and looks for player.
## Stationary enemy that scans for player proximity.

var scan_timer: float = 0.0
const SCAN_INTERVAL: float = 0.5

func enter() -> void:
	player.velocity = Vector2.ZERO
	
	if player.sprite:
		player.sprite.play("idle")
	
	player.hide_telegraph()
	scan_timer = 0.0


func update(delta: float) -> void:
	scan_timer += delta
	
	if scan_timer >= SCAN_INTERVAL:
		scan_timer = 0.0
		_check_for_player()


func _check_for_player() -> void:
	var player_node = _get_player_in_range()
	if player_node:
		state_machine.transition_to("GnomeTelegraph")
		return


func _get_player_in_range() -> Node:
	var detection = player.get_node_or_null("DetectionArea")
	if detection:
		var bodies = detection.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				return body
	return null


func exit() -> void:
	scan_timer = 0.0
