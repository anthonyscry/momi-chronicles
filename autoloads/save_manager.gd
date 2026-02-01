extends Node
class_name SaveManager
## Manages game save/load operations.
## Coordinates data collection from various managers and persists to JSON file.

# ======================================================================# CONSTANTS
# =============================================================================

const SAVE_FILE_PATH = "user://save_data.json"

# =============================================================================
# STATE VARIABLES
# ======================================================================
## Pending data for player after zone loads
var _pending_level: int = 1
var _pending_exp: int = 0
=======
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


## Load game state (returns true if successful)
func load_game() -> bool:
	var data = _read_save_file()
	if data.is_empty():
		DebugLogger.log_error("SaveManager: load_game failed — no valid save data found")
		return false
	var success = _apply_save_data(data)
	if not success:
		DebugLogger.log_error("SaveManager: load_game failed — could not apply save data")
	return success

## Delete save file (for new game)
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	if FileAccess.file_exists(BACKUP_PATH):
		DirAccess.remove_absolute(BACKUP_PATH)

## Get save data without applying (for display)
func get_save_info() -> Dictionary:
	return _read_save_file()

# ======================================================================# PRIVATE METHODS — SAVE DATA STRUCTURE
=======
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	DebugLogger.log_system("SaveManager initialized")

# =============================================================================
# PRIVATE METHODS — DATA GATHERING
# ======================================================================
func _gather_save_data() -> Dictionary:
	var data = _get_default_data()

	# Get player progression
	var player = get_tree().get_first_node_in_group("player")
	if player and player.progression:
		data.level = player.progression.current_level
		data.total_exp = player.progression.total_exp

	# Get global state from GameManager
	data.coins = GameManager.coins
	data.current_zone = GameManager.current_zone if GameManager.current_zone != "" else "neighborhood"
	data.boss_defeated = GameManager.boss_defeated
	data.mini_bosses_defeated = GameManager.mini_bosses_defeated.duplicate()

	# Get sub-system state (with null safety for Phase 16 managers)
	if GameManager.equipment_manager and is_instance_valid(GameManager.equipment_manager):
		data.equipment = GameManager.equipment_manager.get_save_data()
	else:
		DebugLogger.log_error("SaveManager: equipment_manager not valid during save")

	if GameManager.inventory and is_instance_valid(GameManager.inventory):
		data.inventory = GameManager.inventory.get_save_data()
	else:
		DebugLogger.log_error("SaveManager: inventory not valid during save")

	if GameManager.party_manager and is_instance_valid(GameManager.party_manager):
		data.party = GameManager.party_manager.get_save_data()
	else:
		DebugLogger.log_error("SaveManager: party_manager not valid during save")

	data.timestamp = Time.get_unix_time_from_system()

	return data

# =============================================================================
# PRIVATE METHODS — DATA APPLICATION
# =============================================================================

func _apply_save_data(data: Dictionary) -> bool:
	# Validate version
	if not data.has("version") or data.version > SAVE_VERSION:
		DebugLogger.log_error("SaveManager: Incompatible save version (got %s, max %d)" % [str(data.get("version", "missing")), SAVE_VERSION])
		return false

	# Apply to GameManager
	GameManager.coins = data.get("coins", 0)
	GameManager.boss_defeated = data.get("boss_defeated", false)

	# Version migration: add mini_bosses_defeated for v1 saves
	GameManager.mini_bosses_defeated = data.get("mini_bosses_defeated", {
		"alpha_raccoon": false,
		"crow_matriarch": false,
		"rat_king": false,
	})

	# Restore sub-system state (v3+, graceful fallback for v2 saves)
	var equipment_data = data.get("equipment", {})
	if not equipment_data.is_empty():
		if GameManager.equipment_manager and is_instance_valid(GameManager.equipment_manager):
			GameManager.equipment_manager.load_save_data(equipment_data)
		else:
			DebugLogger.log_error("SaveManager: equipment_manager not valid during load")

	var inventory_data = data.get("inventory", {})
	if not inventory_data.is_empty():
		if GameManager.inventory and is_instance_valid(GameManager.inventory):
			GameManager.inventory.load_save_data(inventory_data)
		else:
			DebugLogger.log_error("SaveManager: inventory not valid during load")

	var party_data = data.get("party", {})
	if not party_data.is_empty():
		if GameManager.party_manager and is_instance_valid(GameManager.party_manager):
			GameManager.party_manager.load_save_data(party_data)
		else:
			DebugLogger.log_error("SaveManager: party_manager not valid during load")

	# Store zone for transition (GameManager handles zone loading)
	var target_zone = data.get("current_zone", "neighborhood")

	# Store level/exp for player to pick up after zone loads
	_pending_level = data.get("level", 1)
	_pending_exp = data.get("total_exp", 0)

	# Connect to zone_entered to apply progression after player spawns
	if not Events.zone_entered.is_connected(_on_zone_entered_after_load):
		Events.zone_entered.connect(_on_zone_entered_after_load, CONNECT_ONE_SHOT)

	# Load the zone
	GameManager.load_zone(target_zone, "default")

	Events.game_loaded.emit()
	return true

