extends Node
## Auto-Bot for automated testing. Controls the player directly.
## Toggle with F1 key. Enabled by default for testing.
## 
## Uses _physics_process to sync with player state machine timing.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Whether auto-bot is active
var enabled: bool = true

## How often to make strategic decisions (seconds)
const DECISION_INTERVAL: float = 0.2

## How long to move in one direction before changing (when wandering)
const DIRECTION_CHANGE_TIME: float = 1.5

## Distance to detect enemies (increased for larger zones)
const ENEMY_DETECTION_RANGE: float = 600.0

## Distance to attack enemies  
const ATTACK_RANGE: float = 30.0

## Chance to use special attack (0-1) - OLD SPIN ATTACK
const SPECIAL_ATTACK_CHANCE: float = 0.15

## Chance to use ground pound when available and surrounded
const GROUND_POUND_CHANCE: float = 0.6

## Chance to use charge attack instead of combo
const CHARGE_ATTACK_CHANCE: float = 0.25

## Chance to complete full combo (vs stopping early)
const FULL_COMBO_CHANCE: float = 0.7

## Chance to dodge when enemy is close
const DODGE_CHANCE: float = 0.15

## Chance to run when chasing or fleeing
const RUN_CHANCE: float = 0.7

## Block/Parry settings
const BLOCK_CHANCE: float = 0.25          # Chance to block instead of dodge
const PARRY_ATTEMPT_CHANCE: float = 0.4   # Chance to try parry timing vs normal block
const BLOCK_DURATION_MIN: float = 0.2     # Minimum block hold time
const BLOCK_DURATION_MAX: float = 1.5     # Maximum block hold time
const PARRY_WINDOW: float = 0.15          # Parry window (must match PlayerBlock)

## Phase 16: Ring Menu / Items / Companions settings
const USE_ITEM_HEALTH_THRESHOLD: float = 0.5  # Use healing item below this HP%
const COMPANION_CYCLE_INTERVAL: float = 15.0  # Cycle companions every N seconds
const RING_MENU_TEST_INTERVAL: float = 30.0   # Test ring menu every N seconds
const RING_MENU_BROWSE_TIME: float = 2.0      # How long to browse ring menu

## Zone boundaries to stay within
const ZONE_PADDING: float = 40.0

## Default zone size fallback (used if BaseZone detection fails)
const DEFAULT_ZONE_SIZE: Vector2 = Vector2(800, 600)

## Human-like behavior settings
const REACTION_TIME_MIN: float = 0.05  # Minimum reaction delay
const REACTION_TIME_MAX: float = 0.2   # Maximum reaction delay
const AIM_VARIANCE: float = 0.15       # How much to vary aim direction
const HESITATION_CHANCE: float = 0.08  # Chance to hesitate before acting
const MOVEMENT_CURVE: float = 0.3      # How much to curve movement paths

## Defensive behavior settings
const LOW_HEALTH_THRESHOLD: float = 0.4   # Below this, play defensively
const CRITICAL_HEALTH_THRESHOLD: float = 0.2  # Below this, retreat
const DEFENSIVE_DODGE_CHANCE: float = 0.4  # Dodge chance when low health
const RETREAT_DISTANCE: float = 150.0      # How far to retreat

## Smart healing thresholds
const LIGHT_DAMAGE_THRESHOLD: float = 0.9   # Above 70% HP = light damage (use acorn/seed)
const MODERATE_DAMAGE_THRESHOLD: float = 0.5 # 40-70% HP = moderate (use health_potion)
const HEAVY_DAMAGE_THRESHOLD: float = 0.4    # Below 40% HP = heavy (use mega_potion/full_heal)

## Guard snack usage
const GUARD_SNACK_THRESHOLD: float = 0.2  # Use guard snack below 20% guard

## Buff treat settings
const BUFF_ENEMY_THRESHOLD: int = 3       # Use buffs when 3+ enemies nearby
const BUFF_COOLDOWN: float = 35.0          # Don't re-buff within 35s (buff lasts 30s + 5s grace)

## Companion revival
const REVIVAL_CHECK_INTERVAL: float = 5.0  # Check for knocked-out companions every 5s

## Equipment optimization
const EQUIP_CHECK_INTERVAL: float = 30.0  # Check equipment every 30s

## Hazard avoidance settings
const HAZARD_DETECTION_RANGE: float = 120.0   # How far to detect hazards
const HAZARD_AVOIDANCE_STRENGTH: float = 0.8  # How strongly to steer away (0-1)
const HAZARD_AVOID_RADIUS: float = 50.0       # Extra padding around hazards

## Kiting and crowd control settings
const KITE_AFTER_ATTACK: bool = true      # Back off after attacking
const KITE_DISTANCE: float = 60.0          # Distance to back off
const KITE_DURATION: float = 0.4           # How long to back off
const CROWD_DANGER_COUNT: int = 2          # Enemies nearby = danger
const CROWD_DANGER_RANGE: float = 80.0     # Range to count as "nearby"
const SURROUND_CHECK_ANGLE: float = PI/3   # 60 degree sectors

# =============================================================================
# STATE
# =============================================================================

var decision_timer: float = 0.0
var direction_timer: float = 0.0
var current_direction: Vector2 = Vector2.ZERO
var target_enemy: Node = null
var attack_cooldown: float = 0.0
var dodge_cooldown: float = 0.0
var player_ref = null  # Player - no type annotation to avoid cyclic dependency
var _f1_held: bool = false
var _initialized: bool = false

# Movement smoothing
var desired_direction: Vector2 = Vector2.ZERO
var movement_lerp_speed: float = 8.0

# Obstacle avoidance
var stuck_timer: float = 0.0
var last_position: Vector2 = Vector2.ZERO
var stuck_threshold: float = 5.0  # Pixels moved threshold
var obstacle_avoidance_dir: Vector2 = Vector2.ZERO
var avoiding_obstacle: bool = false

# Human-like behavior
var reaction_delay: float = 0.0        # Current reaction delay timer
var hesitating: bool = false           # Currently hesitating
var hesitation_timer: float = 0.0      # Time left hesitating
var movement_noise: float = 0.0        # Current movement noise angle

# Health tracking
var player_health_percent: float = 1.0
var is_low_health: bool = false
var is_critical_health: bool = false

# Kiting state
var is_kiting: bool = false
var kite_timer: float = 0.0
var kite_direction: Vector2 = Vector2.ZERO

# Combo/Charge attack state
var combo_hits_remaining: int = 0        # How many more combo hits to do
var combo_timer: float = 0.0             # Timing window for next combo hit
var is_charging: bool = false            # Currently doing charge attack
var charge_timer: float = 0.0            # How long we've been charging
var charge_target_time: float = 0.0      # When to release charge
var ground_pound_cooldown: float = 0.0   # Track ground pound cooldown locally

# Crowd awareness
var nearby_enemy_count: int = 0
var safest_direction: Vector2 = Vector2.ZERO
var is_surrounded: bool = false

# Block/Parry state
var is_blocking: bool = false
var block_timer: float = 0.0
var block_target_duration: float = 0.0
var attempting_parry: bool = false
var parry_cooldown: float = 0.0

