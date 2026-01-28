extends State
class_name PlayerHurt

const HURT_DURATION: float = 0.3
const INVINCIBILITY_DURATION: float = 1.0
const FLASH_INTERVAL: float = 0.08

var hurt_timer: float = 0.0
var flash_timer: float = 0.0
var sprite_visible: bool = true

func enter() -> void:
	player.velocity = Vector2.ZERO
	hurt_timer = 0.0
	flash_timer = 0.0
	sprite_visible = true
	
	if player.hurtbox:
		player.hurtbox.start_invincibility(INVINCIBILITY_DURATION)

func exit() -> void:
	if player.sprite:
		player.sprite.visible = true

func physics_update(delta: float) -> void:
	hurt_timer += delta
	
	flash_timer += delta
	if flash_timer >= FLASH_INTERVAL:
		flash_timer = 0.0
		sprite_visible = not sprite_visible
		if player.sprite:
			player.sprite.visible = sprite_visible
	
	if hurt_timer >= HURT_DURATION:
		state_machine.transition_to("Idle")
