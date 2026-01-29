extends Node
## Debug Logger — Categorized logging with file output for overnight testing.
## Logs to console AND file. Categories can be filtered independently.
##
## Usage:
##   DebugLogger.log_combat("Player dealt 25 damage to Raccoon")
##   DebugLogger.log_zone("Transitioning to backyard")
##   DebugLogger.log_bot("Game loop state: FARM -> SHOP")
##   DebugLogger.log_item("Used health_potion, restored 50 HP")
##   DebugLogger.log_error("Failed to find zone exit!")

# =============================================================================
# CONFIGURATION
# =============================================================================

## Enable/disable logging categories (toggle at runtime)
var categories_enabled: Dictionary = {
	"COMBAT": true,
	"ZONE": true,
	"BOT": true,
	"ITEM": true,
	"EQUIP": true,
	"SAVE": true,
	"UI": true,
	"AI": true,
	"ERROR": true,   # Always recommended ON
	"PERF": true,    # Performance metrics
}

## Log to file (user://debug_log.txt)
var file_logging_enabled: bool = true

## Max log file size before rotation (5MB)
const MAX_LOG_SIZE: int = 5 * 1024 * 1024

## Session separator
var _session_id: String = ""
var _log_file: FileAccess = null
var _log_count: int = 0
var _start_time: float = 0.0
var _frame_times: Array[float] = []

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_start_time = Time.get_ticks_msec() / 1000.0
	_session_id = Time.get_datetime_string_from_system().replace(":", "-")
	
	if file_logging_enabled:
		_open_log_file()
	
	# Log session start
	_write_raw("=" .repeat(80))
	_write_raw("DEBUG SESSION: %s" % _session_id)
	_write_raw("Godot %s | Momi's Adventure" % Engine.get_version_info().string)
	_write_raw("=" .repeat(80))
	
	print("[DebugLogger] Initialized — logging to user://debug_log.txt")


func _process(_delta: float) -> void:
	# Track frame times for performance reporting
	if categories_enabled.get("PERF", false):
		_frame_times.append(_delta)
		if _frame_times.size() > 300:  # Keep last 5 seconds at 60fps
			_frame_times.remove_at(0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		_write_raw("=" .repeat(80))
		_write_raw("SESSION ENDED: %s | Total logs: %d" % [
			Time.get_datetime_string_from_system(), _log_count])
		_write_perf_summary()
		_write_raw("=" .repeat(80))
		_close_log_file()

# =============================================================================
# PUBLIC API — Category Loggers
# =============================================================================

func log_combat(msg: String) -> void:
	_log("COMBAT", msg)

func log_zone(msg: String) -> void:
	_log("ZONE", msg)

func log_bot(msg: String) -> void:
	_log("BOT", msg)

func log_item(msg: String) -> void:
	_log("ITEM", msg)

func log_equip(msg: String) -> void:
	_log("EQUIP", msg)

func log_save(msg: String) -> void:
	_log("SAVE", msg)

func log_ui(msg: String) -> void:
	_log("UI", msg)

func log_ai(msg: String) -> void:
	_log("AI", msg)

func log_error(msg: String) -> void:
	_log("ERROR", msg)
	push_error("[DebugLogger] " + msg)

func log_perf(msg: String) -> void:
	_log("PERF", msg)

## Generic log with custom category
func log_custom(category: String, msg: String) -> void:
	_log(category.to_upper(), msg)

# =============================================================================
# UTILITY
# =============================================================================

## Get elapsed session time
func get_session_time() -> float:
	return Time.get_ticks_msec() / 1000.0 - _start_time

## Get average FPS from recent frames
func get_avg_fps() -> float:
	if _frame_times.is_empty():
		return 0.0
	var avg_delta = _frame_times.reduce(func(a, b): return a + b) / _frame_times.size()
	return 1.0 / avg_delta if avg_delta > 0 else 0.0

## Toggle a category on/off
func toggle_category(category: String, enabled: bool) -> void:
	categories_enabled[category.to_upper()] = enabled

## Dump current game state to log (useful for crash debugging)
func dump_game_state() -> void:
	_write_raw("-" .repeat(40) + " GAME STATE DUMP " + "-" .repeat(40))
	_write_raw("Session Time: %.1fs" % get_session_time())
	_write_raw("Avg FPS: %.1f" % get_avg_fps())
	_write_raw("Current Zone: %s" % GameManager.current_zone)
	_write_raw("Coins: %d" % GameManager.coins)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		_write_raw("Player Pos: %s" % player.global_position)
		if player.has_node("HealthComponent"):
			var hp = player.get_node("HealthComponent")
			_write_raw("Player HP: %d/%d" % [hp.current_health, hp.max_health])
		if player.has_node("ProgressionComponent"):
			var prog = player.get_node("ProgressionComponent")
			_write_raw("Level: %d | EXP: %d/%d" % [prog.current_level, prog.current_exp, prog.exp_to_next_level])
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	_write_raw("Enemies alive: %d" % enemies.size())
	
	var companions = get_tree().get_nodes_in_group("companions")
	_write_raw("Companions: %d" % companions.size())
	
	if GameManager.inventory:
		_write_raw("Inventory items: %d" % GameManager.inventory.get_all_items().size())
	
	_write_raw("-" .repeat(97))

# =============================================================================
# INTERNAL
# =============================================================================

func _log(category: String, msg: String) -> void:
	if not categories_enabled.get(category, true):
		return
	
	_log_count += 1
	var timestamp = "%.1f" % get_session_time()
	var formatted = "[%s][%s] %s" % [timestamp, category, msg]
	
	# Console output
	print(formatted)
	
	# File output
	if file_logging_enabled and _log_file:
		_log_file.store_line(formatted)
		_log_file.flush()


func _write_raw(msg: String) -> void:
	print(msg)
	if file_logging_enabled and _log_file:
		_log_file.store_line(msg)
		_log_file.flush()


func _open_log_file() -> void:
	var path = "user://debug_log.txt"
	
	# Check if existing file is too large — rotate
	if FileAccess.file_exists(path):
		var existing = FileAccess.open(path, FileAccess.READ)
		if existing:
			var size = existing.get_length()
			existing.close()
			if size > MAX_LOG_SIZE:
				var old_path = "user://debug_log_prev.txt"
				DirAccess.copy_absolute(
					ProjectSettings.globalize_path(path),
					ProjectSettings.globalize_path(old_path))
	
	# Open for append
	_log_file = FileAccess.open(path, FileAccess.READ_WRITE)
	if _log_file == null:
		_log_file = FileAccess.open(path, FileAccess.WRITE)
	else:
		_log_file.seek_end()


func _close_log_file() -> void:
	if _log_file:
		_log_file.close()
		_log_file = null


func _write_perf_summary() -> void:
	if _frame_times.is_empty():
		return
	
	var avg_delta = _frame_times.reduce(func(a, b): return a + b) / _frame_times.size()
	var min_delta = _frame_times.min()
	var max_delta = _frame_times.max()
	
	_write_raw("PERF SUMMARY:")
	_write_raw("  Avg FPS: %.1f" % (1.0 / avg_delta if avg_delta > 0 else 0))
	_write_raw("  Min FPS: %.1f" % (1.0 / max_delta if max_delta > 0 else 0))
	_write_raw("  Max FPS: %.1f" % (1.0 / min_delta if min_delta > 0 else 0))
	_write_raw("  Total Logs: %d" % _log_count)