# Phase 16: Ring Menu / Items / Companions state
var companion_cycle_timer: float = 5.0    # Start cycling after 5 seconds
var ring_menu_test_timer: float = 10.0    # First ring menu test after 10 seconds
var ring_menu_browse_timer: float = 0.0   # Time spent browsing ring menu
var in_ring_menu: bool = false            # Currently in ring menu
var last_item_use_time: float = 0.0       # When we last used an item

# Zone awareness
var current_zone_size: Vector2 = Vector2(800, 600)
var current_zone_ref: Node = null  # Cached BaseZone reference
var _zone_size_detected: bool = false

# Hazard awareness
var nearby_hazards: Array[Node] = []
var hazard_avoidance_vector: Vector2 = Vector2.ZERO
var is_in_dark_zone: bool = false

# Smart item management state
var last_guard_snack_time: float = 0.0  # Prevent guard snack spam
var last_buff_use_time: float = 0.0      # Prevent buff spam
var revival_check_timer: float = 3.0     # First check after 3 seconds
var equip_check_timer: float = 10.0      # First equipment check after 10 seconds

# Debug info
var debug_state: String = "INIT"
var enemies_found: int = 0
var nearest_enemy_dist: float = 0.0
var debug_frame_counter: int = 0
const DEBUG_LOG_INTERVAL: int = 300  # Log every 5 seconds at 60fps

# Auto-start flag to prevent spam clicking
var auto_start_attempted: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Defer initialization to ensure scene is ready
	call_deferred("_deferred_init")


func _deferred_init() -> void:
	print("[AutoBot] Initialized - Press F1 to toggle (currently: %s)" % ("ON" if enabled else "OFF"))
	_initialized = true


func _physics_process(delta: float) -> void:
	if not _initialized:
		return
	
	# Toggle with F1
	_handle_toggle_input()
	
	# Auto-start: If on title screen and no player, click appropriate button (once)
	if enabled and player_ref == null and not auto_start_attempted:
		# First check for confirmation dialog (overwrite save prompt)
		var confirm_dialog = get_tree().root.find_child("ConfirmationDialog", true, false)
		if confirm_dialog and confirm_dialog is ConfirmationDialog and confirm_dialog.visible:
			auto_start_attempted = true
			print("[AutoBot] Confirming new game!")
			confirm_dialog.confirmed.emit()
		else:
			# Prefer Continue if it exists (has save), otherwise Start
			var continue_btn = get_tree().root.find_child("ContinueButton", true, false)
			if continue_btn and continue_btn is Button and continue_btn.visible:
				auto_start_attempted = true
				print("[AutoBot] Continuing saved game!")
				continue_btn.pressed.emit()
			else:
				var start_btn = get_tree().root.find_child("StartButton", true, false)
				if start_btn and start_btn is Button and start_btn.visible:
					auto_start_attempted = true
					print("[AutoBot] Starting new game!")
					start_btn.pressed.emit()
	
	# Get player reference
	_ensure_player_reference()
	
	if not enabled or player_ref == null:
		return


# Make sure bot_controlled is set
	if not player_ref.bot_controlled:
		player_ref.bot_controlled = true
	
	# Update health status
	_update_health_status()
	
	# Update zone awareness
	_update_zone_awareness()
	
	# Update crowd awareness
	_update_crowd_awareness()
	
	# Update hazard awareness
	_update_hazard_awareness()
	
	# Update kiting
	if is_kiting:
		kite_timer -= delta
		if kite_timer <= 0:
			is_kiting = false
	
	# Update cooldowns and timers
	attack_cooldown = max(0, attack_cooldown - delta)
	dodge_cooldown = max(0, dodge_cooldown - delta)
	reaction_delay = max(0, reaction_delay - delta)
	hesitation_timer = max(0, hesitation_timer - delta)
	ground_pound_cooldown = max(0, ground_pound_cooldown - delta)
	parry_cooldown = max(0, parry_cooldown - delta)
	decision_timer -= delta
	direction_timer -= delta
	
	# Update blocking state
	_update_blocking(delta)
	
	# Update Phase 16 systems (ring menu, companions, items)
	_update_phase16_systems(delta)
	
	# Update combo timing (chain attacks within window)
	_update_combo_timing(delta)
	
	# Update charge attack (release when ready)
	_update_charge_attack(delta)
	
	# Clear hesitation when timer expires
	if hesitation_timer <= 0:
		hesitating = false
	
	# Make decisions periodically (with reaction delay for human-like behavior)
	if decision_timer <= 0 and reaction_delay <= 0:
		decision_timer = DECISION_INTERVAL
		# Add slight random reaction time
		reaction_delay = randf_range(REACTION_TIME_MIN, REACTION_TIME_MAX)
		_make_decision()
	
	# Periodic debug output
	debug_frame_counter += 1
	if debug_frame_counter >= DEBUG_LOG_INTERVAL:
		debug_frame_counter = 0
		_log_debug_status()
	
	# Smooth movement towards desired direction
	current_direction = current_direction.lerp(desired_direction, movement_lerp_speed * delta)
	
	# Apply movement every physics frame
	_apply_movement()


func _handle_toggle_input() -> void:
	if Input.is_key_pressed(KEY_F1) and not _f1_held:
		_f1_held = true
		enabled = not enabled
		print("[AutoBot] %s" % ("ENABLED" if enabled else "DISABLED"))
		_update_player_control()
	elif not Input.is_key_pressed(KEY_F1):
		_f1_held = false


func _ensure_player_reference() -> void:
	if player_ref == null or not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
		if player_ref != null:
			print("[AutoBot] Found player")
			auto_start_attempted = false  # Reset for next title screen visit
			_zone_size_detected = false  # Re-detect zone on new player
			_update_player_control()


func _update_player_control() -> void:
	if player_ref != null:
		player_ref.bot_controlled = enabled
		if not enabled:
			# Clear bot inputs when disabled
			player_ref.bot_input_direction = Vector2.ZERO
			player_ref.bot_running = false
			player_ref.bot_pending_action = ""
			player_ref.bot_blocking = false
			current_direction = Vector2.ZERO
			desired_direction = Vector2.ZERO
			# Clear combat states
			combo_hits_remaining = 0
			is_charging = false
			is_blocking = false
			attempting_parry = false


# =============================================================================
# AI DECISION MAKING
# =============================================================================

