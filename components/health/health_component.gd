extends Node
class_name HealthComponent
## Manages health points for any entity. Emits signals for UI and game logic.

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when health changes (for UI updates)
signal health_changed(current_health: int, max_health: int)

## Emitted when damage is taken (for effects, sounds)
signal damage_taken(amount: int)

## Emitted when healed
signal healed(amount: int)

## Emitted when health reaches zero
signal died

## Emitted when poison is applied
signal poison_started

## Emitted when poison wears off
signal poison_ended

# =============================================================================
# CONFIGURATION
# =============================================================================

## Maximum health points
@export var max_health: int = 100

## Whether to emit global events (for player)
@export var emit_global_events: bool = false

# =============================================================================
# STATE
# =============================================================================

## Current health points
var current_health: int

## Whether already dead (prevents multiple death triggers)
var _is_dead: bool = false

## Poison damage-over-time state
var is_poisoned: bool = false
var poison_damage: int = 0
var poison_tick_interval: float = 0.5
var poison_remaining: float = 0.0
var _poison_tick_timer: float = 0.0
var poison_stack_count: int = 0

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	current_health = max_health


func _process(delta: float) -> void:
	if not is_poisoned:
		return
	
	_poison_tick_timer += delta
	if _poison_tick_timer >= poison_tick_interval:
		_poison_tick_timer -= poison_tick_interval
		take_damage(poison_damage)
	
	poison_remaining -= delta
	if poison_remaining <= 0.0:
		clear_poison()

# =============================================================================
# PUBLIC METHODS
# =============================================================================

## Take damage, reducing health
func take_damage(amount: int) -> void:
	if _is_dead:
		return
	
	var actual_damage = mini(amount, current_health)
	current_health -= actual_damage
	
	damage_taken.emit(actual_damage)
	health_changed.emit(current_health, max_health)
	
	if emit_global_events:
		Events.player_damaged.emit(actual_damage)
		Events.player_health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		_die()

## Heal, increasing health up to max
func heal(amount: int) -> void:
	if _is_dead:
		return
	
	var actual_heal = mini(amount, max_health - current_health)
	current_health += actual_heal
	
	healed.emit(actual_heal)
	health_changed.emit(current_health, max_health)
	
	if emit_global_events:
		Events.player_healed.emit(actual_heal)
		Events.player_health_changed.emit(current_health, max_health)

## Set health to a specific value
func set_health(value: int) -> void:
	current_health = clampi(value, 0, max_health)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0 and not _is_dead:
		_die()

## Reset health to max
func reset() -> void:
	_is_dead = false
	current_health = max_health
	health_changed.emit(current_health, max_health)

## Check if dead
func is_dead() -> bool:
	return _is_dead

## Get health as percentage (0.0 to 1.0)
func get_health_percent() -> float:
	return float(current_health) / float(max_health)


## Get current health value
func get_current_health() -> int:
	return current_health


## Get maximum health value
func get_max_health() -> int:
	return max_health

# =============================================================================
# POISON METHODS
# =============================================================================

## Apply poison damage-over-time. Stacks: strongest damage, longest duration, escalating visual.
func apply_poison(damage_per_tick: int, duration: float) -> void:
	# Stack: use highest damage, refresh duration, track count
	poison_damage = maxi(poison_damage, damage_per_tick)
	poison_remaining = maxf(poison_remaining, duration)
	_poison_tick_timer = 0.0
	poison_stack_count += 1
	
	if not is_poisoned:
		is_poisoned = true
		poison_started.emit()
	
	# Escalate visual — deeper green with more stacks
	_update_poison_visual()


func _update_poison_visual() -> void:
	var parent = get_parent()
	if not parent:
		return
	var sprite = parent.get_node_or_null("Sprite2D")
	if not sprite:
		return
	# Deeper green per stack: 0.7 -> 0.55 -> 0.4 -> 0.3 (clamped)
	var green_intensity = clampf(0.7 - (poison_stack_count - 1) * 0.15, 0.3, 0.7)
	sprite.modulate = Color(green_intensity, 1.0, green_intensity)


## Remove poison status and restore visuals.
func clear_poison() -> void:
	is_poisoned = false
	poison_damage = 0
	poison_remaining = 0.0
	_poison_tick_timer = 0.0
	poison_stack_count = 0
	poison_ended.emit()
	# Restore sprite modulate
	var parent = get_parent()
	if parent:
		var sprite = parent.get_node_or_null("Sprite2D")
		if sprite:
			sprite.modulate = Color.WHITE

# =============================================================================
# PRIVATE METHODS
# =============================================================================

func _die() -> void:
	if _is_dead:
		return
	
	_is_dead = true
	died.emit()
	
	if emit_global_events:
		Events.player_died.emit()
