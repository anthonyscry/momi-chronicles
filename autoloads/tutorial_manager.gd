extends Node
class_name TutorialManager
## Manages tutorial state tracking and completion for gameplay-integrated onboarding.
## Tracks which tutorials have been shown, completed, and whether tutorials are enabled.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Tutorial IDs for all core mechanics
const TUTORIAL_MOVEMENT = "movement"
const TUTORIAL_ATTACK = "attack"
const TUTORIAL_SPECIAL_ATTACK = "special_attack"
const TUTORIAL_DODGE = "dodge"
const TUTORIAL_BLOCK = "block"
const TUTORIAL_COMBO = "combo"
const TUTORIAL_RING_MENU = "ring_menu"
const TUTORIAL_ITEM_USAGE = "item_usage"
const TUTORIAL_COMPANION_SWAP = "companion_swap"

## Number of successful demonstrations required to complete tutorials
const REQUIRED_DEMONSTRATIONS = 3

# =============================================================================
# STATE
# =============================================================================

## Whether tutorials are enabled (can be toggled by player)
var tutorial_enabled: bool = true

## Tracks which tutorials have been shown at least once
var tutorials_shown: Dictionary = {}

## Tracks which tutorials have been completed
var tutorials_completed: Dictionary = {}

## Tracks action counts for tutorials requiring multiple demonstrations
var action_counts: Dictionary = {}

## Movement tutorial tracking
var movement_tutorial_triggered: bool = false
var movement_time: float = 0.0
const MOVEMENT_TUTORIAL_DURATION: float = 3.0
var ready_timer: float = 0.0
const READY_DELAY: float = 0.5  # Wait for player to spawn

## Combat tutorial tracking
var attack_tutorial_triggered: bool = false
var defensive_tutorials_triggered: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_initialize_tutorial_state()
	_connect_event_signals()
	DebugLogger.log_system("TutorialManager initialized")

func _process(delta: float) -> void:
	_check_movement_tutorial(delta)

# =============================================================================
# INITIALIZATION
# =============================================================================

func _initialize_tutorial_state() -> void:
	## Initialize all tutorial tracking dictionaries
	var all_tutorials = [
		TUTORIAL_MOVEMENT,
		TUTORIAL_ATTACK,
		TUTORIAL_SPECIAL_ATTACK,
		TUTORIAL_DODGE,
		TUTORIAL_BLOCK,
		TUTORIAL_COMBO,
		TUTORIAL_RING_MENU,
		TUTORIAL_ITEM_USAGE,
		TUTORIAL_COMPANION_SWAP
	]

	for tutorial_id in all_tutorials:
		if not tutorials_shown.has(tutorial_id):
			tutorials_shown[tutorial_id] = false
		if not tutorials_completed.has(tutorial_id):
			tutorials_completed[tutorial_id] = false
		if not action_counts.has(tutorial_id):
			action_counts[tutorial_id] = 0

func _connect_event_signals() -> void:
	## Connect to game events to track player actions for tutorials
	Events.player_attacked.connect(_on_player_attacked)
	Events.player_dodged.connect(_on_player_dodged)
	Events.player_blocked.connect(_on_player_blocked)
	Events.player_damaged.connect(_on_player_damaged)
	Events.combo_changed.connect(_on_combo_changed)
	Events.combo_completed.connect(_on_combo_completed)
	Events.ring_menu_opened.connect(_on_ring_menu_opened)
	Events.item_used.connect(_on_item_used)
	Events.pickup_collected.connect(_on_pickup_collected)
	Events.enemy_spawned.connect(_on_enemy_spawned)

# =============================================================================
# EVENT HANDLERS
# =============================================================================

func _on_player_attacked() -> void:
	## Track attack actions for attack tutorial
	if should_show_tutorial(TUTORIAL_ATTACK):
		Events.tutorial_triggered.emit(TUTORIAL_ATTACK)
		mark_tutorial_shown(TUTORIAL_ATTACK)
	increment_action_count(TUTORIAL_ATTACK)

func _on_player_dodged() -> void:
	## Track dodge actions for dodge tutorial
	if should_show_tutorial(TUTORIAL_DODGE):
		Events.tutorial_triggered.emit(TUTORIAL_DODGE)
		mark_tutorial_shown(TUTORIAL_DODGE)
	increment_action_count(TUTORIAL_DODGE)