func _make_decision() -> void:
	if player_ref == null:
		debug_state = "NO_PLAYER"
		return
	
	# Find nearest enemy (always check, even when wandering)
	var potential_enemy = _find_nearest_enemy()
	
	# Switch target if we found a better one or current is invalid
	if potential_enemy != null:
		target_enemy = potential_enemy
	elif target_enemy != null and not is_instance_valid(target_enemy):
		target_enemy = null
	
	if target_enemy != null and is_instance_valid(target_enemy):
		var distance = player_ref.global_position.distance_to(target_enemy.global_position)
		var direction_to_enemy = (target_enemy.global_position - player_ref.global_position).normalized()
		var direction_away = -direction_to_enemy  # For retreating
		
		# Human-like: add slight aim variance (imperfect tracking)
		var aim_noise = randf_range(-AIM_VARIANCE, AIM_VARIANCE)
		direction_to_enemy = direction_to_enemy.rotated(aim_noise)
		
		# KITING: Back off after attack
		if is_kiting:
			debug_state = "KITING"
			# Use safest direction if surrounded, otherwise back away from target
			desired_direction = safest_direction if is_surrounded else kite_direction
			player_ref.bot_running = true
			return
		
		# Count living enemies for "finish them" mode
		var living_count = _count_living_enemies()
		var finish_them_mode = living_count <= 5  # Be aggressive when half or fewer enemies left
		var last_stand_mode = living_count <= 2   # Ultra aggressive for final enemies
		
		# LAST STAND: When only 1-2 enemies left, go all-in regardless of health
		if last_stand_mode:
			debug_state = "LAST_STAND"
			# Sprint directly at enemy, attack relentlessly
			player_ref.bot_running = true
			
			if distance <= ATTACK_RANGE:
				if attack_cooldown <= 0:
					_do_attack()
				# Stay close and keep attacking
				desired_direction = direction_to_enemy * 0.3
			else:
				# Chase them down
				desired_direction = direction_to_enemy
			# Skip all defensive behavior - victory or death!
			return
		# CRITICAL HEALTH: Still fight but more carefully (unless in finish mode)
		elif is_critical_health and not finish_them_mode:
			# Only retreat if enemy is very close AND we're not in attack range
			# (If we're in attack range, better to fight than run)
			if distance < RETREAT_DISTANCE and distance > ATTACK_RANGE * 1.5:
				debug_state = "RETREATING"
				desired_direction = safest_direction if safest_direction.length() > 0.1 else direction_away
				player_ref.bot_running = true
				
				# Desperate dodge when retreating
				if dodge_cooldown <= 0 and randf() < DEFENSIVE_DODGE_CHANCE * 1.5:
					_do_dodge_toward_safety()
				return
			# If very close, commit to the fight - better to kill them than run
			elif distance <= ATTACK_RANGE * 1.5:
				debug_state = "DESPERATE_ATTACK"
				# Fall through to attack behavior below
		elif is_critical_health and finish_them_mode:
			debug_state = "FINISH_THEM"
			# In finish mode, ignore health and go aggressive
		
		# SURROUNDED: Prioritize escape if multiple enemies close
		if is_surrounded and nearby_enemy_count >= CROWD_DANGER_COUNT:
			debug_state = "ESCAPING"
			desired_direction = safest_direction
			player_ref.bot_running = true
			
			# Very likely to dodge when surrounded
			if dodge_cooldown <= 0 and randf() < 0.5:
				_do_dodge_toward_safety()
			return
		
		# Human-like: occasional hesitation before engaging
		if not hesitating and randf() < HESITATION_CHANCE:
			hesitating = true
			hesitation_timer = randf_range(0.1, 0.4)
			debug_state = "HESITATING"
			desired_direction = Vector2.ZERO
			return
		
		# Skip action if hesitating
		if hesitating:
			debug_state = "HESITATING"
			desired_direction = desired_direction * 0.3  # Slow down while hesitating
			return
		
		# Combat behavior
		if distance <= ATTACK_RANGE:
			debug_state = "ATTACKING"
			
			# Check for reactive blocking/parrying when enemy is attacking
			if _is_enemy_attacking() and not is_blocking:
				# High chance to try parry when enemy attacks!
				if parry_cooldown <= 0 and randf() < 0.6:
					_start_blocking(true)  # Parry attempt
					return
				elif dodge_cooldown <= 0 and randf() < 0.3:
					_do_defensive_action()
					return
			
			# In attack range - attack!
			if attack_cooldown <= 0 and not is_blocking:
				_do_attack()
				# Start kiting after attack (hit-and-run)
				if KITE_AFTER_ATTACK and (is_low_health or nearby_enemy_count > 1):
					_start_kite(direction_away)
				else:
					desired_direction = Vector2.ZERO  # Stop briefly to attack
			elif not is_blocking:
				# Circle around enemy while waiting for cooldown
				# Prefer direction away from other enemies
				var circle_dir = 1.0
				if safest_direction.length() > 0.1:
					# Circle toward the safer side
					var cross = direction_to_enemy.cross(safest_direction)
					circle_dir = 1.0 if cross > 0 else -1.0
				else:
					circle_dir = 1.0 if randf() < 0.5 else -1.0
				desired_direction = direction_to_enemy.rotated(PI/2 * circle_dir) * 0.5
				player_ref.bot_running = false
			
			# Defensive action: block, parry, or dodge
			var current_defense_chance = DEFENSIVE_DODGE_CHANCE if (is_low_health or nearby_enemy_count > 1) else DODGE_CHANCE
			if not is_blocking and randf() < current_defense_chance:
				_do_defensive_action()
		
		elif distance <= ATTACK_RANGE * 2.5:
			debug_state = "CLOSING"
			# Close in for attack (slower if low health or surrounded)
			desired_direction = direction_to_enemy
			player_ref.bot_running = not (is_low_health or nearby_enemy_count > 1)
		
		else:
			debug_state = "HUNTING"
			# Move toward enemy with slight curve (more natural movement)
			var curve_noise = sin(Engine.get_physics_frames() * 0.05) * MOVEMENT_CURVE
			desired_direction = direction_to_enemy.rotated(curve_noise)
			# Less aggressive when low health or multiple enemies
			var should_run = randf() < RUN_CHANCE
			if is_low_health or nearby_enemy_count > 1:
				should_run = randf() < (RUN_CHANCE * 0.5)
			player_ref.bot_running = should_run
	else:
		# No enemy nearby - explore/wander
		debug_state = "WANDERING"
		player_ref.bot_running = false
		
		if direction_timer <= 0:
			_pick_wander_direction()


func _apply_movement() -> void:
	if player_ref == null:
		return
	
	# Check if stuck (position hasn't changed much)
	_check_if_stuck()
	
	# Clamp direction to ensure valid movement
	if current_direction.length() > 1.0:
		current_direction = current_direction.normalized()
	
	var adjusted_direction = current_direction
	
	# If stuck, apply obstacle avoidance
	if avoiding_obstacle:
		adjusted_direction = obstacle_avoidance_dir
	
	# Apply boundary avoidance
	adjusted_direction = _apply_boundary_avoidance(adjusted_direction)
	
	player_ref.bot_input_direction = adjusted_direction


func _check_if_stuck() -> void:
	if player_ref == null:
		return
	
	var current_pos = player_ref.global_position
	var delta = 1.0 / 60.0  # Assume 60 FPS
	
	# Only check stuck status periodically (every 0.5 seconds worth of frames)
	if Engine.get_physics_frames() % 30 != 0:
		return
	
	var movement = current_pos.distance_to(last_position)
	
	# If we're trying to move but haven't moved much in 0.5 seconds
	# At walk speed (80 px/s), should move ~40px in 0.5s
	if desired_direction.length() > 0.1 and movement < 20.0:
		stuck_timer += 0.5
		
		if stuck_timer > 1.0:  # Stuck for more than 1 second
			_start_obstacle_avoidance()
	else:
		stuck_timer = 0.0
		avoiding_obstacle = false
	
	last_position = current_pos


