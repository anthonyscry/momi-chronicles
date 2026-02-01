extends Node
## SaveManager: Autoload singleton for game save/load functionality.
##
## This autoload handles saving and loading game state to/from disk,
## including player data, quest progress, inventory, and game settings.
## Emits signals via Events autoload to notify other systems.

# =============================================================================
# CONSTANTS
# =============================================================================

## Save file path
const SAVE_FILE_PATH: String = "user://savegame.save"

## Save file version for future compatibility
const SAVE_VERSION: int = 1

# =============================================================================
# PROPERTIES
# =============================================================================

## Whether autosave is enabled
var autosave_enabled: bool = true

## Autosave interval in seconds
var autosave_interval: float = 300.0  # 5 minutes

## Time since last autosave
var _time_since_autosave: float = 0.0

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready() -> void:
	# Enable process for autosave timer
	set_process(autosave_enabled)

# =============================================================================
# PROCESS
# =============================================================================

func _process(delta: float) -> void:
	if not autosave_enabled:
		return

	_time_since_autosave += delta
	if _time_since_autosave >= autosave_interval:
		_time_since_autosave = 0.0
		save_game()

# =============================================================================
# SAVE GAME
# =============================================================================

## Save the current game state to disk
## Returns true if save was successful, false otherwise
func save_game() -> bool:
	var save_data: Dictionary = _collect_save_data()

	# Attempt to write save file
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Failed to open save file for writing: %s" % FileAccess.get_open_error())
		return false

	# Write save data as JSON
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()

	# Emit save event
	if has_node("/root/Events"):
		var events = get_node("/root/Events")
		if events.has_signal("game_saved"):
			events.game_saved.emit()

	return true

## Collect save data from all relevant systems
func _collect_save_data() -> Dictionary:
	var data: Dictionary = {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"quests": {},
		"player": {},
		"game_state": {}
	}

	# Collect quest data from QuestManager
	if has_node("/root/QuestManager"):
		var quest_manager = get_node("/root/QuestManager")
		if quest_manager.has_method("get_save_data"):
			data["quests"] = quest_manager.get_save_data()

	# Collect game state from GameManager
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		if game_manager.has_method("get_save_data"):
			data["game_state"] = game_manager.get_save_data()

	# Collect player data
	data["player"] = _collect_player_data()

	return data

## Collect player-specific save data
func _collect_player_data() -> Dictionary:
	var player_data: Dictionary = {}

	# Get player node from scene tree
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return player_data

	# Basic position data
	player_data["position"] = {
		"x": player.global_position.x,
		"y": player.global_position.y
	}

	# Health data
	var health_comp = player.get_node_or_null("HealthComponent")
	if health_comp:
		player_data["health"] = {
			"current": health_comp.current_health,
			"max": health_comp.max_health
		}

	# Progression data
	var progression_comp = player.get_node_or_null("ProgressionComponent")
	if progression_comp:
		player_data["progression"] = {
			"level": progression_comp.current_level,
			"exp": progression_comp.current_exp if progression_comp.has("current_exp") else 0
		}

	# Guard data
	var guard_comp = player.get_node_or_null("GuardComponent")
	if guard_comp:
		player_data["guard"] = {
			"current": guard_comp.current_guard,
			"max": guard_comp.max_guard
		}

	return player_data

# =============================================================================
# LOAD GAME
# =============================================================================

## Load game state from disk
## Returns true if load was successful, false otherwise
func load_game() -> bool:
	# Check if save file exists
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		push_warning("SaveManager: No save file found at %s" % SAVE_FILE_PATH)
		return false

	# Attempt to read save file
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Failed to open save file for reading: %s" % FileAccess.get_open_error())
		return false

	# Parse JSON
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("SaveManager: Failed to parse save file JSON: %s" % json.get_error_message())
		return false

	var save_data: Dictionary = json.data

	# Validate save version
	if not save_data.has("version") or save_data["version"] != SAVE_VERSION:
		push_warning("SaveManager: Save file version mismatch (expected %d)" % SAVE_VERSION)
		# Could implement migration logic here in the future

	# Apply save data to all systems
	_apply_save_data(save_data)

	# Wait for player to spawn after zone load
	await get_tree().process_frame
	await get_tree().process_frame

	# Emit load event
	if has_node("/root/Events"):
		var events = get_node("/root/Events")
		if events.has_signal("game_loaded"):
			events.game_loaded.emit()

	return true

## Apply loaded save data to all relevant systems
func _apply_save_data(data: Dictionary) -> void:
	# Apply quest data to QuestManager
	if data.has("quests") and has_node("/root/QuestManager"):
		var quest_manager = get_node("/root/QuestManager")
		if quest_manager.has_method("load_save_data"):
			quest_manager.load_save_data(data["quests"])

	# Apply game state to GameManager
	if data.has("game_state") and has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		if game_manager.has_method("load_save_data"):
			game_manager.load_save_data(data["game_state"])

	# Apply player data
	if data.has("player"):
		_apply_player_data(data["player"])

## Apply player-specific save data
func _apply_player_data(player_data: Dictionary) -> void:
	# Get player node from scene tree
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("SaveManager: No player found in scene tree, cannot apply player data")
		return

	# Restore position
	if player_data.has("position"):
		var pos_data = player_data["position"]
		player.global_position = Vector2(pos_data["x"], pos_data["y"])

	# Restore health
	if player_data.has("health"):
		var health_comp = player.get_node_or_null("HealthComponent")
		if health_comp:
			var health_data = player_data["health"]
			health_comp.max_health = health_data["max"]
			health_comp.current_health = health_data["current"]

	# Restore progression
	if player_data.has("progression"):
		var progression_comp = player.get_node_or_null("ProgressionComponent")
		if progression_comp:
			var prog_data = player_data["progression"]
			if progression_comp.has_method("set_level"):
				progression_comp.set_level(prog_data["level"])
			if prog_data.has("exp") and progression_comp.has("current_exp"):
				progression_comp.current_exp = prog_data["exp"]

	# Restore guard
	if player_data.has("guard"):
		var guard_comp = player.get_node_or_null("GuardComponent")
		if guard_comp:
			var guard_data = player_data["guard"]
			guard_comp.max_guard = guard_data["max"]
			guard_comp.current_guard = guard_data["current"]

# =============================================================================
# UTILITIES
# =============================================================================

## Check if a save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

## Delete the current save file
## Returns true if deletion was successful, false otherwise
func delete_save_file() -> bool:
	if not has_save_file():
		return true

	var error = DirAccess.remove_absolute(SAVE_FILE_PATH)
	if error != OK:
		push_error("SaveManager: Failed to delete save file: %s" % error)
		return false

	return true

## Enable or disable autosave
func set_autosave_enabled(enabled: bool) -> void:
	autosave_enabled = enabled
	set_process(enabled)
	_time_since_autosave = 0.0

## Set autosave interval in seconds
func set_autosave_interval(interval: float) -> void:
	autosave_interval = max(interval, 10.0)  # Minimum 10 seconds
	_time_since_autosave = 0.0
