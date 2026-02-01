extends State
class_name PlayerComboAttack
## Combo attack state - 3-hit chain with timing windows and damage scaling.
## Press attack repeatedly within the combo window to chain hits.

# =============================================================================
# COMBO CONFIGURATION
# =============================================================================

## Combo data for each hit: duration, damage multiplier, hitbox timing
const COMBO_DATA = [
	{"duration": 0.3, "damage_mult": 1.0, "hitbox_start": 0.08, "hitbox_end": 0.22},   # Hit 1: Quick jab
	{"duration": 0.35, "damage_mult": 1.25, "hitbox_start": 0.1, "hitbox_end": 0.25},  # Hit 2: Swipe
	{"duration": 0.45, "damage_mult": 1.75, "hitbox_start": 0.12, "hitbox_end": 0.35}  # Hit 3: Power bite
]

## Time window after hitbox ends to input next attack
const COMBO_WINDOW: float = 0.4

## Base damage (can be modified by level)
const BASE_DAMAGE: int = 25

# =============================================================================
# STATE
# =============================================================================

var combo_index: int = 0
var attack_timer: float = 0.0
var hitbox_active: bool = false
var can_chain: bool = false  # True when combo window is open
var chain_requested: bool = false  # Player pressed attack during window
var total_combo_damage: int = 0  # Track total damage for combo completion

# =============================================================================
# LIFECYCLE
# =============================================================================

func enter() -> void:
	# Stop movement
	player.velocity = Vector2.ZERO
	
	# Reset attack state (but keep combo_index if chaining)
	attack_timer = 0.0
	hitbox_active = false
	can_chain = false
	chain_requested = false
	
	# If this is a fresh combo (not chaining), reset index
	if combo_index >= COMBO_DATA.size():
		combo_index = 0
		total_combo_damage = 0
	
	# Calculate and set damage for this hit (uses player effective damage with equipment + buffs)
	var current_data = COMBO_DATA[combo_index]
	var effective_base = player.get_effective_base_damage()
	var damage = int(effective_base * current_data.damage_mult)
	
	if player.hitbox:
		player.hitbox.damage = damage
		player.hitbox.reset()
	
	# Position hitbox based on facing direction
	_position_hitbox()
	
	# Update player's combo count for UI
	player.set_combo_count(combo_index + 1)
	
	# Visual feedback - different color per combo hit
	_apply_combo_visual()
	
	# Emit attack event
	Events.player_attacked.emit()

func exit() -> void:
	# Ensure hitbox is disabled
	if player.hitbox:
		player.hitbox.disable()
	hitbox_active = false
	
	# Reset visual
	if player.sprite:
		player.sprite.modulate = Color.WHITE
		player.sprite.scale = Vector2.ONE
	
	# If combo dropped (not chaining), reset
	if not chain_requested:
		if combo_index > 0:
			Events.combo_dropped.emit()
		combo_index = 0
		player.set_combo_count(0)

func physics_update(delta: float) -> void:
	attack_timer += delta
	var current_data = COMBO_DATA[combo_index]
	var progress = attack_timer / current_data.duration
	
	# Check for chain input during combo window
	_check_chain_input()
	
	# Hitbox timing
	if progress >= current_data.hitbox_start and progress < current_data.hitbox_end:
		if not hitbox_active and player.hitbox:
			player.hitbox.enable()
			hitbox_active = true
	elif progress >= current_data.hitbox_end:
		if hitbox_active and player.hitbox:
			player.hitbox.disable()
			hitbox_active = false
		
		# Open combo window after hitbox ends
		can_chain = true
	
	# Attack finished
	if attack_timer >= current_data.duration:
		_finish_attack()

# =============================================================================
# COMBO LOGIC
# =============================================================================

func _check_chain_input() -> void:
	if not can_chain:
		return

	# Check for attack input during combo window (live input)
	var attack_pressed = Input.is_action_just_pressed("attack")
	if not attack_pressed and InputMap.has_action("attack_alt"):
		attack_pressed = Input.is_action_just_pressed("attack_alt")

	# Bot control
	if player.bot_controlled:
		var bot_action = player.consume_bot_action()
		if bot_action == "attack":
			attack_pressed = true

	# Also check input buffer for attack action
	if not attack_pressed and player.has_buffered_action("attack"):
		attack_pressed = true

	if attack_pressed and combo_index < COMBO_DATA.size() - 1:
		chain_requested = true

