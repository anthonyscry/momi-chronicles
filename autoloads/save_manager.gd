extends Node
class_name SaveManager
## Singleton managing save/load operations for game state persistence.
## Uses ConfigFile to save to user://save_data.cfg and emits Events signals.

## Save file path
const SAVE_PATH = "user://save_data.cfg"

## ConfigFile instance
var config: ConfigFile = ConfigFile.new()


func _ready() -> void:
	DebugLogger.log_system("SaveManager initialized")


## Save current game state to disk
func save_game() -> void:
	# Collect data from GameManager
	var game_data = GameManager.save_game()

	# Save GameManager data
	config.set_value("game", "coins", game_data.get("coins", 0))
	config.set_value("game", "current_zone", game_data.get("current_zone", ""))

	if game_data.has("player_position"):
		var pos = game_data["player_position"]
		config.set_value("game", "player_x", pos.get("x", 0.0))
		config.set_value("game", "player_y", pos.get("y", 0.0))

	# Save current difficulty
	config.set_value("game", "difficulty", DifficultyManager.get_difficulty())

	# Write to disk
	var error = config.save(SAVE_PATH)
	if error != OK:
		DebugLogger.log_system("Failed to save game: Error %d" % error)
		return

	DebugLogger.log_system("Game saved successfully to %s" % SAVE_PATH)
	Events.game_saved.emit()


## Load game state from disk
func load_game() -> bool:
	# Check if save file exists
	if not FileAccess.file_exists(SAVE_PATH):
		DebugLogger.log_system("No save file found at %s" % SAVE_PATH)
		return false

	# Load config file
	var error = config.load(SAVE_PATH)
	if error != OK:
		DebugLogger.log_system("Failed to load save file: Error %d" % error)
		return false

	# Restore difficulty first (before loading other data that might depend on it)
	if config.has_section_key("game", "difficulty"):
		var difficulty = config.get_value("game", "difficulty", DifficultySettings.Difficulty.NORMAL)
		DifficultyManager.set_difficulty(difficulty)

	# Restore GameManager state
	var save_data = {
		"coins": config.get_value("game", "coins", 0),
		"current_zone": config.get_value("game", "current_zone", ""),
		"player_position": {
			"x": config.get_value("game", "player_x", 0.0),
			"y": config.get_value("game", "player_y", 0.0)
		}
	}

	GameManager.load_game(save_data)

	DebugLogger.log_system("Game loaded successfully from %s" % SAVE_PATH)
	Events.game_loaded.emit()

	return true


## Check if a save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


## Delete the save file
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		DebugLogger.log_system("Save file deleted")