func _start_obstacle_avoidance() -> void:
	avoiding_obstacle = true
	
	# Try perpendicular directions to get around obstacle
	var perpendicular = desired_direction.rotated(PI / 2)
	
	# Randomly choose left or right
	if randf() < 0.5:
		perpendicular = -perpendicular
	
	obstacle_avoidance_dir = perpendicular.normalized()
	
	# Reset stuck timer but keep avoiding for a bit
	stuck_timer = -0.8  # Give extra time to get around obstacle


func _apply_boundary_avoidance(direction: Vector2) -> Vector2:
	if player_ref == null:
		return direction
	
	var pos = player_ref.global_position
	var adjusted = direction
	
	# Push away from boundaries (using dynamic zone size)
	if pos.x < ZONE_PADDING:
		adjusted.x = max(adjusted.x, 0.5)
	elif pos.x > current_zone_size.x - ZONE_PADDING:
		adjusted.x = min(adjusted.x, -0.5)
	
	if pos.y < ZONE_PADDING:
		adjusted.y = max(adjusted.y, 0.5)
	elif pos.y > current_zone_size.y - ZONE_PADDING:
		adjusted.y = min(adjusted.y, -0.5)
	
	# Apply hazard avoidance steering
	if hazard_avoidance_vector != Vector2.ZERO:
		adjusted += hazard_avoidance_vector
		adjusted = adjusted.normalized()
	
	return adjusted


func _do_attack() -> void:
	if player_ref == null:
		return
	
	# Already doing combo chain - trigger next hit
	if combo_hits_remaining > 0:
		player_ref.bot_trigger_action("attack")
		combo_hits_remaining -= 1
		combo_timer = 0.5  # Reset window for next hit
		attack_cooldown = 0.35  # Short cooldown between combo hits
		return
	
	# Check for ground pound opportunity (surrounded and level 5+)
	if _should_use_ground_pound():
		_do_ground_pound()
		return
	
	# Decide attack type: charge attack vs combo
	var use_charge = randf() < CHARGE_ATTACK_CHANCE
	
	# More likely to use charge when only one enemy (high damage single target)
	if enemies_found == 1 and nearest_enemy_dist < ATTACK_RANGE * 1.5:
		use_charge = randf() < 0.4
	
	if use_charge:
		_start_charge_attack()
	else:
		_start_combo_attack()


func _do_dodge() -> void:
	if player_ref == null:
		return
	
	player_ref.bot_trigger_action("dodge")
	dodge_cooldown = 1.5


# =============================================================================
# NEW COMBAT ABILITIES
# =============================================================================

## Start a combo attack chain (may do 1-3 hits based on chance)
func _start_combo_attack() -> void:
	# First hit
	player_ref.bot_trigger_action("attack")
	attack_cooldown = 0.35
	
	# Decide if we want to chain (FULL_COMBO_CHANCE for full, else partial)
	if randf() < FULL_COMBO_CHANCE:
		combo_hits_remaining = 2  # Full 3-hit combo (first hit done, 2 remaining)
	elif randf() < 0.5:
		combo_hits_remaining = 1  # 2-hit combo
	else:
		combo_hits_remaining = 0  # Single hit only
	
	combo_timer = 0.5  # Window to trigger next hit


## Start a charge attack (hold then release)
func _start_charge_attack() -> void:
	is_charging = true
	charge_timer = 0.0
	# Random charge time between half and full charge
	charge_target_time = randf_range(0.6, 1.2)
	attack_cooldown = charge_target_time + 0.5  # Don't re-attack while charging


## Update charge attack state (called from _physics_process)
func _update_charge_attack(delta: float) -> void:
	if not enabled or not is_charging or player_ref == null:
		is_charging = false  # Clear state when disabled
		return
	
	charge_timer += delta
	
	# Release at target time
	if charge_timer >= charge_target_time:
		is_charging = false
		# Trigger the charge attack (player_charge_attack.gd checks for held button)
		# Since we can't "hold" a button, we trigger attack and let the state handle it
		player_ref.bot_trigger_action("charge_attack")
		attack_cooldown = 0.5


## Update combo timing window
func _update_combo_timing(delta: float) -> void:
	if not enabled or player_ref == null:
		combo_hits_remaining = 0  # Clear state when disabled
		return
	
	if combo_hits_remaining > 0:
		combo_timer -= delta
		
		# Trigger next combo hit in the window
		if combo_timer <= 0.3 and combo_timer > 0:  # Sweet spot for combo timing
			# Only if we're in range and not doing other things
			if target_enemy != null and nearest_enemy_dist < ATTACK_RANGE * 1.5:
				player_ref.bot_trigger_action("attack")
				combo_hits_remaining -= 1
				combo_timer = 0.5  # Reset for next potential hit
				attack_cooldown = 0.35
		
		# Combo window expired
		if combo_timer <= 0:
			combo_hits_remaining = 0


## Check if we should use ground pound
func _should_use_ground_pound() -> bool:
	if player_ref == null:
		return false
	
	# Check level requirement
	if player_ref.get_current_level() < 5:
		return false
	
	# Check cooldown
	if player_ref.get_ground_pound_cooldown() > 0:
		return false
	
	# Use when surrounded (3+ nearby enemies) or multiple enemies in AOE range
	if is_surrounded or nearby_enemy_count >= 3:
		if randf() < GROUND_POUND_CHANCE:
			return true
	
	# Also consider when 2 enemies are very close
	if nearby_enemy_count >= 2 and nearest_enemy_dist < 40:
		if randf() < GROUND_POUND_CHANCE * 0.8:
			return true
	
	return false


## Execute ground pound
func _do_ground_pound() -> void:
	if player_ref == null:
		return
	
	player_ref.bot_trigger_action("ground_pound")
	ground_pound_cooldown = 3.5  # Local tracking (state has actual cooldown)
	attack_cooldown = 1.0  # Recovery time


func _do_dodge_toward_safety() -> void:
	if player_ref == null:
		return
	
	# Set direction toward safety before dodging
	if safest_direction.length() > 0.1:
		desired_direction = safest_direction
		current_direction = safest_direction
		player_ref.bot_input_direction = safest_direction
	
	player_ref.bot_trigger_action("dodge")
	dodge_cooldown = 1.5

# =============================================================================
# BLOCK/PARRY SYSTEM
# =============================================================================

## Update blocking state (called from _physics_process)
func _update_blocking(delta: float) -> void:
	if not enabled or player_ref == null:
		is_blocking = false
		player_ref.bot_blocking = false
		return
	
	if is_blocking:
		block_timer += delta
		
		# Check if we should stop blocking
		if block_timer >= block_target_duration:
			_stop_blocking()
		elif not _should_continue_blocking():
			_stop_blocking()
	
	# Apply blocking state to player
	player_ref.bot_blocking = is_blocking

