extends State
class_name EnemyAttack
## Enemy attack state - performs an attack on the player.

const ATTACK_DURATION: float = 0.4
const HITBOX_START: float = 0.15
const HITBOX_END: float = 0.35

var attack_timer: float = 0.0
var hitbox_active: bool = false

func enter() -> void:
	player.velocity = Vector2.ZERO
	attack_timer = 0.0
	hitbox_active = false
	
	# Face the target
	if player.target:
		var direction = player.get_direction_to_target()
		player.update_facing(direction)
		_position_hitbox(direction)
	
	# Reset hitbox
	if player.hitbox:
		player.hitbox.reset()
	
	# Start cooldown
	player.start_attack_cooldown()

func exit() -> void:
	if player.hitbox:
		player.hitbox.disable()
	hitbox_active = false

func physics_update(delta: float) -> void:
	# Cancel attack if stunned
	if not player.can_act():
		if player.hitbox:
			player.hitbox.disable()
		state_machine.transition_to("Idle")
		return
	
	attack_timer += delta
	var progress = attack_timer / ATTACK_DURATION
	
	# Enable hitbox during active frames
	if progress >= HITBOX_START and progress < HITBOX_END:
		if not hitbox_active and player.hitbox:
			player.hitbox.enable()
			hitbox_active = true
	elif progress >= HITBOX_END:
		if hitbox_active and player.hitbox:
			player.hitbox.disable()
			hitbox_active = false
	
	# Attack finished
	if attack_timer >= ATTACK_DURATION:
		state_machine.transition_to("Chase")

func _position_hitbox(direction: Vector2) -> void:
	if not player.hitbox:
		return
	
	var hitbox_shape = player.hitbox.get_node_or_null("CollisionShape2D")
	if not hitbox_shape:
		return
	
	# Position based on direction
	hitbox_shape.position = direction.normalized() * 12