func _on_player_blocked() -> void:
	## Track block actions for block tutorial
	if should_show_tutorial(TUTORIAL_BLOCK):
		Events.tutorial_triggered.emit(TUTORIAL_BLOCK)
		mark_tutorial_shown(TUTORIAL_BLOCK)
	increment_action_count(TUTORIAL_BLOCK)

func _on_combo_changed(count: int) -> void:
	## Trigger combo tutorial when player lands 2 attacks in succession
	# Only show combo tutorial if attack tutorial is already completed
	if count >= 2 and is_tutorial_completed(TUTORIAL_ATTACK) and should_show_tutorial(TUTORIAL_COMBO):
		Events.tutorial_triggered.emit(TUTORIAL_COMBO)
		mark_tutorial_shown(TUTORIAL_COMBO)
		DebugLogger.log_system("Combo tutorial triggered on combo count: %d" % count)

func _on_combo_completed(count: int) -> void:
	## Track combo completions for combo tutorial
	# Only increment count if tutorial has been shown
	if tutorials_shown.get(TUTORIAL_COMBO, false) and not is_tutorial_completed(TUTORIAL_COMBO):
		action_counts[TUTORIAL_COMBO] = action_counts.get(TUTORIAL_COMBO, 0) + 1

		# Complete after 2 successful combos (not the default 3)
		if action_counts[TUTORIAL_COMBO] >= 2:
			mark_tutorial_completed(TUTORIAL_COMBO)
			DebugLogger.log_system("Combo tutorial completed after %d combos" % action_counts[TUTORIAL_COMBO])

func _on_ring_menu_opened() -> void:
	## Track ring menu opening for ring menu tutorial
	# Complete ring menu tutorial when opened
	if should_show_tutorial(TUTORIAL_RING_MENU):
		Events.tutorial_triggered.emit(TUTORIAL_RING_MENU)
		mark_tutorial_shown(TUTORIAL_RING_MENU)
		mark_tutorial_completed(TUTORIAL_RING_MENU)
	elif not is_tutorial_completed(TUTORIAL_RING_MENU):
		mark_tutorial_completed(TUTORIAL_RING_MENU)

	# Trigger item usage tutorial when ring menu is opened for the first time
	if should_show_tutorial(TUTORIAL_ITEM_USAGE):
		Events.tutorial_triggered.emit(TUTORIAL_ITEM_USAGE)
		mark_tutorial_shown(TUTORIAL_ITEM_USAGE)
		DebugLogger.log_system("Item usage tutorial triggered on ring menu open")

func _on_item_used(item_id: String) -> void:
	## Track item usage for item usage tutorial
	# Complete item usage tutorial after first use
	if tutorials_shown.get(TUTORIAL_ITEM_USAGE, false) and not is_tutorial_completed(TUTORIAL_ITEM_USAGE):
		mark_tutorial_completed(TUTORIAL_ITEM_USAGE)
		DebugLogger.log_system("Item usage tutorial completed after first item use: %s" % item_id)

func _on_pickup_collected(item_id: String) -> void:
	## Track item pickups to potentially trigger ring menu tutorial
	# Ring menu tutorial triggers on first consumable item pickup
	if should_show_tutorial(TUTORIAL_RING_MENU):
		Events.tutorial_triggered.emit(TUTORIAL_RING_MENU)
		mark_tutorial_shown(TUTORIAL_RING_MENU)
		DebugLogger.log_system("Ring menu tutorial triggered on item pickup: %s" % item_id)

func _on_enemy_spawned(enemy_id: String) -> void:
	## Trigger attack tutorial on first enemy encounter
	if not attack_tutorial_triggered and should_show_tutorial(TUTORIAL_ATTACK):
		Events.tutorial_triggered.emit(TUTORIAL_ATTACK)
		mark_tutorial_shown(TUTORIAL_ATTACK)
		attack_tutorial_triggered = true
		DebugLogger.log_system("Attack tutorial triggered on enemy spawn: %s" % enemy_id)

func _on_player_damaged() -> void:
	## Trigger dodge and block tutorials when player takes damage for the first time
	if not defensive_tutorials_triggered:
		# Trigger dodge tutorial
		if should_show_tutorial(TUTORIAL_DODGE):
			Events.tutorial_triggered.emit(TUTORIAL_DODGE)
			mark_tutorial_shown(TUTORIAL_DODGE)
			DebugLogger.log_system("Dodge tutorial triggered on player damage")

		# Trigger block tutorial
		if should_show_tutorial(TUTORIAL_BLOCK):
			Events.tutorial_triggered.emit(TUTORIAL_BLOCK)
			mark_tutorial_shown(TUTORIAL_BLOCK)
			DebugLogger.log_system("Block tutorial triggered on player damage")

		defensive_tutorials_triggered = true

