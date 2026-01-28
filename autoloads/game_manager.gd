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

## Phase 16 systems - loaded dynamically to avoid autoload ordering issues
var inventory = null           # Inventory
var equipment_manager = null   # EquipmentManager
var party_manager = null       # PartyManager

## Preload Phase 16 classes
const InventoryClass = preload("res://systems/inventory/inventory.gd")
const EquipmentManagerClass = preload("res://systems/equipment/equipment_manager.gd")
const PartyManagerClass = preload("res://systems/party/party_manager.gd")

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
	
	# Auto-save on zone entry
	Events.zone_entered.connect(_on_zone_entered_autosave)
	# Auto-save after boss defeat (delayed for celebration)
	Events.boss_defeated.connect(_on_boss_defeated_autosave)
	
	# Initialize inventory system (Phase 16)
	inventory = InventoryClass.new()
	inventory.name = "Inventory"
	add_child(inventory)
	
	# Initialize equipment system (Phase 16)
	equipment_manager = EquipmentManagerClass.new()
	equipment_manager.name = "EquipmentManager"
	add_child(equipment_manager)
	
	# Initialize party system (Phase 16)
	party_manager = PartyManagerClass.new()
	party_manager.name = "PartyManager"
	add_child(party_manager)

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

## Transition fade overlay
var _fade_overlay: CanvasLayer = null
var _fade_rect: ColorRect = null
var _is_transitioning: bool = false

## Handle zone transition request with fade effect
func _on_zone_transition_requested(target_zone: String, spawn_point: String) -> void:
	if not zone_scenes.has(target_zone):
		push_error("Unknown zone: " + target_zone)
		return
	
	if _is_transitioning:
		return
	_is_transitioning = true
	
	pending_spawn_point = spawn_point
	Events.zone_exited.emit(current_zone)
	
	# Fade out, load zone, fade in
	_ensure_fade_overlay()
	await _fade_to_black(0.3)
	
	# Load the new zone
	var zone_path = zone_scenes[target_zone]
	get_tree().change_scene_to_file(zone_path)
	
	# Wait a frame for scene to load
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Fade back in
	await _fade_from_black(0.4)
	_is_transitioning = false


## Ensure the fade overlay exists (persistent across scenes)
func _ensure_fade_overlay() -> void:
	if _fade_overlay and is_instance_valid(_fade_overlay):
		return
	
	_fade_overlay = CanvasLayer.new()
	_fade_overlay.name = "FadeOverlay"
	_fade_overlay.layer = 128  # Above everything
	_fade_overlay.process_mode = Node.PROCESS_MODE_ALWAYS  # Works during pause
	add_child(_fade_overlay)
	
	_fade_rect = ColorRect.new()
	_fade_rect.name = "FadeRect"
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.anchors_preset = Control.PRESET_FULL_RECT
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_overlay.add_child(_fade_rect)


## Fade screen to black
func _fade_to_black(duration: float) -> void:
	_ensure_fade_overlay()
	_fade_rect.color.a = 0.0
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade_rect, "color:a", 1.0, duration)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.finished


## Fade screen from black
func _fade_from_black(duration: float) -> void:
	_ensure_fade_overlay()
	_fade_rect.color.a = 1.0
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade_rect, "color:a", 0.0, duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.finished


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


# =============================================================================
# AUTO-SAVE
# =============================================================================

## Auto-save on zone entry
func _on_zone_entered_autosave(zone_name: String) -> void:
	# Skip if this is initial game load (no player yet)
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player and player.progression and player.progression.current_level > 0:
		SaveManager.save_game()
		print("[GameManager] Auto-saved on zone entry: ", zone_name)


## Auto-save after boss defeat (delayed for celebration/rewards)
func _on_boss_defeated_autosave(_boss: Node) -> void:
	# Wait 3 seconds for victory celebration and rewards
	await get_tree().create_timer(3.0).timeout
	SaveManager.save_game()
	print("[GameManager] Auto-saved after boss defeat")
