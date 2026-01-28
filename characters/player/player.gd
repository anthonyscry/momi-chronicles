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
	
	# Connect to level up for stat scaling
	if progression:
		progression.level_changed.connect(_on_level_changed)
	
	# Apply initial stats
	_apply_level_stats()

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
	
	if health:
		health.take_damage(damage)
	if health and not health.is_dead():
		# Only transition to Hurt if not blocking
		if not is_blocking():
			state_machine.transition_to("Hurt")

func _on_died() -> void:
	state_machine.transition_to("Death")

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
func _on_level_changed(new_level: int) -> void:
	_apply_level_stats()

## Apply stats based on current level
func _apply_level_stats() -> void:
	if not progression:
		return
	
	# Update health
	var health_bonus = progression.get_stat_bonus("max_health")
	if health:
		var new_max = BASE_MAX_HEALTH + health_bonus
		var heal_amount = new_max - health.max_health  # Heal the difference
		health.max_health = new_max
		if heal_amount > 0:
			health.heal(heal_amount)  # Full heal on level up
	
	# Update attack damage
	var damage_bonus = progression.get_stat_bonus("attack_damage")
	if hitbox:
		hitbox.damage = BASE_ATTACK_DAMAGE + damage_bonus
	
	# Emit for UI
	Events.stats_updated.emit("all", progression.get_level())

## Get effective walk speed (with level bonus)
func get_effective_walk_speed() -> float:
	var bonus = 0
	if progression:
		bonus = progression.get_stat_bonus("move_speed")
	return BASE_WALK_SPEED + bonus

## Get effective run speed (with level bonus)
func get_effective_run_speed() -> float:
	var bonus = 0
	if progression:
		bonus = progression.get_stat_bonus("move_speed")
	return BASE_RUN_SPEED + bonus * 1.5  # Run gets bigger bonus

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
