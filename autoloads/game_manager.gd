extends Node
## Central singleton managing global game state.
## Tracks coins, player position, current zone, and provides save/load hooks.

# =============================================================================
# CONSTANTS
# =============================================================================

const InventoryClass = preload("res://systems/inventory/inventory.gd")
const EquipmentManagerClass = preload("res://systems/equipment/equipment_manager.gd")
const PartyManagerClass = preload("res://systems/party/party_manager.gd")

# =============================================================================
# STATE VARIABLES
# =============================================================================

var is_paused: bool = false
var is_player_alive: bool = true

var coins: int = 0
var current_zone: String = ""

var zone_scenes: Dictionary = {
	"neighborhood": "res://world/zones/neighborhood.tscn",
	"backyard": "res://world/zones/backyard.tscn",
	"boss_arena": "res://world/zones/boss_arena.tscn",
	"test_zone": "res://world/zones/test_zone.tscn",
	"sewers": "res://world/zones/sewers.tscn",
	"rooftops": "res://world/zones/rooftops.tscn",
}

var unlocked_zones: Array[String] = []

var boss_defeated: bool = false
var game_complete: bool = false
var mini_bosses_defeated: Dictionary = {
	"alpha_raccoon": false,
	"crow_matriarch": false,
	"rat_king": false,
	"pigeon_king": false,
}

var pending_spawn_point: String = ""
var player_position: Vector2 = Vector2.ZERO

var inventory = null
var equipment_manager = null
var party_manager = null

var _fade_overlay: CanvasLayer = null
var _fade_rect: ColorRect = null
var _is_transitioning: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	Events.player_died.connect(_on_player_died)
	Events.zone_entered.connect(_on_zone_entered)
	Events.zone_transition_requested.connect(_on_zone_transition_requested)
	Events.boss_defeated.connect(_on_boss_defeated)
	Events.mini_boss_defeated.connect(_on_mini_boss_defeated)

	Events.zone_entered.connect(_on_zone_entered_autosave)
	Events.boss_defeated.connect(_on_boss_defeated_autosave)
	Events.mini_boss_defeated.connect(_on_mini_boss_defeated_autosave)

	inventory = InventoryClass.new()
	inventory.name = "Inventory"
	add_child(inventory)

	equipment_manager = EquipmentManagerClass.new()
	equipment_manager.name = "EquipmentManager"
	add_child(equipment_manager)

	party_manager = PartyManagerClass.new()
	party_manager.name = "PartyManager"
	add_child(party_manager)

	if unlocked_zones.is_empty():
		unlock_zone("neighborhood")

	DebugLogger.log_system("GameManager initialized")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

# =============================================================================
# PUBLIC API - PAUSE SYSTEM
# =============================================================================

func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	if is_paused:
		return
	is_paused = true
	get_tree().paused = true
	Events.game_paused.emit()

func resume_game() -> void:
	if not is_paused:
		return
	is_paused = false
	get_tree().paused = false
	Events.game_resumed.emit()

# =============================================================================
# PUBLIC API - GAME FLOW
# =============================================================================

func restart_game() -> void:
	is_player_alive = true
	is_paused = false
	get_tree().paused = false
	_clear_temporary_state()
	get_tree().reload_current_scene()
	Events.game_restarted.emit()

func quit_game() -> void:
	get_tree().quit()

# =============================================================================
# PUBLIC API - ZONE TRANSITIONS
# =============================================================================

func load_zone(zone_name: String, spawn_point: String = "default") -> void:
	_on_zone_transition_requested(zone_name, spawn_point)

func get_pending_spawn() -> String:
	var spawn = pending_spawn_point
	pending_spawn_point = ""
	return spawn

# =============================================================================
# PUBLIC API - CURRENCY
# =============================================================================

func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount
	Events.coins_changed.emit(coins)

func remove_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins = max(0, coins - amount)
	Events.coins_changed.emit(coins)

func set_coins(amount: int) -> void:
	coins = max(0, amount)
	Events.coins_changed.emit(coins)

func get_coins() -> int:
	return coins

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		Events.coins_changed.emit(coins)
		return true
	return false

# =============================================================================
# ZONE MANAGEMENT
# =============================================================================

func is_zone_unlocked(zone_id: String) -> bool:
	return zone_id in unlocked_zones

func unlock_zone(zone_id: String) -> void:
	if zone_id.is_empty():
		push_warning("GameManager: Attempted to unlock zone with empty ID")
		return
	if is_zone_unlocked(zone_id):
		DebugLogger.log_system("Zone already unlocked: %s" % zone_id)
		return
	unlocked_zones.append(zone_id)
	Events.zone_unlocked.emit(zone_id)
	DebugLogger.log_system("Zone unlocked: %s" % zone_id)

func get_unlocked_zones() -> Array[String]:
	return unlocked_zones.duplicate()

func reset_zones() -> void:
	unlocked_zones.clear()
	unlock_zone("neighborhood")

# =============================================================================
# SAVE / LOAD
# =============================================================================