# =============================================================================
# MOVEMENT TUTORIAL LOGIC
# =============================================================================

func _check_movement_tutorial(delta: float) -> void:
	## Handle movement tutorial triggering and completion

	# Wait for initial delay before triggering tutorial (ensures player is spawned)
	if ready_timer < READY_DELAY:
		ready_timer += delta
		return

	# Trigger movement tutorial if not yet triggered and should be shown
	if not movement_tutorial_triggered and should_show_tutorial(TUTORIAL_MOVEMENT):
		Events.tutorial_triggered.emit(TUTORIAL_MOVEMENT)
		mark_tutorial_shown(TUTORIAL_MOVEMENT)
		movement_tutorial_triggered = true
		DebugLogger.log_system("Movement tutorial triggered")
		return

	# Skip if tutorial already completed
	if is_tutorial_completed(TUTORIAL_MOVEMENT):
		return

	# Track movement input
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_vector.length() > 0.1:  # Player is moving
		movement_time += delta

		# Complete tutorial after required movement duration
		if movement_time >= MOVEMENT_TUTORIAL_DURATION:
			mark_tutorial_completed(TUTORIAL_MOVEMENT)
			DebugLogger.log_system("Movement tutorial completed after %.1f seconds" % movement_time)

# =============================================================================
# PUBLIC API
# =============================================================================

## Check if a tutorial should be shown
func should_show_tutorial(tutorial_id: String) -> bool:
	if not tutorial_enabled:
		return false
	if tutorials_completed.get(tutorial_id, false):
		return false
	return true

## Mark a tutorial as shown
func mark_tutorial_shown(tutorial_id: String) -> void:
	tutorials_shown[tutorial_id] = true
	DebugLogger.log_system("Tutorial shown: %s" % tutorial_id)

## Mark a tutorial as completed
func mark_tutorial_completed(tutorial_id: String) -> void:
	tutorials_completed[tutorial_id] = true
	DebugLogger.log_system("Tutorial completed: %s" % tutorial_id)
	Events.tutorial_completed.emit(tutorial_id)

## Check if a tutorial has been completed
func is_tutorial_completed(tutorial_id: String) -> bool:
	return tutorials_completed.get(tutorial_id, false)

## Increment action count for a tutorial and check if complete
func increment_action_count(tutorial_id: String) -> void:
	action_counts[tutorial_id] = action_counts.get(tutorial_id, 0) + 1

	if action_counts[tutorial_id] >= REQUIRED_DEMONSTRATIONS:
		mark_tutorial_completed(tutorial_id)

## Get current action count for a tutorial
func get_action_count(tutorial_id: String) -> int:
	return action_counts.get(tutorial_id, 0)

## Enable or disable tutorials
func set_tutorials_enabled(enabled: bool) -> void:
	tutorial_enabled = enabled
	DebugLogger.log_system("Tutorials %s" % ("enabled" if enabled else "disabled"))

## Reset all tutorial progress (for testing or new game+)
func reset_all_tutorials() -> void:
	tutorials_shown.clear()
	tutorials_completed.clear()
	action_counts.clear()
	movement_tutorial_triggered = false
	movement_time = 0.0
	ready_timer = 0.0
	attack_tutorial_triggered = false
	defensive_tutorials_triggered = false
	_initialize_tutorial_state()
	DebugLogger.log_system("All tutorials reset")

## Get save data for persistence
func get_save_data() -> Dictionary:
	return {
		"tutorial_enabled": tutorial_enabled,
		"tutorials_shown": tutorials_shown.duplicate(),
		"tutorials_completed": tutorials_completed.duplicate(),
		"action_counts": action_counts.duplicate()
	}

## Load save data from persistence
func load_save_data(data: Dictionary) -> void:
	tutorial_enabled = data.get("tutorial_enabled", true)
	tutorials_shown = data.get("tutorials_shown", {})
	tutorials_completed = data.get("tutorials_completed", {})
	action_counts = data.get("action_counts", {})
	movement_tutorial_triggered = false
	movement_time = 0.0
	ready_timer = 0.0
	attack_tutorial_triggered = false
	defensive_tutorials_triggered = false
	_initialize_tutorial_state()
	DebugLogger.log_system("Tutorial progress loaded from save")
