extends State
class_name CatStealth
## Cat stealth state - nearly invisible, slowly approaches target, then pounces.

var no_target_timer: float = 0.0
const NO_TARGET_TIMEOUT: float = 3.0

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.is_stealthed = true
	no_target_timer = 0.0
	
	# Fade to stealth transparency
	if player.sprite:
		var tween = player.create_tween()
		tween.tween_property(player.sprite, "modulate:a", player.stealth_alpha, 0.3)


func physics_update(delta: float) -> void:
	# Can't act while stunned
	if not player.can_act():
		player.velocity = Vector2.ZERO
		player.move_and_slide()
		return
	
	# Target detected within detection range — stalk slowly
	if player.target and player.is_target_in_detection_range():
		no_target_timer = 0.0
		var distance = player.get_distance_to_target()
		
		# Close enough to pounce
		if distance <= player.attack_range and player.can_attack:
			state_machine.transition_to("CatPounce")
			return
		
		# Slowly approach while staying transparent
		var direction = player.get_direction_to_target()
		player.velocity = direction * player.patrol_speed * 0.5
		player.update_facing(direction)
		player.move_and_slide()
		return
	
	# No target — wait, then go to idle
	no_target_timer += delta
	if no_target_timer >= NO_TARGET_TIMEOUT:
		state_machine.transition_to("Idle")
		return
	
	player.velocity = Vector2.ZERO
	player.move_and_slide()
