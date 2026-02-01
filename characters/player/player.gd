extends CharacterBody2D
class_name Player

## Base stats (level 1)
const BASE_WALK_SPEED: float = 80.0
const BASE_RUN_SPEED: float = 140.0
const BASE_ATTACK_DAMAGE: int = 25
const BASE_MAX_HEALTH: int = 100

## Legacy constants for compatibility
const WALK_SPEED: float = 80.0
const RUN_SPEED: float = 140.0

@onready var sprite: Polygon2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var camera: Camera2D = $Camera2D
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var health: HealthComponent = $HealthComponent
@onready var progression = $ProgressionComponent  # ProgressionComponent - no type to avoid cyclic dependency
@onready var guard = $GuardComponent  # GuardComponent for blocking

var facing_direction: String = "down"
var facing_left: bool = false

## Current combo count (for UI display)
var current_combo_count: int = 0

## Debug: Hitbox visualizer (created at runtime)
var hitbox_visualizer: HitboxVisualizer = null

# =============================================================================
# CAMERA FEEL
# =============================================================================

## Look-ahead: camera leads in player movement direction
const LOOK_AHEAD_DISTANCE: float = 20.0
const LOOK_AHEAD_SMOOTH: float = 3.0
var _look_ahead_target: Vector2 = Vector2.ZERO

## Combat zoom: subtle zoom-in when enemies nearby
const BASE_ZOOM: Vector2 = Vector2(1.0, 1.0)
const COMBAT_ZOOM: Vector2 = Vector2(1.12, 1.12)
const COMBAT_ZOOM_RANGE: float = 60.0  # Enemies within this range trigger zoom
const ZOOM_SMOOTH: float = 2.5
var _target_zoom: Vector2 = BASE_ZOOM

# =============================================================================
# BOT CONTROL - For AutoBot to control player directly
# =============================================================================

## If true, bot is controlling movement (ignores player input for movement)
var bot_controlled: bool = false

## Bot-injected input direction (used when bot_controlled is true)
var bot_input_direction: Vector2 = Vector2.ZERO

## Bot-injected running state
var bot_running: bool = false

## Pending actions from bot (attack, special_attack, dodge)
var bot_pending_action: String = ""

## Bot-injected blocking state
var bot_blocking: bool = false

func _ready() -> void:
	add_to_group("player")
	state_machine.init(self)

	if hurtbox:
		hurtbox.hurt.connect(_on_hurt)
	if health:
		health.died.connect(_on_died)
	if hitbox:
		hitbox.hit_landed.connect(_on_hit_landed)

	# Connect to level up for stat scaling
	if progression:
		progression.level_changed.connect(_on_level_changed)

	# Connect to equipment changes to re-apply stats
	if GameManager.equipment_manager:
		GameManager.equipment_manager.stats_recalculated.connect(_on_equipment_changed)

	# Apply initial stats
	_apply_level_stats()

	# Setup debug hitbox visualizer
	_setup_hitbox_visualizer()


func _unhandled_input(event: InputEvent) -> void:
	# F3 toggles hitbox visualizer (same key as debug panel)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			if hitbox_visualizer:
				hitbox_visualizer.toggle()


func _physics_process(delta: float) -> void:
	_update_camera_feel(delta)


func _update_camera_feel(delta: float) -> void:
	if not camera:
		return
	
	# --- Look-ahead: offset camera in movement direction ---
	var input_dir = get_input_direction()
	if input_dir.length() > 0.1:
		_look_ahead_target = input_dir.normalized() * LOOK_AHEAD_DISTANCE
	else:
		_look_ahead_target = Vector2.ZERO
	
	# Smoothly interpolate camera offset toward look-ahead target
	# (EffectsManager uses camera.offset for shake, so we track separately)
	var current_offset = camera.offset
	# Only adjust if not being shaken (shake_timer check via EffectsManager)
	if EffectsManager.shake_timer <= 0.0:
		camera.offset = current_offset.lerp(_look_ahead_target, LOOK_AHEAD_SMOOTH * delta)
	
	# --- Combat zoom: zoom in when enemies are close ---
	var enemies_nearby = false
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and enemy is Node2D:
			if global_position.distance_to(enemy.global_position) < COMBAT_ZOOM_RANGE:
				enemies_nearby = true
				break
	
	_target_zoom = COMBAT_ZOOM if enemies_nearby else BASE_ZOOM
	
	# Don't fight camera_punch (which also tweens zoom)
	if not EffectsManager.camera_punch_active:
		camera.zoom = camera.zoom.lerp(_target_zoom, ZOOM_SMOOTH * delta)

