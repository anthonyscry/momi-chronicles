extends State
class_name PigeonFlockChase

## Pigeon chase state - pursues player in formation, coordinates swoop attacks.

# ==============================================================================
# MOVEMENT SETTINGS
# ==============================================================================

const FORMATION_SPACING: float = 40.0
const SWOOP_TRIGGER_DISTANCE: float = 200.0
const VERTICAL_ADJUST_SPEED: float = 60.0
const MIN_ATTACK_HEIGHT: float = 120.0

# ==============================================================================
# STATE
# ==============================================================================

var target_position: Vector2 = Vector2.ZERO
var swoop_scheduled: bool = false
var swoop_time: float = 0.0
var hover_offset: float = 0.0

# ==============================================================================
# LIFECYCLE
# ==============================================================================

func enter() -> void:
	if player.sprite:
		player.sprite.play("fly")
	
	target_position = player.global_position
	
	# Announce chase start
	if player.is_lead_pigeon:
		Events.pigeon_chase_started.emit(player.flock_id, player.global_position)
	else:
		_sync_swoop_timing()

func exit() -> void:
	swoop_scheduled = false
	swoop_time = 0.0

func physics_update(delta: float) -> void:
	var player_node = player.get_attack_target()
	
	# Lost target - return to idle
	if not player_node:
		state_machine.transition_to("FlockIdle")
		return
	
	var to_target = player_node.global_position - player.global_position
	var distance = to_target.length()
	
	# Fleeing behavior
	if player.is_fleeing:
		_flee_from_threat(delta)
		return
	
	# Check for swoop attack
	if distance < player.ATTACK_RANGE and not swoop_scheduled:
		if player.is_lead_pigeon:
			_schedule_swoop(0.0)
		else:
			var delay = player.flock_position * player.SWOOP_DELAY_BETWEEN_PIGEONS
			_schedule_swoop(delay)
	
	# Handle scheduled swoop
	if swoop_scheduled:
		swoop_time -= delta
		if swoop_time <= 0:
			state_machine.transition_to("SwoopAttack")
			return
	
	# Update movement
	_update_movement(to_target, distance, delta)
	_update_facing(to_target.x)

# ==============================================================================
# MOVEMENT
# ==============================================================================

func _update_movement(to_target: Vector2, distance: float, delta: float) -> void:
	# Maintain aerial height
	var height_adjust = Vector2.ZERO
	if player.global_position.y < MIN_ATTACK_HEIGHT:
		height_adjust.y = VERTICAL_ADJUST_SPEED * delta
	
	if distance > SWOOP_TRIGGER_DISTANCE:
		var direction = to_target.normalized()
		
		# Formation position relative to lead
		var formation_pos = _get_formation_position()
		
		# Target position - circle around player
		var target_pos = direction * (distance - SWOOP_TRIGGER_DISTANCE * 0.5)
		target_pos += formation_pos * 0.3
		
		# Steering toward target
		var steering = (target_pos - player.velocity) * 2.0
		player.velocity = (player.velocity + steering * delta).limit_length(player.FLY_SPEED)
		player.velocity += height_adjust
	else:
		# Circling behavior when close
		var circle_dir = Vector2(-to_target.y, to_target.x).normalized()
		player.velocity = circle_dir * player.FLY_SPEED * 0.5 + height_adjust
	
	player.move_and_slide()

func _get_formation_position() -> Vector2:
	var lead = player.get_flock_lead()
	if lead and is_instance_valid(lead):
		var angle = player.flock_position * TAU / 6
		return Vector2(cos(angle), sin(angle)) * FORMATION_SPACING
	return Vector2.ZERO

# ==============================================================================
# FLEE BEHAVIOR
# ==============================================================================

func _flee_from_threat(delta: float) -> void:
	# Fly upward and away
	var flee_direction = Vector2(0, -1)
	player.velocity = flee_direction * player.FLEE_SPEED
	player.move_and_slide()
	
	# Return to idle when at sufficient height
	if player.global_position.y < player.PERCH_HEIGHT - 50:
		state_machine.transition_to("FlockIdle")

# ==============================================================================
# SWOOP COORDINATION
# ==============================================================================

func _sync_swoop_timing() -> void:
	var lead = player.get_flock_lead()
	if lead and is_instance_valid(lead):
		var delay = player.flock_position * player.SWOOP_DELAY_BETWEEN_PIGEONS
		swoop_time = delay
		swoop_scheduled = true

func _schedule_swoop(delay: float) -> void:
	swoop_scheduled = true
	swoop_time = delay

# ==============================================================================
# FACING
# ==============================================================================

func _update_facing(horizontal: float) -> void:
	if player.sprite:
		if horizontal < -1:
			player.sprite.flip_h = true
		elif horizontal > 1:
			player.sprite.flip_h = false