# =============================================================================
# PRIVATE METHODS — FILE I/O (Atomic Write with Backup)
# =============================================================================

func _write_save_file(data: Dictionary) -> bool:
	# Create backup of existing save first
	if FileAccess.file_exists(SAVE_PATH):
		if FileAccess.file_exists(BACKUP_PATH):
			DirAccess.remove_absolute(BACKUP_PATH)
		DirAccess.copy_absolute(SAVE_PATH, BACKUP_PATH)

	# Write to temp file first (atomic write pattern)
	var temp_path = SAVE_PATH + ".tmp"
	var file = FileAccess.open(temp_path, FileAccess.WRITE)
	if not file:
		DebugLogger.log_error("SaveManager: Failed to open temp file for writing: %s" % temp_path)
		return false

	var json_string = JSON.stringify(data, "  ")
	file.store_string(json_string)
	file.close()

	# Move temp to actual save path (atomic)
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	DirAccess.rename_absolute(temp_path, SAVE_PATH)

	Events.game_saved.emit()
	DebugLogger.log_save("Game saved successfully")
	return true

func _read_save_file() -> Dictionary:
	var file_path = SAVE_PATH

	# Try main save first
	if not FileAccess.file_exists(file_path):
		# Try backup
		if FileAccess.file_exists(BACKUP_PATH):
			file_path = BACKUP_PATH
			DebugLogger.log_save("Using backup save file")
		else:
			return {}

	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		DebugLogger.log_error("SaveManager: Failed to open save file for reading: %s" % file_path)
		return {}

	var json_string = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		DebugLogger.log_error("SaveManager: Failed to parse save file — corrupt data at %s" % file_path)
		Events.save_corrupted.emit()
		return {}

	var data = json.get_data()
	if not data is Dictionary:
		DebugLogger.log_error("SaveManager: Save file format invalid — expected Dictionary at %s" % file_path)
		Events.save_corrupted.emit()
		return {}

	# Validate required fields
	if not _validate_save_data(data):
		Events.save_corrupted.emit()
		return {}

	return data

func _validate_save_data(data: Dictionary) -> bool:
	var required_fields = ["version", "level", "total_exp", "coins", "current_zone"]
	for field in required_fields:
		if not data.has(field):
			DebugLogger.log_error("SaveManager: Missing required field: " + field)
			return false
	return true

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_zone_entered_after_load(_zone_name: String) -> void:
	# Apply progression to player after spawn
	await get_tree().process_frame  # Wait for player to initialize
	await get_tree().process_frame  # Extra frame for safety

	var player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player):
		DebugLogger.log_error("SaveManager: Player not found after load — progression not restored")
		return
	if not player.progression:
		DebugLogger.log_error("SaveManager: Player has no progression component — progression not restored")
		return

	player.progression.current_level = _pending_level
	player.progression.total_exp = _pending_exp
	player.progression.current_exp = player.progression.get_exp_progress()
	player._apply_level_stats()

	# Emit signals so UI updates
	player.progression.level_changed.emit(_pending_level)
	player.progression.exp_changed.emit(
		player.progression.get_exp_progress(),
		player.progression.get_exp_to_next_level()
	)
	DebugLogger.log_save("Game loaded — level %d, exp %d restored" % [_pending_level, _pending_exp])
=======
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
=======
## Delete the save file
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		DebugLogger.log_system("Save file deleted")
