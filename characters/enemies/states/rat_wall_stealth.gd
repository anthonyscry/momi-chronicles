extends State
class_name RatWallStealth

## Roof Rat stealth state - semi-transparent while waiting on wall for prey.

var no_target_timer: float = 0.0

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.is_stealthed = true
	no_target_timer = 0.0
	
	if player.sprite:
		player.sprite.play("wall_idle")
		var tween = player.create_tween()
		tween.tween_property(player.sprite, "scale:y", player.wall_squish_factor, 0.2)
		tween.parallel().tween_property(player.sprite, "modulate:a", player.stealth_alpha, 0.3)

func update(delta: float) -> void:
	if not player.can_act():
		player.velocity = Vector2.ZERO
		player.move_and_slide()
		return
	
	if player.target and player.is_target_in_detection_range():
		no_target_timer = 0.0
		if _is_player_below():
			state_machine.transition_to("WallAmbush")
			return
		_track_target_approach(delta)
		return
	
	no_target_timer += delta
	if no_target_timer >= player.NO_TARGET_TIMEOUT:
		state_machine.transition_to("WallRun")
		return
	
	player.velocity = Vector2.ZERO
	player.move_and_slide()

func _is_player_below() -> bool:
	if not player.target:
		return false
	var to_target = player.target.global_position - player.global_position
	return to_target.y > 0 and abs(to_target.x) < 40.0

func _track_target_approach(delta: float) -> void:
	var to_target = player.target.global_position - player.global_position
	var distance = to_target.length()
	
	if distance < player.AMBUSH_TRIGGER_DISTANCE and _is_player_below():
		state_machine.transition_to("WallAmbush")
		return
	
	if player.sprite:
		if to_target.x > 0:
			player.sprite.flip_h = false
		elif to_target.x < 0:
			player.sprite.flip_h = true

func exit() -> void:
	no_target_timer = 0.0
	player.is_stealthed = false
	if player.sprite:
		var tween = player.create_tween()
		tween.tween_property(player.sprite, "scale:y", 1.0, 0.1)
		tween.parallel().tween_property(player.sprite, "modulate:a", 1.0, 0.15)