func save_game() -> Dictionary:
	return {
		"coins": coins,
		"current_zone": current_zone,
		"player_position": {
			"x": player_position.x,
			"y": player_position.y,
		},
		"unlocked_zones": unlocked_zones.duplicate(),
	}

func load_game(save_data: Dictionary) -> void:
	if save_data.has("coins"):
		set_coins(save_data["coins"])
	if save_data.has("current_zone"):
		current_zone = save_data["current_zone"]
	if save_data.has("player_position"):
		var pos = save_data["player_position"]
		player_position = Vector2(pos.get("x", 0.0), pos.get("y", 0.0))
	if save_data.has("unlocked_zones"):
		unlocked_zones = []
		for zone_id in save_data["unlocked_zones"]:
			unlocked_zones.append(zone_id)
	if unlocked_zones.is_empty():
		unlock_zone("neighborhood")

# =============================================================================
# PRIVATE METHODS
# =============================================================================

func _are_subsystems_valid() -> bool:
	if not inventory or not is_instance_valid(inventory):
		DebugLogger.log_error("GameManager: inventory is null or freed")
		return false
	if not equipment_manager or not is_instance_valid(equipment_manager):
		DebugLogger.log_error("GameManager: equipment_manager is null or freed")
		return false
	if not party_manager or not is_instance_valid(party_manager):
		DebugLogger.log_error("GameManager: party_manager is null or freed")
		return false
	return true

func _clear_temporary_state() -> void:
	if inventory and is_instance_valid(inventory):
		for effect_type in inventory.active_buffs.keys():
			Events.buff_expired.emit(effect_type)
		inventory.active_buffs.clear()
	else:
		DebugLogger.log_error("GameManager: inventory not valid during state clear")

func _ensure_fade_overlay() -> void:
	if _fade_overlay and is_instance_valid(_fade_overlay):
		return
	_fade_overlay = CanvasLayer.new()
	_fade_overlay.name = "FadeOverlay"
	_fade_overlay.layer = 128
	_fade_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_fade_overlay)

	_fade_rect = ColorRect.new()
	_fade_rect.name = "FadeRect"
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.anchors_preset = Control.PRESET_FULL_RECT
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_overlay.add_child(_fade_rect)

func _fade_to_black(duration: float) -> void:
	_ensure_fade_overlay()
	_fade_rect.color.a = 0.0
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade_rect, "color:a", 1.0, duration)
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.finished

func _fade_from_black(duration: float) -> void:
	_ensure_fade_overlay()
	_fade_rect.color.a = 1.0
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade_rect, "color:a", 0.0, duration)
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.finished

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_player_died() -> void:
	is_player_alive = false
	Events.game_over.emit()

func _on_zone_entered(zone_name: String) -> void:
	current_zone = zone_name

func _on_zone_transition_requested(target_zone: String, spawn_point: String) -> void:
	if not zone_scenes.has(target_zone):
		DebugLogger.log_error("GameManager: Unknown zone requested: " + target_zone)
		return
	if _is_transitioning:
		return
	_is_transitioning = true

	pending_spawn_point = spawn_point
	Events.zone_exited.emit(current_zone)

	await _fade_to_black(0.3)
	var zone_path = zone_scenes[target_zone]
	get_tree().change_scene_to_file(zone_path)
	await get_tree().process_frame
	await get_tree().process_frame
	await _fade_from_black(0.4)
	_is_transitioning = false

func _on_boss_defeated(_boss: Node) -> void:
	boss_defeated = true

func _on_mini_boss_defeated(_boss: Node, boss_key: String) -> void:
	if mini_bosses_defeated.has(boss_key):
		mini_bosses_defeated[boss_key] = true

func _on_zone_entered_autosave(zone_name: String) -> void:
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player) and player.progression and player.progression.current_level > 0:
		if not SaveManager.save_game():
			DebugLogger.log_error("GameManager: Auto-save failed on zone entry: %s" % zone_name)
			return
		DebugLogger.log_zone("Auto-saved on zone entry: %s" % zone_name)

func _on_boss_defeated_autosave(_boss: Node) -> void:
	await get_tree().create_timer(3.0).timeout
	if not SaveManager.save_game():
		DebugLogger.log_error("GameManager: Auto-save failed after boss defeat")
		return
	DebugLogger.log_save("Auto-saved after boss defeat")

func _on_mini_boss_defeated_autosave(_boss: Node, _boss_key: String) -> void:
	await get_tree().create_timer(2.0).timeout
	if not SaveManager.save_game():
		DebugLogger.log_error("GameManager: Auto-save failed after mini-boss defeat")
		return
	DebugLogger.log_save("Auto-saved after mini-boss defeat")

func reset_game() -> void:
	coins = 0
	current_zone = ""
	player_position = Vector2.ZERO
	boss_defeated = false
	game_complete = false
	mini_bosses_defeated = {
		"alpha_raccoon": false,
		"crow_matriarch": false,
		"rat_king": false,
		"pigeon_king": false,
	}
	reset_zones()
	DebugLogger.log_system("Game state reset")
