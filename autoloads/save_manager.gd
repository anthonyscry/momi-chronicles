extends Node
class_name SaveManager
## Manages game save/load operations.
## Coordinates data collection from various managers and persists to JSON file.

# =============================================================================
# CONFIGURATION
# =============================================================================

const SAVE_FILE_PATH = "user://save_data.json"

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	DebugLogger.log_system("SaveManager initialized")

# =============================================================================
# SAVE OPERATIONS
# =============================================================================

## Collect all save data from game managers and return as Dictionary
func get_save_data() -> Dictionary:
	var save_data = {}

	# Tutorial progress
	if TutorialManager:
		save_data["tutorial"] = TutorialManager.get_save_data()

	# TODO: Add other manager data as needed
	# save_data["player"] = PlayerManager.get_save_data()
	# save_data["inventory"] = InventoryManager.get_save_data()
	# save_data["quests"] = QuestManager.get_save_data()

	DebugLogger.log_system("Save data collected")
	return save_data

## Save game data to file
func save_game() -> bool:
	var save_data = get_save_data()

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		DebugLogger.log_error("Failed to open save file for writing: %s" % SAVE_FILE_PATH)
		return false

	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()

	DebugLogger.log_system("Game saved to: %s" % SAVE_FILE_PATH)
	Events.game_saved.emit()
	return true

# =============================================================================
# LOAD OPERATIONS
# =============================================================================

## Load game data from file and distribute to managers
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		DebugLogger.log_warning("Save file does not exist: %s" % SAVE_FILE_PATH)
		return false

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		DebugLogger.log_error("Failed to open save file for reading: %s" % SAVE_FILE_PATH)
		return false

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		DebugLogger.log_error("Failed to parse save file JSON")
		return false

	var save_data = json.data
	if typeof(save_data) != TYPE_DICTIONARY:
		DebugLogger.log_error("Save data is not a dictionary")
		return false

	load_save_data(save_data)
	return true

## Distribute save data to appropriate managers
func load_save_data(data: Dictionary) -> void:
	# Tutorial progress
	if data.has("tutorial") and TutorialManager:
		TutorialManager.load_save_data(data["tutorial"])

	# TODO: Add other manager loading as needed
	# if data.has("player") and PlayerManager:
	#     PlayerManager.load_save_data(data["player"])
	# if data.has("inventory") and InventoryManager:
	#     InventoryManager.load_save_data(data["inventory"])

	DebugLogger.log_system("Save data loaded and distributed to managers")
	Events.game_loaded.emit()

# =============================================================================
# UTILITY
# =============================================================================

## Check if a save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

## Delete the save file
func delete_save() -> bool:
	if not has_save_file():
		return false

	var dir = DirAccess.open("user://")
	if dir == null:
		DebugLogger.log_error("Failed to access user directory")
		return false

	var result = dir.remove(SAVE_FILE_PATH.get_file())
	if result == OK:
		DebugLogger.log_system("Save file deleted")
		return true
	else:
		DebugLogger.log_error("Failed to delete save file")
		return false