## Start blocking (with optional parry attempt)
func _start_blocking(try_parry: bool = false) -> void:
	if player_ref == null or is_blocking:
		return
	
	# Check if player can block
	if player_ref.guard and not player_ref.guard.can_block():
		return
	
	is_blocking = true
	block_timer = 0.0
	attempting_parry = try_parry
	
	if try_parry:
		# Short block for parry attempt - just past the parry window
		block_target_duration = PARRY_WINDOW + randf_range(0.05, 0.15)
		debug_state = "PARRYING"
	else:
		# Normal block duration
		block_target_duration = randf_range(BLOCK_DURATION_MIN, BLOCK_DURATION_MAX)
		debug_state = "BLOCKING"
	
	player_ref.bot_blocking = true
	parry_cooldown = 0.8  # Can't spam parry attempts

## Stop blocking
func _stop_blocking() -> void:
	is_blocking = false
	attempting_parry = false
	if player_ref:
		player_ref.bot_blocking = false

## Check if we should continue blocking
func _should_continue_blocking() -> bool:
	if player_ref == null:
		return false
	
	# Stop if guard is depleted
	if player_ref.guard and not player_ref.guard.can_block():
		return false
	
	# Stop if no enemies nearby
	if nearby_enemy_count == 0:
		return false
	
	return true

## Decide whether to block, parry, or dodge
func _do_defensive_action() -> void:
	if player_ref == null:
		return
	
	# Can't defend if already blocking or on cooldown
	if is_blocking:
		return
	
	# Check if we can block (have guard available)
	var can_block = player_ref.guard and player_ref.guard.can_block()
	
	# Decide: block, parry attempt, or dodge
	var action_roll = randf()
	
	if can_block and action_roll < BLOCK_CHANCE:
		# Try to parry or normal block
		var try_parry = parry_cooldown <= 0 and randf() < PARRY_ATTEMPT_CHANCE
		_start_blocking(try_parry)
	else:
		# Dodge instead
		_do_dodge_toward_safety()

## Check if an enemy is about to attack (for reactive blocking)
func _is_enemy_attacking() -> bool:
	if target_enemy == null or not is_instance_valid(target_enemy):
		return false
	
	# Check if enemy is in attack state
	if target_enemy.has_node("StateMachine"):
		var state = target_enemy.get_node("StateMachine").current_state
		if state and state.name == "Attack":
			return true
	
	return false


func _start_kite(direction: Vector2) -> void:
	is_kiting = true
	kite_timer = KITE_DURATION
	kite_direction = direction.normalized()
	# Slight randomization to be less predictable
	kite_direction = kite_direction.rotated(randf_range(-0.3, 0.3))