func _on_hurt(attacking_hitbox: Hitbox) -> void:
	var damage = attacking_hitbox.damage
	var attacker = attacking_hitbox.get_parent()
	
	# Check for parry/block
	if guard and guard.is_blocking:
		if guard.on_blocked_hit(attacker, damage):
			# Perfect parry - no damage taken!
			return
		# Normal block - reduced damage
		damage = int(damage * (1.0 - guard.get_damage_reduction()))
	
	# Apply equipment defense (flat % reduction)
	if GameManager.equipment_manager:
		var defense_pct = GameManager.equipment_manager.get_stat_bonus(EquipmentDatabase.StatType.DEFENSE)
		if defense_pct > 0.0:
			damage = int(damage * maxf(0.1, 1.0 - defense_pct))
	
	# Apply defense buff multiplier (temporary buff from items)
	if GameManager.inventory:
		var def_mult = GameManager.inventory.get_buff_multiplier(ItemDatabase.EffectType.BUFF_DEFENSE)
		if def_mult > 1.0:
			damage = int(damage / def_mult)  # e.g. 1.3x defense = take 1/1.3 damage
	
	# Ensure minimum 1 damage
	damage = maxi(damage, 1)
	
	if health:
		health.take_damage(damage)
	if health and not health.is_dead():
		# Only transition to Hurt if not blocking
		if not is_blocking():
			state_machine.transition_to("Hurt")

func _on_died() -> void:
	state_machine.transition_to("Death")

## Emitted when player's hitbox lands on an enemy hurtbox
func _on_hit_landed(hurtbox: Hurtbox) -> void:
	var enemy = hurtbox.get_parent()
	if enemy and enemy.is_in_group("enemies"):
		Events.player_hit_enemy.emit(enemy)

func get_input_direction() -> Vector2:
	# Bot control takes priority
	if bot_controlled:
		return bot_input_direction
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func is_running() -> bool:
	# Bot control takes priority
	if bot_controlled:
		return bot_running
	return Input.is_action_pressed("run")

## Check if player is currently blocking
func is_blocking() -> bool:
	return guard and guard.is_blocking

## Check if there's a pending bot action (and consume it)
func consume_bot_action() -> String:
	var action = bot_pending_action
	bot_pending_action = ""
	return action

## Bot triggers an action (attack, special_attack, dodge)
func bot_trigger_action(action: String) -> void:
	bot_pending_action = action

