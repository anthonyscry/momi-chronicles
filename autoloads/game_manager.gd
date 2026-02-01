extends Node
class_name GameManager
## Central singleton managing global game state.
## Tracks coins, player position, current zone, and provides save/load hooks.

## Current coin count
var coins: int = 0

## Current zone/level name
var current_zone: String = ""

## Player's last saved position
var player_position: Vector2 = Vector2.ZERO

## Reference to party manager (set by party system when ready)
var party_manager = null


func _ready() -> void:
	DebugLogger.log_system("GameManager initialized")


## Get current coin count
func get_coins() -> int:
	return coins


## Add coins and emit change event
func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount
	Events.coins_changed.emit(coins)
	DebugLogger.log_system("Added %d coins, total: %d" % [amount, coins])


## Remove coins and emit change event
func remove_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins = max(0, coins - amount)
	Events.coins_changed.emit(coins)
	DebugLogger.log_system("Removed %d coins, total: %d" % [amount, coins])


## Set coins directly (used by save system)
func set_coins(amount: int) -> void:
	coins = max(0, amount)
	Events.coins_changed.emit(coins)


## Save game state to dictionary (called by SaveManager)
func save_game() -> Dictionary:
	var save_data = {
		"coins": coins,
		"current_zone": current_zone,
		"player_position": {
			"x": player_position.x,
			"y": player_position.y
		}
	}
	return save_data


## Load game state from dictionary (called by SaveManager)
func load_game(save_data: Dictionary) -> void:
	if save_data.has("coins"):
		coins = save_data["coins"]
		Events.coins_changed.emit(coins)

	if save_data.has("current_zone"):
		current_zone = save_data["current_zone"]

	if save_data.has("player_position"):
		var pos = save_data["player_position"]
		player_position = Vector2(pos["x"], pos["y"])

	DebugLogger.log_system("Game state loaded - Coins: %d, Zone: %s" % [coins, current_zone])


## Reset game to initial state (called when returning to title screen)
func reset_game() -> void:
	coins = 0
	current_zone = ""
	player_position = Vector2.ZERO
	party_manager = null
	DebugLogger.log_system("Game state reset")
