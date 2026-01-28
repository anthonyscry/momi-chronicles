extends Node
class_name ProgressionComponent
## Manages EXP, levels, and stat scaling for player.
## Listens to enemy_defeated to automatically grant EXP.

# =============================================================================
# SIGNALS
# =============================================================================

signal exp_changed(current_exp: int, exp_to_next: int)
signal level_changed(new_level: int)

# =============================================================================
# CONFIGURATION
# =============================================================================

## Starting level
const START_LEVEL: int = 1

## Maximum level
const MAX_LEVEL: int = 20

## Base EXP needed for level 2
const BASE_EXP: int = 100

## EXP scaling factor per level (exponential curve)
const EXP_SCALE: float = 1.5

## Stat increases per level
const STATS_PER_LEVEL = {
	"max_health": 10,      # +10 HP per level
	"attack_damage": 3,    # +3 damage per level
	"move_speed": 2        # +2 speed per level
}

# =============================================================================
# STATE
# =============================================================================

var current_level: int = START_LEVEL
var current_exp: int = 0
var total_exp: int = 0  # Lifetime EXP earned

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	Events.enemy_defeated.connect(_on_enemy_defeated)

# =============================================================================
# PUBLIC METHODS
# =============================================================================

## Get EXP required to reach next level from current level
func get_exp_for_level(level: int) -> int:
	if level <= 1:
		return 0
	# Exponential curve: BASE_EXP * (SCALE ^ (level - 2))
	return int(BASE_EXP * pow(EXP_SCALE, level - 2))

## Get total EXP needed from level 1 to target level
func get_total_exp_for_level(level: int) -> int:
	var total = 0
	for i in range(2, level + 1):
		total += get_exp_for_level(i)
	return total

## Get EXP needed for current level to next
func get_exp_to_next_level() -> int:
	if current_level >= MAX_LEVEL:
		return 0
	return get_exp_for_level(current_level + 1)

## Get EXP progress within current level (0 to exp_to_next)
func get_exp_progress() -> int:
	var exp_for_current = get_total_exp_for_level(current_level)
	return total_exp - exp_for_current

## Add EXP and check for level up
func add_exp(amount: int) -> void:
	if current_level >= MAX_LEVEL:
		return
	
	current_exp += amount
	total_exp += amount
	
	# Check for level up(s) - may level up multiple times from one kill
	while current_exp >= get_exp_to_next_level() and current_level < MAX_LEVEL:
		current_exp -= get_exp_to_next_level()
		_level_up()
	
	exp_changed.emit(get_exp_progress(), get_exp_to_next_level())
	Events.exp_gained.emit(amount, current_level, get_exp_progress(), get_exp_to_next_level())

## Get stat bonus for current level
func get_stat_bonus(stat_name: String) -> int:
	if not STATS_PER_LEVEL.has(stat_name):
		return 0
	return STATS_PER_LEVEL[stat_name] * (current_level - 1)

## Get current level
func get_level() -> int:
	return current_level

## Reset progression (for new game)
func reset() -> void:
	current_level = START_LEVEL
	current_exp = 0
	total_exp = 0
	exp_changed.emit(0, get_exp_to_next_level())
	level_changed.emit(current_level)

# =============================================================================
# PRIVATE METHODS
# =============================================================================

func _level_up() -> void:
	current_level += 1
	level_changed.emit(current_level)
	Events.player_leveled_up.emit(current_level)
	print("[Progression] Level up! Now level ", current_level)

func _on_enemy_defeated(enemy: Node) -> void:
	# Get EXP value from enemy (defaults to 10 if not set)
	var exp_value = 10
	if enemy and enemy.get("exp_value") != null:
		exp_value = enemy.exp_value
	add_exp(exp_value)