func _finish_attack() -> void:
	# Track damage for this hit
	var current_data = COMBO_DATA[combo_index]
	total_combo_damage += int(player.get_effective_base_damage() * current_data.damage_mult)

	if chain_requested and combo_index < COMBO_DATA.size() - 1:
		# Chain to next attack - consume buffered attack if that's what triggered it
		if player.has_buffered_action("attack"):
			player.consume_buffered_action()

		combo_index += 1
		chain_requested = false

		# Re-enter this state for next hit (restart timers)
		attack_timer = 0.0
		hitbox_active = false
		can_chain = false

		# Set up next hit (uses player effective damage with equipment + buffs)
		var next_data = COMBO_DATA[combo_index]
		var next_effective_base = player.get_effective_base_damage()
		var next_damage = int(next_effective_base * next_data.damage_mult)

		if player.hitbox:
			player.hitbox.damage = next_damage
			player.hitbox.reset()

		_position_hitbox()
		player.set_combo_count(combo_index + 1)
		_apply_combo_visual()

		Events.player_attacked.emit()
	else:
		# Combo ended
		if combo_index == COMBO_DATA.size() - 1:
			# Full combo completed!
			Events.combo_completed.emit(total_combo_damage)

		combo_index = 0
		total_combo_damage = 0

		# Check for buffered actions and transition accordingly
		_handle_buffered_inputs()

# =============================================================================
# INPUT BUFFERING
# =============================================================================

func _handle_buffered_inputs() -> void:
	# Check for buffered actions and transition to appropriate state
	var buffered_action = player.consume_buffered_action()

	if buffered_action == "dodge":
		state_machine.transition_to("Dodge")
	elif buffered_action == "attack":
		# Start a new combo
		state_machine.transition_to("ComboAttack")
	elif buffered_action == "special_attack" and player.is_ability_unlocked("special_attack"):
		state_machine.transition_to("SpecialAttack")
	else:
		# No buffered action, return to idle
		state_machine.transition_to("Idle")

# =============================================================================
# VISUALS
# =============================================================================

func _apply_combo_visual() -> void:
	if not player.sprite:
		return
	
	# Different visual per combo stage
	match combo_index:
		0:  # Hit 1 - White/normal
			player.sprite.modulate = Color(1.1, 1.1, 1.0)
			player.sprite.scale = Vector2(1.0, 1.0)
		1:  # Hit 2 - Yellow tint
			player.sprite.modulate = Color(1.2, 1.1, 0.8)
			player.sprite.scale = Vector2(1.05, 1.05)
		2:  # Hit 3 - Orange/red, bigger
			player.sprite.modulate = Color(1.3, 1.0, 0.7)
			player.sprite.scale = Vector2(1.1, 1.1)

func _position_hitbox() -> void:
	if not player.hitbox:
		return
	
	var hitbox_shape: CollisionShape2D = player.hitbox.get_node_or_null("CollisionShape2D")
	if not hitbox_shape:
		return
	
	# Slightly larger hitbox for later combo hits
	var scale_bonus = 1.0 + combo_index * 0.15
	hitbox_shape.scale = Vector2(scale_bonus, scale_bonus)
	
	# Position based on facing direction
	var offset_distance = 10 + combo_index * 2  # Reach increases per hit
	
	match player.facing_direction:
		"down":
			hitbox_shape.position = Vector2(0, offset_distance)
			hitbox_shape.rotation = 0
		"up":
			hitbox_shape.position = Vector2(0, -offset_distance)
			hitbox_shape.rotation = 0
		"side":
			if player.facing_left:
				hitbox_shape.position = Vector2(-offset_distance, 0)
			else:
				hitbox_shape.position = Vector2(offset_distance, 0)
			hitbox_shape.rotation = 0
