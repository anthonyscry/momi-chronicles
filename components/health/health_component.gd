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

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	current_health = max_health

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
# PRIVATE METHODS
# =============================================================================

func _die() -> void:
	if _is_dead:
		return
	
	_is_dead = true
	died.emit()
	
	if emit_global_events:
		Events.player_died.emit()