func _pick_wander_direction() -> void:
	# Human-like: variable wander duration
	direction_timer = DIRECTION_CHANGE_TIME + randf() * 1.5
	
	var pos = player_ref.global_position if player_ref else Vector2(400, 300)
	
	# Find all living enemies and pick closest/best target
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_enemy: Node = null
	var closest_dist: float = 999999.0
	var living_enemy_count: int = 0
	
	for e in enemies:
		if is_instance_valid(e) and e.has_method("is_alive") and e.is_alive():
			living_enemy_count += 1
			var dist = pos.distance_to(e.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_enemy = e
	
	# Hunt threshold: more aggressive in dark zones (always hunt if visible)
	var hunt_chance = 0.85 if is_in_dark_zone else 0.7
	if closest_enemy != null and randf() < hunt_chance:
		var dir_to_enemy = (closest_enemy.global_position - pos).normalized()
		# Less aim variance in dark (focused) vs open zones (casual)
		var aim_var = 0.1 if is_in_dark_zone else 0.2
		desired_direction = dir_to_enemy.rotated(randf_range(-aim_var, aim_var))
		# Run toward enemies more often when there are fewer left
		var run_chance = 0.5 if living_enemy_count > 3 else 0.8
		# Always run in dark zones (dangerous environment)
		if is_in_dark_zone:
			run_chance = 0.9
		player_ref.bot_running = randf() < run_chance
		return
	
	# Generate patrol points proportional to current zone
	var patrol_points = _generate_patrol_points()
	
	# In dark zones, reduce wander duration (stay alert, move more purposefully)
	if is_in_dark_zone:
		direction_timer = DIRECTION_CHANGE_TIME * 0.6  # Shorter wander legs in darkness
	
	# Pick a random patrol point we're not too close to
	var target_point = patrol_points[randi() % patrol_points.size()]
	var attempts = 0
	while pos.distance_to(target_point) < 100 and attempts < 5:
		target_point = patrol_points[randi() % patrol_points.size()]
		attempts += 1
	
	var to_target = (target_point - pos).normalized()
	desired_direction = to_target.rotated(randf_range(-0.2, 0.2))
	
	# Avoid hazards during patrol
	if hazard_avoidance_vector != Vector2.ZERO:
		desired_direction = (desired_direction + hazard_avoidance_vector).normalized()
	
	# Usually run when patrolling
	player_ref.bot_running = randf() < 0.6
	
	# Shorter pauses when no enemies around
	if randf() < 0.1:
		desired_direction = Vector2.ZERO
		direction_timer = randf_range(0.1, 0.3)


# =============================================================================
# HELPERS
# =============================================================================

func _update_zone_awareness() -> void:
	# Only re-detect when zone ref is lost (zone transition) or not yet detected
	if _zone_size_detected and is_instance_valid(current_zone_ref):
		return
	
	if player_ref == null:
		return
	
	# Walk up the player's ancestor tree to find BaseZone
	var node = player_ref.get_parent()
	while node != null:
		if node is BaseZone:
			current_zone_ref = node
			current_zone_size = node.zone_size
			_zone_size_detected = true
			print("[AutoBot] Zone detected: %s (size: %s)" % [node.zone_id, current_zone_size])
			return
		node = node.get_parent()
	
	# Fallback: read camera limits from player if BaseZone not found
	if player_ref.has_node("Camera2D"):
		var cam = player_ref.get_node("Camera2D")
		var w = cam.limit_right - cam.limit_left
		var h = cam.limit_bottom - cam.limit_top
		if w > 0 and h > 0:
			current_zone_size = Vector2(w, h)
			_zone_size_detected = true
			print("[AutoBot] Zone size from camera: %s" % current_zone_size)
			return
	
	# Ultimate fallback
	current_zone_size = DEFAULT_ZONE_SIZE
	_zone_size_detected = true
	print("[AutoBot] Using default zone size: %s" % current_zone_size)


func _update_health_status() -> void:
	if player_ref == null:
		return
	
	# Get health from player's HealthComponent
	if player_ref.has_node("HealthComponent"):
		var health = player_ref.get_node("HealthComponent")
		if health.has_method("get_health_percent"):
			player_health_percent = health.get_health_percent()
		elif health.has_method("get_current_health") and health.has_method("get_max_health"):
			var current = health.get_current_health()
			var max_hp = health.get_max_health()
			if max_hp > 0:
				player_health_percent = float(current) / float(max_hp)
	
	# Update health state flags
	is_low_health = player_health_percent < LOW_HEALTH_THRESHOLD
	is_critical_health = player_health_percent < CRITICAL_HEALTH_THRESHOLD


func _update_crowd_awareness() -> void:
	if player_ref == null:
		return
	
	var player_pos = player_ref.global_position
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	# Reset counters
	nearby_enemy_count = 0
	var threat_vectors: Array[Vector2] = []
	
	# Count nearby enemies and track their directions
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_alive") and not enemy.is_alive():
			continue
		
		var dist = player_pos.distance_to(enemy.global_position)
		if dist < CROWD_DANGER_RANGE:
			nearby_enemy_count += 1
			var dir_to_enemy = (enemy.global_position - player_pos).normalized()
			threat_vectors.append(dir_to_enemy)
	
	# Calculate safest direction (away from all threats)
	if threat_vectors.size() > 0:
		var combined_threat = Vector2.ZERO
		for vec in threat_vectors:
			combined_threat += vec
		combined_threat /= threat_vectors.size()
		
		# Safest direction is opposite of combined threat
		safest_direction = -combined_threat.normalized()
		
		# Apply boundary awareness to safest direction
		safest_direction = _apply_boundary_avoidance(safest_direction)
	else:
		safest_direction = Vector2.ZERO
	
	# Check if surrounded (enemies on multiple sides)
	is_surrounded = _check_if_surrounded(threat_vectors)


func _update_hazard_awareness() -> void:
	if player_ref == null:
		return
	
	var player_pos = player_ref.global_position
	nearby_hazards.clear()
	hazard_avoidance_vector = Vector2.ZERO
	
	# Scan for toxic puddles — they are Area2D children in the zone's Hazards container
	var hazard_repulsion = Vector2.ZERO
	var hazard_count = 0
	
	# Find hazards via zone tree (puddles aren't in a group — they're children of Hazards container)
	if is_instance_valid(current_zone_ref) and current_zone_ref.has_node("Hazards"):
		var hazards_node = current_zone_ref.get_node("Hazards")
		for hazard in hazards_node.get_children():
			var dist = player_pos.distance_to(hazard.global_position)
			if dist < HAZARD_DETECTION_RANGE:
				nearby_hazards.append(hazard)
				# Stronger repulsion when closer (inverse distance weighting)
				var strength = 1.0 - (dist / HAZARD_DETECTION_RANGE)
				var away_dir = (player_pos - hazard.global_position).normalized()
				hazard_repulsion += away_dir * strength
				hazard_count += 1
	
	# Amplify avoidance when already poisoned (reactive learning)
	if player_ref.has_node("HealthComponent"):
		var health = player_ref.get_node("HealthComponent")
		if health.is_poisoned and hazard_count > 0:
			hazard_repulsion *= 1.5
	
	if hazard_count > 0:
		hazard_avoidance_vector = (hazard_repulsion / hazard_count).normalized() * HAZARD_AVOIDANCE_STRENGTH
	
	# Detect darkness zones (sewers has CanvasModulate named "Darkness")
	is_in_dark_zone = false
	if is_instance_valid(current_zone_ref):
		is_in_dark_zone = current_zone_ref.has_node("Darkness")


func _find_nearest_enemy() -> Node:
	if player_ref == null:
		return null
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	enemies_found = 0
	nearest_enemy_dist = 9999.0
	var best_target: Node = null
	var best_score: float = -9999.0
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		# Skip dead enemies
		if enemy.has_method("is_alive") and not enemy.is_alive():
			continue
		
		enemies_found += 1
		var dist = player_ref.global_position.distance_to(enemy.global_position)
		
		# Track nearest distance for debug
		if dist < nearest_enemy_dist:
			nearest_enemy_dist = dist
		
		# Only consider enemies in range
		if dist > ENEMY_DETECTION_RANGE:
			continue
		
		# Score calculation: prefer closer, weaker enemies
		var score = ENEMY_DETECTION_RANGE - dist  # Base score from distance
		
		# Bonus for enemies already targeting us (they're a threat)
		if enemy.has_method("get_target") and enemy.get_target() == player_ref:
			score += 50.0
		
		# Bonus for low health enemies (finish them off)
		if enemy.has_node("HealthComponent"):
			var health = enemy.get_node("HealthComponent")
			if health.has_method("get_health_percent"):
				var hp_percent = health.get_health_percent()
				if hp_percent < 0.5:
					score += 100.0 * (1.0 - hp_percent)  # More bonus for lower HP
		
		# Prefer current target for consistency (less erratic switching)
		if enemy == target_enemy:
			score += 30.0
		
		if score > best_score:
			best_score = score
			best_target = enemy
	
	return best_target


## Get status text for HUD
func get_status() -> String:
	if not enabled:
		return "OFF"
	return debug_state


## Get detailed debug info
func get_debug_info() -> String:
	if not enabled:
		return "AutoBot: OFF"
	
	var info = "AutoBot: %s\n" % debug_state
	info += "Enemies: %d" % enemies_found
	if nearest_enemy_dist < ENEMY_DETECTION_RANGE:
		info += " (%.0fpx)" % nearest_enemy_dist
	info += "\n"
	info += "Nearby: %d | HP: %.0f%%" % [nearby_enemy_count, player_health_percent * 100]
	if is_surrounded:
		info += " [SURROUNDED]"
	if is_blocking:
		var block_type = "PARRY" if attempting_parry else "BLOCK"
		info += " [%s]" % block_type
	info += "\n"
	# Show guard status
	if player_ref and player_ref.guard:
		var guard_pct = player_ref.guard.get_guard_percent() * 100
		info += "Guard: %.0f%% | " % guard_pct
	if player_ref:
		info += "Pos: (%.0f, %.0f)" % [player_ref.global_position.x, player_ref.global_position.y]
	return info


## Count living enemies
func _count_living_enemies() -> int:
	var count = 0
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e) and e.has_method("is_alive") and e.is_alive():
			count += 1
	return count


## Log debug status periodically
func _log_debug_status() -> void:
	var living_enemies = 0
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e) and e.has_method("is_alive") and e.is_alive():
			living_enemies += 1
	
	var pos_str = "N/A"
	var hp_str = "N/A"
	var guard_str = "N/A"
	if player_ref:
		pos_str = "(%.0f, %.0f)" % [player_ref.global_position.x, player_ref.global_position.y]
		hp_str = "%.0f%%" % (player_health_percent * 100)
		if player_ref.guard:
			guard_str = "%.0f%%" % (player_ref.guard.get_guard_percent() * 100)
	
	var block_str = ""
	if is_blocking:
		block_str = " | BLOCKING" if not attempting_parry else " | PARRYING"
	
	print("[AutoBot] State: %s | Pos: %s | HP: %s | Guard: %s | Enemies: %d | Nearest: %.0fpx%s" % [
		debug_state, pos_str, hp_str, guard_str, living_enemies, nearest_enemy_dist, block_str
	])


