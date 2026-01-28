extends Node
## Manages global game state including pause, current zone, and game flow.

# =============================================================================
# STATE
# =============================================================================

## Whether the game is currently paused
var is_paused: bool = false

## Name of the currently loaded zone
var current_zone: String = ""

## Whether player is alive
var is_player_alive: bool = true

## Currency system
var coins: int = 0

# =============================================================================
# LIFECYCLE
# =============================================================================

## Zone scene paths
var zone_scenes: Dictionary = {
	"neighborhood": "res://world/zones/neighborhood.tscn",
	"backyard": "res://world/zones/backyard.tscn",
	"boss_arena": "res://world/zones/boss_arena.tscn",
	"test_zone": "res://world/zones/test_zone.tscn"
}

## Track boss defeat for save state
var boss_defeated: bool = false

## Spawn point to use after zone transition
var pending_spawn_point: String = ""

func _ready() -> void:
	# Connect to player death for game over handling
	Events.player_died.connect(_on_player_died)
	Events.zone_entered.connect(_on_zone_entered)
	Events.zone_transition_requested.connect(_on_zone_transition_requested)
	Events.boss_defeated.connect(_on_boss_defeated)

func _on_boss_defeated(_boss: Node) -> void:
	boss_defeated = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

# =============================================================================
# PAUSE SYSTEM
# =============================================================================

## Toggle pause state
func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()

## Pause the game
func pause_game() -> void:
	if is_paused:
		return
	is_paused = true
	get_tree().paused = true
	Events.game_paused.emit()

## Resume the game
func resume_game() -> void:
	if not is_paused:
		return
	is_paused = false
	get_tree().paused = false
	Events.game_resumed.emit()

# =============================================================================
# GAME FLOW
# =============================================================================

## Handle player death
func _on_player_died() -> void:
	is_player_alive = false
	Events.game_over.emit()

## Track current zone
func _on_zone_entered(zone_name: String) -> void:
	current_zone = zone_name

## Restart the game (reload current scene)
func restart_game() -> void:
	is_player_alive = true
	is_paused = false
	get_tree().paused = false
	get_tree().reload_current_scene()
	Events.game_restarted.emit()

## Quit to desktop
func quit_game() -> void:
	get_tree().quit()

# =============================================================================
# ZONE TRANSITIONS
# =============================================================================

## Handle zone transition request
func _on_zone_transition_requested(target_zone: String, spawn_point: String) -> void:
	if not zone_scenes.has(target_zone):
		push_error("Unknown zone: " + target_zone)
		return
	
	pending_spawn_point = spawn_point
	Events.zone_exited.emit(current_zone)
	
	# Load the new zone
	var zone_path = zone_scenes[target_zone]
	get_tree().change_scene_to_file(zone_path)


## Load a specific zone
func load_zone(zone_name: String, spawn_point: String = "default") -> void:
	_on_zone_transition_requested(zone_name, spawn_point)


## Get the pending spawn point and clear it
func get_pending_spawn() -> String:
	var spawn = pending_spawn_point
	pending_spawn_point = ""
	return spawn


# =============================================================================
# CURRENCY SYSTEM
# =============================================================================

## Add coins to player's wallet
func add_coins(amount: int) -> void:
	coins += amount
	Events.coins_changed.emit(coins)


## Get current coin count
func get_coins() -> int:
	return coins


## Spend coins if player has enough
func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		Events.coins_changed.emit(coins)
		return true
	return false
