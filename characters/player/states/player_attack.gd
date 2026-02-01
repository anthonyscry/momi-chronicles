extends State
class_name PlayerAttack
## Attack state - player performs an attack with hitbox active.

# =============================================================================
# CONFIGURATION
# =============================================================================

## How long the attack lasts
const ATTACK_DURATION: float = 0.35

## When hitbox becomes active (as fraction of duration)
const HITBOX_START: float = 0.1

## When hitbox deactivates (as fraction of duration)
const HITBOX_END: float = 0.7

# =============================================================================
# STATE
# =============================================================================

var attack_timer: float = 0.0
var hitbox_active: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================

func enter() -> void:
	# Stop movement
	player.velocity = Vector2.ZERO
	
	# Reset attack
	attack_timer = 0.0
	hitbox_active = false
	
	# Position hitbox based on facing direction
	_position_hitbox()
	
	# Reset hitbox tracking
	if player.hitbox:
		player.hitbox.reset()
	
	# Play attack animation when available
	# var anim_name = player.get_facing_animation("attack")
	# if player.animation_player.has_animation(anim_name):
	# 	player.animation_player.play(anim_name)
	
	# Emit attack event
	Events.player_attacked.emit()

func exit() -> void:
	# Ensure hitbox is disabled
	if player.hitbox:
		player.hitbox.disable()
	hitbox_active = false

func physics_update(delta: float) -> void:
	attack_timer += delta
	var progress = attack_timer / ATTACK_DURATION

	# Enable hitbox during active frames
	if progress >= HITBOX_START and progress < HITBOX_END:
		if not hitbox_active and player.hitbox:
			player.hitbox.enable()
			hitbox_active = true
			# Light attack screen shake
			EffectsManager.screen_shake(2.0, 0.1)
	elif progress >= HITBOX_END:
		if hitbox_active and player.hitbox:
			player.hitbox.disable()
			hitbox_active = false

	# Attack finished - check for buffered inputs
	if attack_timer >= ATTACK_DURATION:
		_handle_buffered_inputs()

# =============================================================================
# PRIVATE METHODS
# =============================================================================

func _handle_buffered_inputs() -> void:
	# Check for buffered actions and transition to appropriate state
	var buffered_action = player.consume_buffered_action()

	if buffered_action == "dodge":
		state_machine.transition_to("Dodge")
	elif buffered_action == "attack":
		# Chain to another attack (restart attack state)
		state_machine.transition_to("Attack")
	elif buffered_action == "special_attack" and player.is_ability_unlocked("special_attack"):
		state_machine.transition_to("SpecialAttack")
	else:
		# No buffered action, return to idle
		state_machine.transition_to("Idle")

func _position_hitbox() -> void:
	if not player.hitbox:
		return

	# Get the collision shape to reposition
	var hitbox_shape: CollisionShape2D = player.hitbox.get_node_or_null("CollisionShape2D")
	if not hitbox_shape:
		return

	# Position based on facing direction
	match player.facing_direction:
		"down":
			hitbox_shape.position = Vector2(0, 10)
			hitbox_shape.rotation = 0
		"up":
			hitbox_shape.position = Vector2(0, -10)
			hitbox_shape.rotation = 0
		"side":
			if player.facing_left:
				hitbox_shape.position = Vector2(-10, 0)
			else:
				hitbox_shape.position = Vector2(10, 0)
			hitbox_shape.rotation = 0
