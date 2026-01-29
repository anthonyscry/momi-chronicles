extends State
class_name PlayerChargeAttack
## Charge attack - hold attack button to charge, release for powerful hit.
## Damage scales from 1.5x (min charge) to 2.5x (full charge).

# =============================================================================
# CONFIGURATION
# =============================================================================

## Time to reach minimum charge (can release for weak charged attack)
const MIN_CHARGE_TIME: float = 0.4

## Time to reach full charge
const MAX_CHARGE_TIME: float = 1.2

## Damage multiplier at minimum charge
const MIN_DAMAGE_MULT: float = 1.5

## Damage multiplier at full charge
const MAX_DAMAGE_MULT: float = 2.5

## Attack duration when releasing
const RELEASE_DURATION: float = 0.4

## Hitbox active window
const HITBOX_START: float = 0.05
const HITBOX_END: float = 0.3

## Base damage (will be modified by level)
const BASE_DAMAGE: int = 25

# =============================================================================
# STATE
# =============================================================================

var charge_time: float = 0.0
var is_charging: bool = true
var release_timer: float = 0.0
var hitbox_active: bool = false
var calculated_damage: int = 0

# =============================================================================
# LIFECYCLE
# =============================================================================

func enter() -> void:
	player.velocity = Vector2.ZERO
	charge_time = 0.0
	is_charging = true
	release_timer = 0.0
	hitbox_active = false
	bot_target_charge_time = 0.0  # Reset for bot
	
	# Start charge visual
	_start_charge_visual()
	
	Events.player_charge_started.emit()

func exit() -> void:
	if player.hitbox:
		player.hitbox.disable()
	hitbox_active = false
	
	# Reset sprite
	if player.sprite:
		player.sprite.modulate = Color.WHITE
		player.sprite.scale = Vector2.ONE

func physics_update(delta: float) -> void:
	if is_charging:
		_update_charging(delta)
	else:
		_update_release(delta)

# =============================================================================
# CHARGING PHASE
# =============================================================================

## Bot's target charge time (set randomly on enter)
var bot_target_charge_time: float = 0.0

func _update_charging(delta: float) -> void:
	charge_time += delta
	
	# Check if attack button released
	var attack_held = Input.is_action_pressed("attack")
	if not attack_held and InputMap.has_action("attack_alt"):
		attack_held = Input.is_action_pressed("attack_alt")
	
	# Bot control - releases after reaching target charge time
	if player.bot_controlled:
		if bot_target_charge_time == 0.0:
			# Set target time once
			bot_target_charge_time = randf_range(0.5, MAX_CHARGE_TIME)
		attack_held = charge_time < bot_target_charge_time
	
	if not attack_held:
		_release_attack()
		return
	
	# Update charge visuals
	var charge_percent = clampf(charge_time / MAX_CHARGE_TIME, 0, 1)
	_update_charge_visual(charge_percent)
	
	# Slight movement slowdown while charging
	var input_dir = player.get_input_direction()
	player.velocity = input_dir * 20  # Very slow movement while charging

func _release_attack() -> void:
	is_charging = false
	release_timer = 0.0
	
	# Calculate damage based on charge level (uses effective base with equipment + buffs)
	var charge_percent = clampf(charge_time / MAX_CHARGE_TIME, 0, 1)
	var effective_base = player.get_effective_base_damage()
	
	if charge_time < MIN_CHARGE_TIME:
		# Not enough charge - do weak attack
		calculated_damage = int(effective_base * 0.75)
	else:
		# Interpolate between min and max multiplier
		var charge_normalized = (charge_time - MIN_CHARGE_TIME) / (MAX_CHARGE_TIME - MIN_CHARGE_TIME)
		charge_normalized = clampf(charge_normalized, 0, 1)
		var multiplier = lerpf(MIN_DAMAGE_MULT, MAX_DAMAGE_MULT, charge_normalized)
		calculated_damage = int(effective_base * multiplier)
	
	# Set hitbox damage
	if player.hitbox:
		player.hitbox.damage = calculated_damage
		player.hitbox.reset()
	
	# Position hitbox
	_position_hitbox()
	
	# Release visual burst
	_release_burst(charge_percent)
	
	Events.player_charge_released.emit(calculated_damage, charge_percent)

# =============================================================================
# RELEASE PHASE
# =============================================================================

func _update_release(delta: float) -> void:
	release_timer += delta
	var progress = release_timer / RELEASE_DURATION
	
	# Hitbox timing
	if progress >= HITBOX_START and progress < HITBOX_END:
		if not hitbox_active and player.hitbox:
			player.hitbox.enable()
			hitbox_active = true
	elif progress >= HITBOX_END:
		if hitbox_active and player.hitbox:
			player.hitbox.disable()
			hitbox_active = false
	
	# Lunge forward slightly
	if progress < 0.2:
		var lunge_dir = _get_facing_vector()
		player.velocity = lunge_dir * 150
	else:
		player.velocity = player.velocity.lerp(Vector2.ZERO, delta * 10)
	
	player.move_and_slide()
	
	# Attack finished
	if release_timer >= RELEASE_DURATION:
		state_machine.transition_to("Idle")

# =============================================================================
# VISUALS
# =============================================================================

func _start_charge_visual() -> void:
	if player.sprite:
		player.sprite.modulate = Color(1.0, 0.95, 0.8)

func _update_charge_visual(percent: float) -> void:
	if not player.sprite:
		return
	
	# Glow intensifies with charge
	var glow = lerpf(0.8, 1.4, percent)
	player.sprite.modulate = Color(glow, glow * 0.9, 0.7 + percent * 0.3)
	
	# Slight scale pulse
	var pulse = 1.0 + sin(charge_time * 10) * 0.05 * percent
	player.sprite.scale = Vector2(pulse, pulse)
	
	# Screen shake at full charge
	if percent >= 1.0:
		if fmod(charge_time, 0.1) < 0.02:
			EffectsManager.screen_shake(2.0, 0.05)

func _release_burst(charge_percent: float) -> void:
	# Screen shake based on charge
	var shake_intensity = lerpf(3.0, 12.0, charge_percent)
	EffectsManager.screen_shake(shake_intensity, 0.2)
	
	# Flash sprite
	if player.sprite:
		player.sprite.modulate = Color(1.5, 1.3, 1.0)
		player.sprite.scale = Vector2(1.2, 1.2)

# =============================================================================
# HELPERS
# =============================================================================

func _position_hitbox() -> void:
	if not player.hitbox:
		return
	
	var hitbox_shape = player.hitbox.get_node_or_null("CollisionShape2D")
	if not hitbox_shape:
		return
	
	# Larger hitbox for charged attack
	hitbox_shape.scale = Vector2(1.5, 1.5)
	
	match player.facing_direction:
		"down":
			hitbox_shape.position = Vector2(0, 12)
		"up":
			hitbox_shape.position = Vector2(0, -12)
		"side":
			hitbox_shape.position = Vector2(-15 if player.facing_left else 15, 0)

func _get_facing_vector() -> Vector2:
	match player.facing_direction:
		"down":
			return Vector2.DOWN
		"up":
			return Vector2.UP
		"side":
			return Vector2.LEFT if player.facing_left else Vector2.RIGHT
	return Vector2.DOWN
