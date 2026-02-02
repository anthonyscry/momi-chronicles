extends State
class_name PlayerSpecialAttack
## Special Attack state - Momi's powerful spin attack that hits all nearby enemies.
## Deals more damage but has a longer wind-up and cooldown.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Wind-up time before attack
const WINDUP_DURATION: float = 0.25

## Active spin attack duration
const SPIN_DURATION: float = 0.4

## Recovery time after attack
const RECOVERY_DURATION: float = 0.2

## Total duration
const TOTAL_DURATION: float = WINDUP_DURATION + SPIN_DURATION + RECOVERY_DURATION

## Damage multiplier for special attack
const DAMAGE_MULTIPLIER: float = 2.0

## Spin attack radius (hitbox scale)
const SPIN_RADIUS: float = 1.5

# =============================================================================
# STATE
# =============================================================================

var attack_timer: float = 0.0
var hitbox_active: bool = false
var original_damage: int = 0
var spin_rotation: float = 0.0

# =============================================================================
# LIFECYCLE
# =============================================================================

func enter() -> void:
	# Stop movement during wind-up
	player.velocity = Vector2.ZERO
	
	# Reset timers
	attack_timer = 0.0
	hitbox_active = false
	spin_rotation = 0.0
	
	# Store and boost damage
	if player.hitbox:
		original_damage = player.hitbox.damage
		player.hitbox.damage = int(original_damage * DAMAGE_MULTIPLIER)
		player.hitbox.reset()
	
	# Scale up hitbox for spin attack (hits in all directions)
	_setup_spin_hitbox()
	
	# Play special attack animation and visual feedback
	if player.sprite:
		player.sprite.play("special_attack")
		player.sprite.modulate = Color(1.2, 1.0, 0.8, 1.0)  # Slight glow
	
	# Emit special attack event
	Events.player_special_attacked.emit()


func exit() -> void:
	# Ensure hitbox is disabled
	if player.hitbox:
		player.hitbox.disable()
		player.hitbox.damage = original_damage
	hitbox_active = false
	
	# Reset hitbox position
	_reset_hitbox()
	
	# Reset visual
	if player.sprite:
		player.sprite.modulate = Color.WHITE
		player.sprite.rotation = 0


func physics_update(delta: float) -> void:
	attack_timer += delta
	
	# Phase 1: Wind-up (charging)
	if attack_timer < WINDUP_DURATION:
		# Slight backwards movement during charge
		var charge_progress = attack_timer / WINDUP_DURATION
		if player.sprite:
			player.sprite.scale = Vector2(1.0 - charge_progress * 0.1, 1.0 + charge_progress * 0.1)
		return
	
	# Phase 2: Spin attack (active frames)
	var spin_start = WINDUP_DURATION
	var spin_end = WINDUP_DURATION + SPIN_DURATION
	
	if attack_timer >= spin_start and attack_timer < spin_end:
		# Enable hitbox
		if not hitbox_active and player.hitbox:
			player.hitbox.enable()
			hitbox_active = true
		
		# Spin visual
		var spin_progress = (attack_timer - spin_start) / SPIN_DURATION
		spin_rotation = spin_progress * TAU * 2  # Two full rotations
		if player.sprite:
			player.sprite.rotation = spin_rotation
			player.sprite.scale = Vector2(1.1, 1.1)  # Slightly larger during spin
			player.sprite.modulate = Color(1.3, 1.1, 0.9, 1.0)  # Brighter glow
		
		# Move hitbox around player in a circle
		_update_spin_hitbox(spin_progress)
		return
	
	# Phase 3: Recovery
	if attack_timer >= spin_end:
		# Disable hitbox
		if hitbox_active and player.hitbox:
			player.hitbox.disable()
			hitbox_active = false
		
		# Slow down rotation
		if player.sprite:
			player.sprite.rotation = lerp_angle(player.sprite.rotation, 0.0, delta * 10)
			player.sprite.scale = Vector2(1.0, 1.0)
			player.sprite.modulate = Color.WHITE
	
	# Attack finished
	if attack_timer >= TOTAL_DURATION:
		state_machine.transition_to("Idle")


# =============================================================================
# PRIVATE METHODS
# =============================================================================

func _setup_spin_hitbox() -> void:
	if not player.hitbox:
		return
	
	var hitbox_shape: CollisionShape2D = player.hitbox.get_node_or_null("CollisionShape2D")
	if not hitbox_shape:
		return
	
	# Make hitbox larger for spin attack
	hitbox_shape.scale = Vector2(SPIN_RADIUS, SPIN_RADIUS)


func _update_spin_hitbox(progress: float) -> void:
	if not player.hitbox:
		return
	
	var hitbox_shape: CollisionShape2D = player.hitbox.get_node_or_null("CollisionShape2D")
	if not hitbox_shape:
		return
	
	# Move hitbox in a circle around player
	var angle = progress * TAU * 2
	var radius = 12.0
	hitbox_shape.position = Vector2(cos(angle) * radius, sin(angle) * radius)


func _reset_hitbox() -> void:
	if not player.hitbox:
		return
	
	var hitbox_shape: CollisionShape2D = player.hitbox.get_node_or_null("CollisionShape2D")
	if not hitbox_shape:
		return
	
	# Reset scale and position
	hitbox_shape.scale = Vector2.ONE
	hitbox_shape.position = Vector2.ZERO
