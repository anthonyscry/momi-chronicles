extends State
class_name PigeonFlockIdle

## Pigeon idle state - hovers on perch in formation, lead monitors for player.

# ==============================================================================
# FORMATION SETTINGS
# ==============================================================================

const HOVER_DURATION: float = 1.5
const FORMATION_SPACING: float = 32.0
const HOVER_AMPLITUDE: float = 2.0
const HOVER_SPEED: float = 0.005

# ==============================================================================
# STATE
# ==============================================================================

var hover_time: float = 0.0
var formation_offset: Vector2 = Vector2.ZERO
var flock_members: Array = []

# ==============================================================================
# LIFECYCLE
# ==============================================================================

func enter() -> void:
	player.is_fleeing = false
	player.velocity = Vector2.ZERO
	
	if player.sprite:
		player.sprite.play("idle")
	
	# Setup formation
	_setup_formation_offset()
	
	# Lead pigeon announces idle state
	if player.is_lead_pigeon:
		Events.pigeon_entered_idle.emit(player.flock_id)

func exit() -> void:
	hover_time = 0.0

func physics_update(delta: float) -> void:
	# Check flee condition
	if player.is_fleeing:
		state_machine.transition_to("FlockChase")
		return
	
	# Hover animation
	hover_time += delta
	if player.sprite:
		var hover_offset = sin(Time.get_ticks_msec() * HOVER_SPEED) * HOVER_AMPLITUDE
		player.sprite.position.y = -8 + hover_offset
	
	# Periodic player check (lead pigeon)
	if player.is_lead_pigeon:
		_check_for_player()

# ==============================================================================
# FORMATION
# ==============================================================================

func _setup_formation_offset() -> void:
	if player.is_lead_pigeon:
		formation_offset = Vector2.ZERO
		player.perch_position = player.global_position
	else:
		var lead = _get_flock_lead()
		if lead and is_instance_valid(lead):
			var angle = player.flock_position * TAU / _get_flock_size()
			formation_offset = Vector2(cos(angle), sin(angle)) * FORMATION_SPACING
			player.perch_position = lead.perch_position + formation_offset
		else:
			# Fallback if lead not found
			formation_offset = Vector2(randf_range(-24, 24), randf_range(-16, 16))
			player.perch_position = player.global_position

func _get_flock_lead() -> Node:
	var flock = player.get_flock_members()
	for member in flock:
		if member.is_lead_pigeon:
			return member
	return null

func _get_flock_size() -> int:
	var flock = player.get_flock_members()
	return max(flock.size(), 1)

# ==============================================================================
# PLAYER DETECTION
# ==============================================================================

func _check_for_player() -> void:
	var player_node = player.get_attack_target()
	if not player_node:
		return
	
	var distance = player.global_position.distance_to(player_node.global_position)
	
	if distance < player.DETECTION_RANGE:
		# Lead pigeon detected player - trigger coordinated chase
		Events.pigeon_detected_player.emit(player.flock_id, player_node.global_position)
		state_machine.transition_to("FlockChase")