## Generate patrol points proportional to current zone dimensions
func _generate_patrol_points() -> Array[Vector2]:
	# For corridor-based zones (sewers), generate points along walkable corridors
	if is_instance_valid(current_zone_ref):
		# Check if zone has corridor_segments (sewers-style layout)
		if "corridor_segments" in current_zone_ref:
			return _generate_corridor_patrol_points()
	
	# Default: grid-based patrol for open zones
	var zs = current_zone_size
	var pad = ZONE_PADDING * 2  # Stay well inside boundaries
	var points: Array[Vector2] = []
	
	# Generate a grid of patrol points covering the zone
	# 3 columns x 2 rows = 6 points, proportional to zone size
	var cols = 3
	var rows = 2
	for row in range(rows):
		for col in range(cols):
			var x = pad + (zs.x - pad * 2) * (float(col) / float(cols - 1)) if cols > 1 else zs.x / 2.0
			var y = pad + (zs.y - pad * 2) * (float(row) / float(rows - 1)) if rows > 1 else zs.y / 2.0
			points.append(Vector2(x, y))
	
	# Add center point
	points.append(Vector2(zs.x / 2.0, zs.y / 2.0))
	
	return points


## Generate patrol points at the center of each corridor segment and side room
func _generate_corridor_patrol_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	
	# Sample center points from each corridor segment
	var segments: Array = current_zone_ref.corridor_segments
	for seg in segments:
		# Center of each corridor segment
		var center = seg.position + seg.size / 2.0
		points.append(center)
	
	# Also sample side room centers (exploration)
	if "side_rooms" in current_zone_ref:
		var rooms: Array = current_zone_ref.side_rooms
		for room in rooms:
			var rect: Rect2 = room.rect
			points.append(rect.position + rect.size / 2.0)
	
	return points


## Check if enemies are on multiple sides (surrounded)
func _check_if_surrounded(threat_vectors: Array[Vector2]) -> bool:
	if threat_vectors.size() < 2:
		return false
	
	# Divide space into 6 sectors (60 degrees each)
	var sectors_occupied = 0
	var sector_size = TAU / 6  # 60 degrees
	var sector_flags = [false, false, false, false, false, false]
	
	for vec in threat_vectors:
		var angle = vec.angle()
		# Normalize angle to 0-TAU
		if angle < 0:
			angle += TAU
		
		var sector_index = int(angle / sector_size) % 6
		if not sector_flags[sector_index]:
			sector_flags[sector_index] = true
			sectors_occupied += 1
	
	# Consider surrounded if enemies in 3+ different sectors
	return sectors_occupied >= 3

# =============================================================================
# PHASE 16: RING MENU / ITEMS / COMPANIONS
# =============================================================================

## Update Phase 16 systems (ring menu, item usage, companion cycling)
func _update_phase16_systems(delta: float) -> void:
	# Update timers
	companion_cycle_timer -= delta
	ring_menu_test_timer -= delta
	revival_check_timer -= delta
	equip_check_timer -= delta
	
	# Allow critical healing even in combat
	if is_critical_health:
		_try_use_smart_healing()
	
	# Combat-specific item actions
	if nearby_enemy_count > 0:
		# Use guard snack when guard is low in combat
		_try_use_guard_snack()
		# Use buff treats before tough encounters
		if target_enemy != null:
			_try_use_buff_treats()
	
	# Don't do non-combat Phase 16 actions while in close combat
	if nearby_enemy_count > 0 and nearest_enemy_dist < 100:
		return
	
	# Smart healing when safe (tiered by damage severity)
	if player_health_percent < LIGHT_DAMAGE_THRESHOLD and nearby_enemy_count == 0:
		_try_use_smart_healing()
	
	# Check for companion revival
	if revival_check_timer <= 0:
		revival_check_timer = REVIVAL_CHECK_INTERVAL
		_try_revive_companion()
	
	# Optimize equipment periodically (when safe)
	if equip_check_timer <= 0 and nearby_enemy_count == 0:
		equip_check_timer = EQUIP_CHECK_INTERVAL
		_optimize_equipment()
	
	# Cycle companions periodically
	if companion_cycle_timer <= 0:
		companion_cycle_timer = COMPANION_CYCLE_INTERVAL + randf_range(-3, 3)
		_cycle_companion()
	
	# Test ring menu periodically (when safe)
	if ring_menu_test_timer <= 0 and nearby_enemy_count == 0:
		ring_menu_test_timer = RING_MENU_TEST_INTERVAL + randf_range(-5, 5)
		_test_ring_menu()


## Smart tiered healing — picks items based on damage severity
func _try_use_smart_healing() -> void:
	# Don't spam item usage
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_item_use_time < 3.0:
		return
	
	# Check if inventory exists
	if not GameManager.inventory:
		return
	
	# Determine item tier based on HP level
	var items_to_try: Array[String] = []
	
	if player_health_percent < HEAVY_DAMAGE_THRESHOLD:
		# Critical/heavy damage — use strongest available
		items_to_try = ["full_heal", "mega_potion", "health_potion", "acorn", "bird_seed"]
	elif player_health_percent < MODERATE_DAMAGE_THRESHOLD:
		# Moderate damage — use potions, don't waste full_heal
		items_to_try = ["health_potion", "mega_potion", "acorn", "bird_seed"]
	elif player_health_percent < LIGHT_DAMAGE_THRESHOLD:
		# Light damage — use snacks, save potions
		items_to_try = ["acorn", "bird_seed"]
	else:
		return  # HP is above 90%, no healing needed
	
	for item_id in items_to_try:
		if GameManager.inventory.has_item(item_id):
			if GameManager.inventory.use_item(item_id):
				last_item_use_time = current_time
				print("[AutoBot] Smart heal (%d%% HP): used %s" % [int(player_health_percent * 100), item_id])
				return


## Use guard_snack when guard meter is low during combat
func _try_use_guard_snack() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_guard_snack_time < 5.0:
		return
	
	if not GameManager.inventory:
		return
	
	# Only use in combat when guard is low
	if player_ref == null or not player_ref.guard:
		return
	
	if player_ref.guard.get_guard_percent() >= GUARD_SNACK_THRESHOLD:
		return
	
	if nearby_enemy_count == 0:
		return
	
	if GameManager.inventory.has_item("guard_snack"):
		if GameManager.inventory.use_item("guard_snack"):
			last_guard_snack_time = current_time
			print("[AutoBot] Used guard_snack (guard was %.0f%%)" % (player_ref.guard.get_guard_percent() * 100))


