extends Node
## Manages game save/load with atomic writes and backup system.

# =============================================================================
# CONSTANTS
# =============================================================================

const SAVE_PATH: String = "user://save.dat"
const BACKUP_PATH: String = "user://save.dat.bak"
const SAVE_VERSION: int = 3

# =============================================================================
# STATE VARIABLES
# =============================================================================

## Pending data for player after zone loads
var _pending_level: int = 1
var _pending_exp: int = 0

# =============================================================================
# PUBLIC API
# =============================================================================

## Check if a save file exists
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(BACKUP_PATH)

## Save current game state
func save_game() -> bool:
	var data = _gather_save_data()
	return _write_save_file(data)

## Load game state (returns true if successful)
func load_game() -> bool:
	var data = _read_save_file()
	if data.is_empty():
		return false
	return _apply_save_data(data)

## Delete save file (for new game)
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	if FileAccess.file_exists(BACKUP_PATH):
		DirAccess.remove_absolute(BACKUP_PATH)

## Get save data without applying (for display)
func get_save_info() -> Dictionary:
	return _read_save_file()

# =============================================================================
# PRIVATE METHODS — SAVE DATA STRUCTURE
# =============================================================================

## Default save data (fresh game)
func _get_default_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"level": 1,
		"total_exp": 0,
		"coins": 0,
		"current_zone": "neighborhood",
		"boss_defeated": false,
		"mini_bosses_defeated": {
			"alpha_raccoon": false,
			"crow_matriarch": false,
			"rat_king": false,
		},
		"equipment": {},
		"inventory": {},
		"party": {},
		"timestamp": Time.get_unix_time_from_system()
	}

# =============================================================================
# PRIVATE METHODS — DATA GATHERING
# =============================================================================

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

	# Get sub-system state (helpers already exist on each manager)
	data.equipment = GameManager.equipment_manager.get_save_data()
	data.inventory = GameManager.inventory.get_save_data()
	data.party = GameManager.party_manager.get_save_data()

	data.timestamp = Time.get_unix_time_from_system()

	return data

# =============================================================================
# PRIVATE METHODS — DATA APPLICATION
# =============================================================================

func _apply_save_data(data: Dictionary) -> bool:
	# Validate version
	if not data.has("version") or data.version > SAVE_VERSION:
		push_error("SaveManager: Incompatible save version")
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
		GameManager.equipment_manager.load_save_data(equipment_data)

	var inventory_data = data.get("inventory", {})
	if not inventory_data.is_empty():
		GameManager.inventory.load_save_data(inventory_data)

	var party_data = data.get("party", {})
	if not party_data.is_empty():
		GameManager.party_manager.load_save_data(party_data)

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
		push_error("SaveManager: Failed to open temp file for writing")
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
		push_error("SaveManager: Failed to open save file for reading")
		return {}

	var json_string = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("SaveManager: Failed to parse save file - corrupt data")
		Events.save_corrupted.emit()
		return {}

	var data = json.get_data()
	if not data is Dictionary:
		push_error("SaveManager: Save file format invalid")
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
			push_error("SaveManager: Missing required field: " + field)
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
	if player and player.progression:
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
