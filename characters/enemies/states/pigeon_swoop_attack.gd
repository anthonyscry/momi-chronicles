extends State
class_name PigeonSwoopAttack

## Pigeon aerial swoop attack - dives toward player, damages, then returns to perch.

const DamageUtils = preload("res://components/combat/damage_utils.gd")

# ==============================================================================
# ATTACK SETTINGS
# ==============================================================================

const SWOOP_HEIGHT: float = 120.0
const SWOOP_DURATION: float = 0.6
const RETURN_SPEED: float = 100.0
const HITBOX_DURATION: float = 0.2
const SWOOP_HORIZONTAL_DISTANCE: float = 150.0

# ==============================================================================
# STATE
# ==============================================================================

enum { PHASE_DIVE, PHASE_DAMAGE, PHASE_RETURN }

var swoop_start: Vector2 = Vector2.ZERO
var swoop_target: Vector2 = Vector2.ZERO
var swoop_direction: Vector2 = Vector2.ZERO
var swoop_progress: float = 0.0
var attack_phase: int = PHASE_DIVE
var has_hit_player: bool = false

# ==============================================================================
# LIFECYCLE
# ==============================================================================

func enter() -> void:
	var player_node = player.get_attack_target()
	if player_node:
		swoop_start = player.global_position
		swoop_target = player_node.global_position + Vector2(0, 16)
		swoop_direction = (swoop_target - swoop_start).normalized()
	
	if player.sprite:
		player.sprite.play("swoop")
	
	# Disable hitbox initially
	_disable_hitbox()
	
	attack_phase = PHASE_DIVE
	has_hit_player = false
	swoop_progress = 0.0

func exit() -> void:
	_disable_hitbox()
	
	# Reset position to perch
	player.global_position = player.perch_position
	
	if player.sprite:
		player.sprite.rotation = 0.0

func physics_update(delta: float) -> void:
	match attack_phase:
		PHASE_DIVE:
			_update_dive_phase(delta)
		PHASE_DAMAGE:
			_update_damage_phase(delta)
		PHASE_RETURN:
			_update_return_phase(delta)

# ==============================================================================
# DIVE PHASE
# ==============================================================================

func _update_dive_phase(delta: float) -> void:
	swoop_progress += delta / SWOOP_DURATION
	
	if swoop_progress >= 1.0:
		attack_phase = PHASE_DAMAGE
		swoop_progress = 0.0
		return
	
	# Ease in quad for accelerating dive
	var progress = _ease_in_quad(swoop_progress)
	
	# Calculate position - dive down and forward
	var vertical_drop = progress * SWOOP_HEIGHT
	var horizontal = progress * SWOOP_HORIZONTAL_DISTANCE
	
	player.global_position = swoop_start + swoop_direction * horizontal + Vector2(0, vertical_drop)
	
	# Rotate sprite to face downward
	if player.sprite:
		player.sprite.rotation = lerp(0.0, PI * 0.25, progress)

# ==============================================================================
# DAMAGE PHASE
# ==============================================================================

func _update_damage_phase(delta: float) -> void:
	swoop_progress += delta / HITBOX_DURATION
	
	if swoop_progress >= 1.0:
		attack_phase = PHASE_RETURN
		swoop_progress = 0.0
		_disable_hitbox()
		return
	
	# Enable hitbox during damage window
	if not has_hit_player:
		_enable_hitbox()
		_check_hit_player()

func _check_hit_player() -> void:
	if not player.hitbox:
		return
	
	var overlapping = player.hitbox.get_overlapping_areas()
	for area in overlapping:
		var body = area.get_parent()
		if body and body.is_in_group("player"):
			if DamageUtils.apply_hitbox_damage(body, player.hitbox):
				Events.pigeon_hit_player.emit(player.flock_id)
				has_hit_player = true
			break

# ==============================================================================
# RETURN PHASE
# ==============================================================================

func _update_return_phase(delta: float) -> void:
	var perch = player.perch_position
	var to_perch = perch - player.global_position
	var distance = to_perch.length()
	
	# Move toward perch
	if distance > 0:
		var direction = to_perch.normalized()
		player.global_position += direction * min(RETURN_SPEED * delta, distance)
	
	# Reset rotation
	if player.sprite:
		player.sprite.rotation = lerp(player.sprite.rotation, 0.0, delta * 5)
	
	# Return complete
	if distance < 8:
		state_machine.transition_to("FlockIdle")

# ==============================================================================
# HITBOX CONTROL
# ==============================================================================

func _enable_hitbox() -> void:
	if player.hitbox:
		player.hitbox.reset()
		player.hitbox.enable()

func _disable_hitbox() -> void:
	if player.hitbox:
		player.hitbox.disable()

# ==============================================================================
# UTILITIES
# ==============================================================================

func _ease_in_quad(t: float) -> float:
	return t * t
