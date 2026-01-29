extends State
class_name CatRetreat
## Cat retreat state - flees away from target after pounce, fades back into stealth.

const RETREAT_DURATION: float = 0.8

var retreat_timer: float = 0.0
var retreat_direction: Vector2 = Vector2.ZERO

func enter() -> void:
	retreat_timer = 0.0
	
	# Calculate direction AWAY from target (or last known position)
	if player.target:
		retreat_direction = -player.get_direction_to_target()
	else:
		# No target — retreat in opposite of facing direction
		retreat_direction = -player.facing_direction
	
	# Set retreat velocity
	player.velocity = retreat_direction * player.chase_speed
	player.update_facing(retreat_direction)
	
	# Gradually fade sprite alpha back to stealth_alpha over retreat duration
	if player.sprite:
		var tween = player.create_tween()
		tween.tween_property(player.sprite, "modulate:a", player.stealth_alpha, RETREAT_DURATION)\
			.set_ease(Tween.EASE_IN)


func physics_update(delta: float) -> void:
	# Can't act while stunned
	if not player.can_act():
		player.velocity = Vector2.ZERO
		player.move_and_slide()
		return
	
	retreat_timer += delta
	
	# Decelerate smoothly during retreat
	player.velocity = retreat_direction * player.chase_speed * (1.0 - retreat_timer / RETREAT_DURATION)
	player.move_and_slide()
	
	# Retreat finished — return to stealth
	if retreat_timer >= RETREAT_DURATION:
		player.is_stealthed = true
		state_machine.transition_to("CatStealth")