## Use buff treats before tough encounters
func _try_use_buff_treats() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_buff_use_time < BUFF_COOLDOWN:
		return
	
	if not GameManager.inventory:
		return
	
	# Determine if situation warrants buffs
	var is_tough_fight = nearby_enemy_count >= BUFF_ENEMY_THRESHOLD
	if not is_tough_fight and target_enemy != null and is_instance_valid(target_enemy):
		is_tough_fight = _is_tough_enemy(target_enemy)
	
	# Speed treat is always available at critical health (retreat buff)
	if is_critical_health and not GameManager.inventory.has_buff(ItemDatabase.EffectType.BUFF_SPEED):
		if GameManager.inventory.has_item("speed_treat"):
			if GameManager.inventory.use_item("speed_treat"):
				last_buff_use_time = current_time
				print("[AutoBot] Used speed_treat (critical HP escape)")
				return
	
	if not is_tough_fight:
		return
	
	# Power treat — boost damage for tough fights
	if not GameManager.inventory.has_buff(ItemDatabase.EffectType.BUFF_ATTACK):
		if GameManager.inventory.has_item("power_treat"):
			if GameManager.inventory.use_item("power_treat"):
				last_buff_use_time = current_time
				print("[AutoBot] Used power_treat (tough fight)")
				return
	
	# Tough treat — reduce incoming damage
	if not GameManager.inventory.has_buff(ItemDatabase.EffectType.BUFF_DEFENSE):
		if GameManager.inventory.has_item("tough_treat"):
			if GameManager.inventory.use_item("tough_treat"):
				last_buff_use_time = current_time
				print("[AutoBot] Used tough_treat (tough fight)")
				return


## Check if an enemy is a tough opponent (mini-boss or high HP)
func _is_tough_enemy(enemy: Node) -> bool:
	if enemy == null or not is_instance_valid(enemy):
		return false
	# Check if mini-boss (high HP enemies — 80+ max health)
	if enemy.has_node("HealthComponent"):
		var health = enemy.get_node("HealthComponent")
		if health.max_health >= 80:
			return true
	return false


## Revive knocked-out companions with revival_bone
func _try_revive_companion() -> void:
	# Only revive when safe (no nearby enemies)
	if nearby_enemy_count > 0:
		return
	
	if not GameManager.inventory or not GameManager.party_manager:
		return
	
	# Check if any companions are knocked out
	var knocked_out = GameManager.party_manager.knocked_out
	if knocked_out.is_empty():
		return
	
	# Check if we have revival bone
	if not GameManager.inventory.has_item("revival_bone"):
		return
	
	# Find first knocked-out companion and revive
	for companion_id in knocked_out:
		if GameManager.inventory.use_item("revival_bone"):
			GameManager.party_manager.revive_companion(companion_id, 0.5)
			print("[AutoBot] Used revival_bone to revive %s" % companion_id)
			return


## Optimize equipment — auto-equip best gear per slot
func _optimize_equipment() -> void:
	if not GameManager.equipment_manager:
		return
	
	var em = GameManager.equipment_manager
	
	# Check each slot for upgrades
	for slot in EquipmentDatabase.Slot.values():
		var current_id = em.get_equipped(slot)
		var current_score = _get_equipment_score(current_id)
		
		# Check all unequipped equipment that fits this slot
		var best_id = current_id
		var best_score = current_score
		
		for equip_id in em.equipment_inventory:
			var equip_data = EquipmentDatabase.get_equipment(equip_id)
			if equip_data.is_empty():
				continue
			if equip_data.slot != slot:
				continue
			
			var score = _get_equipment_score(equip_id)
			if score > best_score:
				best_score = score
				best_id = equip_id
		
		# Equip if better option found
		if best_id != current_id and best_id != "":
			em.equip(best_id)
			print("[AutoBot] Equipped %s (score: %.0f > %.0f)" % [best_id, best_score, current_score])


## Score equipment by weighted stat totals
func _get_equipment_score(equip_id: String) -> float:
	if equip_id == "":
		return 0.0
	
	var equip_data = EquipmentDatabase.get_equipment(equip_id)
	if equip_data.is_empty():
		return 0.0
	
	var score: float = 0.0
	var stats = equip_data.get("stats", {})
	
	# Weight each stat type (attack and HP most valuable for bot)
	for stat_type in stats:
		var value = stats[stat_type]
		match stat_type:
			EquipmentDatabase.StatType.ATTACK_DAMAGE:
				score += value * 3.0    # Attack is king (kills faster = less damage taken)
			EquipmentDatabase.StatType.MAX_HEALTH:
				score += value * 1.5    # HP is survival
			EquipmentDatabase.StatType.DEFENSE:
				score += value * 2.0    # Defense percentage is strong
			EquipmentDatabase.StatType.MOVE_SPEED:
				score += value * 1.0    # Speed helps kiting
			EquipmentDatabase.StatType.GUARD_REGEN:
				score += value * 1.5    # Guard regen for blocking bot
			EquipmentDatabase.StatType.EXP_BONUS:
				score += value * 0.5    # EXP is nice but not survival
	
	return score


## Cycle to next companion using Q key
func _cycle_companion() -> void:
	if not GameManager.party_manager:
		return
	
	# Only cycle if we have companions registered
	if GameManager.party_manager.companions.size() == 0:
		return
	
	# Simulate Q key press
	var event = InputEventAction.new()
	event.action = "cycle_companion"
	event.pressed = true
	Input.parse_input_event(event)
	
	print("[AutoBot] Cycled companion -> %s" % GameManager.party_manager.active_companion_id)


## Test the ring menu by opening, browsing, and closing it
func _test_ring_menu() -> void:
	# Open ring menu
	var open_event = InputEventAction.new()
	open_event.action = "ring_menu"
	open_event.pressed = true
	Input.parse_input_event(open_event)
	
	print("[AutoBot] Testing ring menu...")
	
	# Take screenshot after a short delay to let menu animate open
	await get_tree().create_timer(0.3).timeout
	_capture_ring_menu_screenshot()
	
	# Schedule navigation actions
	_schedule_ring_menu_navigation()

## Capture a screenshot of the ring menu for UI verification
func _capture_ring_menu_screenshot() -> void:
	var viewport = get_viewport()
	if viewport == null:
		print("[AutoBot] No viewport for screenshot")
		return
	
	var image = viewport.get_texture().get_image()
	if image == null:
		print("[AutoBot] Failed to get viewport image")
		return
	
	# Save to project root for easy access
	var error = image.save_png("res://screenshot.png")
	if error == OK:
		print("[AutoBot] Ring menu screenshot saved to screenshot.png")
	else:
		print("[AutoBot] Failed to save screenshot: error %d" % error)


## Schedule ring menu navigation actions
func _schedule_ring_menu_navigation() -> void:
	# Wait a bit, then navigate through rings
	await get_tree().create_timer(0.5).timeout
	
	# Navigate right a few times
	for i in range(3):
		var nav_event = InputEventAction.new()
		nav_event.action = "move_right"
		nav_event.pressed = true
		Input.parse_input_event(nav_event)
		await get_tree().create_timer(0.3).timeout
	
	# Switch to next ring (down)
	var switch_event = InputEventAction.new()
	switch_event.action = "move_down"
	switch_event.pressed = true
	Input.parse_input_event(switch_event)
	await get_tree().create_timer(0.5).timeout
	
	# Navigate a bit more
	for i in range(2):
		var nav_event = InputEventAction.new()
		nav_event.action = "move_left"
		nav_event.pressed = true
		Input.parse_input_event(nav_event)
		await get_tree().create_timer(0.3).timeout
	
	# Close ring menu
	var close_event = InputEventAction.new()
	close_event.action = "ring_menu"
	close_event.pressed = true
	Input.parse_input_event(close_event)
	
	print("[AutoBot] Ring menu test complete")
