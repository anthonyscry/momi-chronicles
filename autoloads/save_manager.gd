extends Node
## SaveManager - handles save/load operations for game state.

# =============================================================================
# CONSTANTS
# =============================================================================

const SAVE_FILE_PATH = "user://save_data.json"
const BACKUP_PATH = "user://save_data.backup.json"
const SAVE_VERSION = 3

# =============================================================================
# STATE
# =============================================================================

var _pending_level: int = 1
var _pending_exp: int = 0

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	DebugLogger.log_system("SaveManager initialized")

# =============================================================================
# PUBLIC API
# =============================================================================

func save_exists() -> bool:
	return has_save_file()

func has_save() -> bool:
	return has_save_file()

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func delete_save() -> bool:
	var ok = true
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var err = DirAccess.remove_absolute(SAVE_FILE_PATH)
		if err != OK:
			DebugLogger.log_error("SaveManager: Failed to delete save file: %s" % str(err))
			ok = false
	if FileAccess.file_exists(BACKUP_PATH):
		var err_backup = DirAccess.remove_absolute(BACKUP_PATH)
		if err_backup != OK:
			DebugLogger.log_error("SaveManager: Failed to delete backup save file: %s" % str(err_backup))
			ok = false
	return ok

func save_game() -> bool:
	var data = _gather_save_data()
	return _write_save_file(data)

func load_game() -> bool:
	var data = _read_save_file()
	if data.is_empty():
		DebugLogger.log_error("SaveManager: load_game failed - no valid save data found")
		return false
	var success = _apply_save_data(data)
	if not success:
		DebugLogger.log_error("SaveManager: load_game failed - could not apply save data")
	return success

func get_save_info() -> Dictionary:
	return _read_save_file()

# =============================================================================
# PRIVATE METHODS - DATA
# =============================================================================

func _get_default_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"level": 1,
		"total_exp": 0,
		"coins": 0,
		"difficulty": 1,
		"current_zone": "neighborhood",
		"boss_defeated": false,
		"mini_bosses_defeated": {
			"alpha_raccoon": false,
			"crow_matriarch": false,
			"rat_king": false,
		},
		"unlocked_zones": [],
		"player_position": {"x": 0.0, "y": 0.0},
	}

func _gather_save_data() -> Dictionary:
	var data = _get_default_data()

	var game_data = GameManager.save_game()
	data["coins"] = game_data.get("coins", data["coins"])
	if DifficultyManager:
		data["difficulty"] = DifficultyManager.get_difficulty()
	data["current_zone"] = game_data.get("current_zone", data["current_zone"])
	data["player_position"] = game_data.get("player_position", data["player_position"])
	data["unlocked_zones"] = game_data.get("unlocked_zones", data["unlocked_zones"])
	data["npc_reputation"] = game_data.get("npc_reputation", {})

	data["boss_defeated"] = GameManager.boss_defeated
	data["mini_bosses_defeated"] = GameManager.mini_bosses_defeated.duplicate()

	var player = get_tree().get_first_node_in_group("player")
	if player and player.progression:
		data["level"] = player.progression.current_level
		data["total_exp"] = player.progression.total_exp

	if GameManager.equipment_manager and is_instance_valid(GameManager.equipment_manager):
		data["equipment"] = GameManager.equipment_manager.get_save_data()
	else:
		DebugLogger.log_error("SaveManager: equipment_manager not valid during save")

	if GameManager.inventory and is_instance_valid(GameManager.inventory):
		data["inventory"] = GameManager.inventory.get_save_data()
	else:
		DebugLogger.log_error("SaveManager: inventory not valid during save")

	if GameManager.party_manager and is_instance_valid(GameManager.party_manager):
		data["party"] = GameManager.party_manager.get_save_data()
	else:
		DebugLogger.log_error("SaveManager: party_manager not valid during save")

	if TutorialManager:
		data["tutorial"] = TutorialManager.get_save_data()

	data["timestamp"] = Time.get_unix_time_from_system()

	return data

