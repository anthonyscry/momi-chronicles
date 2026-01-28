extends State
class_name PlayerDodge

const DODGE_SPEED: float = 200.0
const DODGE_DURATION: float = 0.3
const INVINCIBILITY_DURATION: float = 0.35

var dodge_timer: float = 0.0
var dodge_direction: Vector2 = Vector2.ZERO

func enter() -> void:
	dodge_timer = 0.0
	
	dodge_direction = player.get_input_direction()
	if dodge_direction == Vector2.ZERO:
		match player.facing_direction:
			"down":
				dodge_direction = Vector2.DOWN
			"up":
				dodge_direction = Vector2.UP
			"side":
				dodge_direction = Vector2.LEFT if player.facing_left else Vector2.RIGHT
	
	dodge_direction = dodge_direction.normalized()
	
	if player.hurtbox:
		player.hurtbox.start_invincibility(INVINCIBILITY_DURATION)
	
	if player.sprite:
		player.sprite.color.a = 0.5
	
	# Emit dodge event for audio
	Events.player_dodged.emit()

func exit() -> void:
	if player.sprite:
		player.sprite.color.a = 1.0

func physics_update(delta: float) -> void:
	dodge_timer += delta
	
	var progress = dodge_timer / DODGE_DURATION
	var speed_multiplier = 1.0 - (progress * progress)
	
	player.velocity = dodge_direction * DODGE_SPEED * speed_multiplier
	player.move_and_slide()
	
	if dodge_timer >= DODGE_DURATION:
		state_machine.transition_to("Idle")