func update_facing(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	
	if abs(direction.x) > abs(direction.y):
		facing_direction = "side"
		facing_left = direction.x < 0
		# Flip polygon for facing
		sprite.scale.x = -1 if facing_left else 1
	else:
		facing_direction = "down" if direction.y > 0 else "up"
		sprite.scale.x = 1

func set_camera_limits(rect: Rect2) -> void:
	if camera:
		camera.limit_left = int(rect.position.x)
		camera.limit_top = int(rect.position.y)
		camera.limit_right = int(rect.end.x)
		camera.limit_bottom = int(rect.end.y)

## Get current combo count
func get_combo_count() -> int:
	return current_combo_count

## Set combo count (called by ComboAttack state)
func set_combo_count(count: int) -> void:
	current_combo_count = count
	Events.combo_changed.emit(count)

## Called when player levels up
func _on_level_changed(_new_level: int) -> void:
	_apply_level_stats()
	_push_away_from_enemies()  # Prevent getting stuck on dying enemies

## Push player away from nearby enemies on level up
func _push_away_from_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var push_dir = Vector2.ZERO
	var close_count = 0
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < 40.0:  # Very close - might be overlapping
			var away = (global_position - enemy.global_position).normalized()
			push_dir += away
			close_count += 1
	
	# Apply push if enemies were close
	if close_count > 0:
		push_dir = push_dir.normalized() * 60.0  # Push velocity
		velocity = push_dir

## Apply stats based on current level (called on init and level up — full heals)
func _apply_level_stats() -> void:
	if not progression:
		return
	
	_recalculate_stats()
	
	# FULL HEAL on level up / init (reward for leveling)
	if health:
		health.current_health = health.max_health
		Events.player_healed.emit(health.max_health)

## Recalculate all stats from level + equipment + buffs (no heal)
func _recalculate_stats() -> void:
	if not progression:
		return
	
	# Update health: base + level + equipment
	var health_bonus = progression.get_stat_bonus("max_health")
	var equip_health: int = 0
	if GameManager.equipment_manager:
		equip_health = int(GameManager.equipment_manager.get_stat_bonus(EquipmentDatabase.StatType.MAX_HEALTH))
	if health:
		health.max_health = BASE_MAX_HEALTH + health_bonus + equip_health
		# Clamp current health to new max (don't exceed)
		health.current_health = mini(health.current_health, health.max_health)
	
	# Update attack damage: base + level + equipment (buff applied per-attack)
	if hitbox:
		hitbox.damage = get_effective_base_damage()
	
	# Emit for UI
	Events.stats_updated.emit("all", progression.get_level())

## Called when equipment changes — recalculate without full heal
func _on_equipment_changed() -> void:
	_recalculate_stats()

## Get effective walk speed (level + equipment + buff)
func get_effective_walk_speed() -> float:
	var bonus: float = 0.0
	if progression:
		bonus += progression.get_stat_bonus("move_speed")
	if GameManager.equipment_manager:
		bonus += GameManager.equipment_manager.get_stat_bonus(EquipmentDatabase.StatType.MOVE_SPEED)
	var speed = BASE_WALK_SPEED + bonus
	# Apply speed buff multiplier
	if GameManager.inventory:
		speed *= GameManager.inventory.get_buff_multiplier(ItemDatabase.EffectType.BUFF_SPEED)
	return speed

## Get effective run speed (level + equipment + buff)
func get_effective_run_speed() -> float:
	var bonus: float = 0.0
	if progression:
		bonus += progression.get_stat_bonus("move_speed")
	if GameManager.equipment_manager:
		bonus += GameManager.equipment_manager.get_stat_bonus(EquipmentDatabase.StatType.MOVE_SPEED)
	var speed = BASE_RUN_SPEED + bonus * 1.5  # Run gets bigger bonus
	# Apply speed buff multiplier
	if GameManager.inventory:
		speed *= GameManager.inventory.get_buff_multiplier(ItemDatabase.EffectType.BUFF_SPEED)
	return speed

## Get effective base attack damage (level + equipment + buff)
func get_effective_base_damage() -> int:
	var base: int = BASE_ATTACK_DAMAGE
	if progression:
		base += progression.get_stat_bonus("attack_damage")
	if GameManager.equipment_manager:
		base += int(GameManager.equipment_manager.get_stat_bonus(EquipmentDatabase.StatType.ATTACK_DAMAGE))
	# Apply attack buff multiplier
	if GameManager.inventory:
		base = int(base * GameManager.inventory.get_buff_multiplier(ItemDatabase.EffectType.BUFF_ATTACK))
	return base

## Get current level
func get_current_level() -> int:
	if progression:
		return progression.get_level()
	return 1

## Check if ability is unlocked
func is_ability_unlocked(ability_name: String) -> bool:
	if not progression:
		return false
	
	match ability_name:
		"ground_pound":
			return progression.get_level() >= 5
		_:
			return true

## Get ground pound cooldown remaining
func get_ground_pound_cooldown() -> float:
	# Access static cooldown via preload to avoid cyclic dependency
	var GroundPoundState = preload("res://characters/player/states/player_ground_pound.gd")
	return GroundPoundState.cooldown_remaining

# =============================================================================
# DEBUG TOOLS
# =============================================================================

## Setup hitbox visualizer for debug mode
func _setup_hitbox_visualizer() -> void:
	# Create visualizer instance
	hitbox_visualizer = HitboxVisualizer.new()
	hitbox_visualizer.name = "HitboxVisualizer"
	add_child(hitbox_visualizer)

	# Auto-track all hitboxes and hurtboxes
	hitbox_visualizer.auto_track_parent()