func _apply_save_data(data: Dictionary) -> bool:
	var version = data.get("version", 1)
	if version > SAVE_VERSION:
		DebugLogger.log_error("SaveManager: Incompatible save version (got %s, max %d)" % [str(version), SAVE_VERSION])
		return false

	if data.has("difficulty") and DifficultyManager:
		DifficultyManager.set_difficulty(data["difficulty"])

	GameManager.set_coins(data.get("coins", 0))
	GameManager.boss_defeated = data.get("boss_defeated", false)
	GameManager.mini_bosses_defeated = data.get("mini_bosses_defeated", {
		"alpha_raccoon": false,
		"crow_matriarch": false,
		"rat_king": false,
	})
	GameManager.unlocked_zones = data.get("unlocked_zones", [])

	# Restore NPC reputation
	var rep_data = data.get("npc_reputation", {})
	for npc_id in rep_data:
		GameManager.npc_reputation[npc_id] = int(rep_data[npc_id])

	var pos_data = data.get("player_position", {})
	if pos_data.has("x") and pos_data.has("y"):
		GameManager.player_position = Vector2(pos_data["x"], pos_data["y"])

	var target_zone = data.get("current_zone", "neighborhood")
	GameManager.current_zone = target_zone

	var equipment_data = data.get("equipment", {})
	if not equipment_data.is_empty() and GameManager.equipment_manager and is_instance_valid(GameManager.equipment_manager):
		GameManager.equipment_manager.load_save_data(equipment_data)

	var inventory_data = data.get("inventory", {})
	if not inventory_data.is_empty() and GameManager.inventory and is_instance_valid(GameManager.inventory):
		GameManager.inventory.load_save_data(inventory_data)

	var party_data = data.get("party", {})
	if not party_data.is_empty() and GameManager.party_manager and is_instance_valid(GameManager.party_manager):
		GameManager.party_manager.load_save_data(party_data)

	if data.has("tutorial") and TutorialManager:
		TutorialManager.load_save_data(data["tutorial"])

	_pending_level = data.get("level", 1)
	_pending_exp = data.get("total_exp", 0)

	if not Events.zone_entered.is_connected(_on_zone_entered_after_load):
		Events.zone_entered.connect(_on_zone_entered_after_load, CONNECT_ONE_SHOT)

	GameManager.load_zone(target_zone, "default")
	Events.game_loaded.emit()
	return true

# =============================================================================
# PRIVATE METHODS - FILE I/O
# =============================================================================

func _write_save_file(data: Dictionary) -> bool:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		if FileAccess.file_exists(BACKUP_PATH):
			DirAccess.remove_absolute(BACKUP_PATH)
		DirAccess.copy_absolute(SAVE_FILE_PATH, BACKUP_PATH)

	var temp_path = SAVE_FILE_PATH + ".tmp"
	var file = FileAccess.open(temp_path, FileAccess.WRITE)
	if not file:
		DebugLogger.log_error("SaveManager: Failed to open temp file for writing: %s" % temp_path)
		return false

	var json_string = JSON.stringify(data, "  ")
	file.store_string(json_string)
	file.close()

	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
	DirAccess.rename_absolute(temp_path, SAVE_FILE_PATH)

	Events.game_saved.emit()
	DebugLogger.log_save("Game saved successfully")
	return true

func _read_save_file() -> Dictionary:
	var file_path = SAVE_FILE_PATH
	if not FileAccess.file_exists(file_path):
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

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		DebugLogger.log_error("SaveManager: Failed to parse save file - corrupt data at %s" % file_path)
		Events.save_corrupted.emit()
		return {}

	var data = json.get_data()
	if not data is Dictionary:
		DebugLogger.log_error("SaveManager: Save file format invalid - expected Dictionary at %s" % file_path)
		Events.save_corrupted.emit()
		return {}

	return data

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_zone_entered_after_load(_zone_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame

	var player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player):
		DebugLogger.log_error("SaveManager: Player not found after load - progression not restored")
		return
	if not player.progression:
		DebugLogger.log_error("SaveManager: Player has no progression component - progression not restored")
		return

	player.progression.current_level = _pending_level
	player.progression.total_exp = _pending_exp
	player.progression.current_exp = player.progression.get_exp_progress()
	player._apply_level_stats()

	player.progression.level_changed.emit(_pending_level)
	player.progression.exp_changed.emit(
		player.progression.get_exp_progress(),
		player.progression.get_exp_to_next_level()
	)
	DebugLogger.log_save("Game loaded - level %d, exp %d restored" % [_pending_level, _pending_exp])
