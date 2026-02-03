extends CanvasLayer
## Ring Menu - Secret of Mana style radial menu
## NOTE: This is an autoload, so don't use class_name (would conflict)

## Ring configuration - Readable compact design
const RING_RADIUS: float = 58.0          # Distance from center to items
const RING_CENTER_OFFSET: Vector2 = Vector2(0, 12)  # Offset ring center down to avoid title overlap
const ROTATION_SPEED: float = 10.0       # Animation speed
const MAX_VISIBLE_ITEMS: int = 6         # Items visible at once

## Animation constants - Snappier feel
const OPEN_DURATION: float = 0.12
const CLOSE_DURATION: float = 0.08

## Ring glow colors per type
const RING_GLOW_COLORS: Dictionary = {
	0: Color(0.9, 0.75, 0.3, 0.2),   # ITEMS - Gold
	1: Color(0.4, 0.6, 1.0, 0.2),    # EQUIPMENT - Blue
	2: Color(1.0, 0.6, 0.3, 0.2),    # COMPANIONS - Orange
	3: Color(0.6, 0.6, 0.6, 0.2),    # OPTIONS - Silver
	4: Color(1.0, 0.2, 0.2, 0.8),    # BOSS - Purple
}

## Ring types
enum RingType { ITEMS, EQUIPMENT, COMPANIONS, BOSS, OPTIONS }

## Current state
var is_open: bool = false
var current_ring: RingType = RingType.ITEMS
var selected_index: int = 0
var target_rotation: float = 0.0
var current_rotation: float = 0.0

## Ring data (populated by game systems)
var rings: Dictionary = {
	RingType.ITEMS: [],
	RingType.EQUIPMENT: [],
	RingType.COMPANIONS: [],
	RingType.BOSS: [],
	RingType.OPTIONS: []
}

## Ring display names
var ring_names: Dictionary = {
	RingType.ITEMS: "Items",
	RingType.EQUIPMENT: "Equipment",
	RingType.COMPANIONS: "Companions",
	RingType.BOSS: "Bosses",
	RingType.OPTIONS: "Options",
}

## Node references
@onready var container: Control = $Container
@onready var background: ColorRect = $Container/Background
@onready var ring_glow: ColorRect = $Container/RingGlow
@onready var ring_label: Label = $Container/RingLabel
@onready var item_name_label: Label = $Container/ItemNameLabel
@onready var item_desc_label: Label = $Container/ItemDescLabel
@onready var bosses_menu: Control = $Container/BossesMenu
@onready var boss_back_button: Button = get_node_or_null("Container/BossesMenu/BossesBackground/BossesVBox/BossesScrollContainer/BossesListVBox/BackButton")

## Pooled ring items
var ring_items: Array = []  # Array of RingItem nodes
var RingItemScene: PackedScene = preload("res://ui/ring_menu/ring_item.tscn")

## Animation tween
var open_tween: Tween

## Quest log overlay (shown when selecting Quest Log from OPTIONS ring)
var _quest_log_overlay: CanvasLayer = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	# Pre-create ring item instances
	for i in MAX_VISIBLE_ITEMS:
		var item = RingItemScene.instantiate()
		container.add_child(item)
		ring_items.append(item)
		item.visible = false
	
	# Set up default options ring
	_setup_default_options()
	_setup_default_boss_ring()

func _setup_default_options() -> void:
	rings[RingType.OPTIONS] = [
		{"id": "quest_log", "name": "Quest Log", "type": "option", "desc": "View your quests"},
		{"id": "save", "name": "Save Game", "type": "option", "desc": "Save your progress"},
		{"id": "settings", "name": "Settings", "type": "option", "desc": "Audio and display options"},
		{"id": "quit", "name": "Quit", "type": "option", "desc": "Return to title screen"},
	]

func _setup_default_boss_ring() -> void:
	rings[RingType.BOSS] = [
		{"id": "boss_tracker", "name": "Boss Tracker", "type": "boss", "desc": "View defeated bosses"},
	]

func _unhandled_input(event: InputEvent) -> void:
	# Close boss tracker if open
	if bosses_menu and bosses_menu.visible:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("dodge") or event.is_action_pressed("ring_menu"):
			_on_boss_back_pressed()
			get_viewport().set_input_as_handled()
		return

	# Close quest log if open
	if _quest_log_overlay and is_instance_valid(_quest_log_overlay):
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("dodge") or event.is_action_pressed("ring_menu"):
			_close_quest_log()
			get_viewport().set_input_as_handled()
			return

	# Tab to toggle menu
	if event.is_action_pressed("ring_menu"):
		if is_open:
			close_menu()
		else:
			open_menu()
		get_viewport().set_input_as_handled()
		return
	
	if not is_open:
		return
	
	# Navigation when open
	if event.is_action_pressed("ui_left") or event.is_action_pressed("move_left"):
		rotate_selection(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("move_right"):
		rotate_selection(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("move_up"):
		switch_ring(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down") or event.is_action_pressed("move_down"):
		switch_ring(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("attack"):
		activate_selected()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("dodge"):
		close_menu()
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not is_open:
		return
	
	# Smooth rotation animation
	current_rotation = lerp_angle(current_rotation, target_rotation, ROTATION_SPEED * delta)
	_update_item_positions()
	
	# Subtle breathing pulse on the ring glow
	if ring_glow:
		var pulse = 0.15 + sin(Time.get_ticks_msec() * 0.003) * 0.08
		var base_color = RING_GLOW_COLORS.get(current_ring as int, Color(0.5, 0.5, 0.5, 0.2))
		ring_glow.color.a = base_color.a + pulse

# =============================================================================
# MENU CONTROL
# =============================================================================

func open_menu() -> void:
	if is_open:
		return
	
	is_open = true
	visible = true
	if bosses_menu:
		bosses_menu.visible = false
	_set_ring_ui_visible(true)
	
	# Animate open (scale from 0 to 1, fade in)
	container.scale = Vector2.ZERO
	container.modulate.a = 0.0
	
	if open_tween:
		open_tween.kill()
	open_tween = create_tween()
	open_tween.set_ease(Tween.EASE_OUT)
	open_tween.set_trans(Tween.TRANS_BACK)
	open_tween.tween_property(container, "scale", Vector2.ONE, OPEN_DURATION)
	open_tween.parallel().tween_property(container, "modulate:a", 1.0, OPEN_DURATION * 0.5)
	
	# Pause game
	GameManager.pause_game()
	
	# Reset selection
	selected_index = 0
	current_rotation = 0.0
	target_rotation = 0.0
	
	# Populate current ring
	_refresh_ring()
	
	# Play sound
	AudioManager.play_sfx("menu_select")
	
	Events.ring_menu_opened.emit()

func close_menu() -> void:
	if not is_open:
		return
	
	is_open = false
	if bosses_menu:
		bosses_menu.visible = false
	
	# Animate close
	if open_tween:
		open_tween.kill()
	open_tween = create_tween()
	open_tween.set_ease(Tween.EASE_IN)
	open_tween.set_trans(Tween.TRANS_BACK)
	open_tween.tween_property(container, "scale", Vector2.ZERO, CLOSE_DURATION)
	open_tween.parallel().tween_property(container, "modulate:a", 0.0, CLOSE_DURATION)
	var self_ref = weakref(self)
	var hide_func = func():
		var node = self_ref.get_ref()
		if node:
			node.visible = false
	var hide_ref = weakref(hide_func)
	open_tween.tween_callback(func():
		var cb = hide_ref.get_ref()
		if cb:
			cb.call()
	)
	
	# Resume game
	GameManager.resume_game()
	
	# Play sound
	AudioManager.play_sfx("menu_navigate")
	
	Events.ring_menu_closed.emit()

# =============================================================================
# NAVIGATION
# =============================================================================

func rotate_selection(direction: int) -> void:
	var items = rings[current_ring]
	if items.is_empty():
		return
	
	selected_index = (selected_index + direction) % items.size()
	if selected_index < 0:
		selected_index = items.size() - 1
	
	# Calculate rotation angle
	var angle_per_item = TAU / min(items.size(), MAX_VISIBLE_ITEMS)
	target_rotation = -selected_index * angle_per_item
	
	_update_selection()
	AudioManager.play_sfx("menu_navigate")

func switch_ring(direction: int) -> void:
	var ring_count = RingType.size()
	var current_int = current_ring as int
	current_int = (current_int + direction) % ring_count
	if current_int < 0:
		current_int = ring_count - 1
	current_ring = current_int as RingType
	
	# Reset selection for new ring
	selected_index = 0
	current_rotation = 0.0
	target_rotation = 0.0
	
	_refresh_ring()
	AudioManager.play_sfx("menu_select")

func activate_selected() -> void:
	var items = rings[current_ring]
	if items.is_empty() or selected_index >= items.size():
		return
	
	var item = items[selected_index]
	
	AudioManager.play_sfx("menu_select")
	
	# Handle based on type
	match current_ring:
		RingType.ITEMS:
			_use_item(item)
		RingType.EQUIPMENT:
			_equip_item(item)
		RingType.COMPANIONS:
			_switch_companion(item)
		RingType.BOSS:
			_show_boss_tracker()
		RingType.OPTIONS:
			_handle_option(item)

func _show_boss_tracker() -> void:
	# Show boss tracker menu
	is_open = false	# Hide ring menu, show boss tracker
	if bosses_menu:
		bosses_menu.visible = true
	_set_ring_ui_visible(false)
	
	# Play sound
	AudioManager.play_sfx("menu_select")
	
	# Populate boss list
	_populate_boss_tracker()
	
	# Connect back button
	if is_instance_valid(boss_back_button):
		if not boss_back_button.is_connected("pressed", _on_boss_back_pressed):
			boss_back_button.pressed.connect(_on_boss_back_pressed)
	
	# Pause game
	GameManager.pause_game()

func _on_boss_back_pressed() -> void:
	# Close boss tracker, return to ring menu
	if bosses_menu:
		bosses_menu.visible = false
	_set_ring_ui_visible(true)
	# Re-open ring menu at original ring
	is_open = true
	_refresh_ring()
	AudioManager.play_sfx("menu_navigate")

func _populate_boss_tracker() -> void:
	var boss_container = get_node_or_null("Container/BossesMenu/BossesBackground/BossesVBox/BossesScrollContainer/BossesListVBox")
	if not boss_container:
		return
	
	# Clear existing entries
	for child in boss_container.get_children():
		if child.name.begins_with("BossEntry_"):
			child.queue_free()
	
	# Get all boss IDs from BossRewardManager
	var all_bosses = [0, 1, 2, 3] # BossID enum values
	for boss_id in all_bosses:
		var entry = _create_boss_entry(boss_id)
		boss_container.add_child(entry)

func _create_boss_entry(boss_id: int) -> Control:
	var is_defeated = BossRewardManager.is_boss_defeated(boss_id)
	var is_claimed = BossRewardManager.is_reward_claimed(boss_id)
	var boss_name = BossRewardManager.BOSS_NAMES[boss_id]
	
	var entry = HBoxContainer.new()
	entry.name = "BossEntry_%d" % boss_id
	
	# Boss icon
	var icon = TextureRect.new()
	if is_defeated:
		icon.texture = BossRewardManager.get_boss_icon_texture(boss_id)
		icon.custom_minimum_size = Vector2(32, 32)
		entry.add_child(icon)
	else:
		# Fallback: Use ColorRect for locked icon (no locked.png yet)
		var locked_icon = ColorRect.new()
		locked_icon.color = Color(0.5, 0.5, 0.5, 1)
		locked_icon.custom_minimum_size = Vector2(32, 32)
		entry.add_child(locked_icon)
	
	# Boss name
	var label = Label.new()
	label.text = boss_name if is_defeated else "%s [LOCKED]" % boss_name
	label.custom_minimum_size = Vector2(200, 32)
	entry.add_child(label)
	
	# Status indicator
	var status = Label.new()
	if is_defeated:
		if is_claimed:
			status.text = "Defeated"
			status.modulate = Color(0, 1, 0, 1) # Green
		else:
			status.text = "Reward Available"
			status.modulate = Color(1, 0.85, 0.2, 1) # Gold
	else:
		status.text = "---"
		status.modulate = Color(0.7, 0.7, 0.7, 1) # Gray
	status.custom_minimum_size = Vector2(100, 32)
	entry.add_child(status)

	if is_defeated and not is_claimed:
		var claim_button = Button.new()
		claim_button.text = "Claim"
		claim_button.custom_minimum_size = Vector2(64, 28)
		claim_button.pressed.connect(_on_boss_claim_pressed.bind(boss_id))
		entry.add_child(claim_button)
	
	return entry

func _on_boss_claim_pressed(boss_id: int) -> void:
	if not BossRewardManager.is_boss_defeated(boss_id):
		return
	if BossRewardManager.is_reward_claimed(boss_id):
		return
	BossRewardManager.mark_reward_claimed(boss_id)
	var rewards = BossRewardManager.get_boss_rewards(boss_id)
	Events.boss_reward_claimed.emit(boss_id, rewards)
	_populate_boss_tracker()

func _set_ring_ui_visible(is_visible: bool) -> void:
	if ring_label:
		ring_label.visible = is_visible
	if item_name_label:
		item_name_label.visible = is_visible
	if item_desc_label:
		item_desc_label.visible = is_visible
	for ring_item in ring_items:
		ring_item.visible = is_visible




# =============================================================================
# RING DISPLAY
# =============================================================================

func _refresh_ring() -> void:
	# Update ring glow color based on current ring type
	if ring_glow:
		var glow_color = RING_GLOW_COLORS.get(current_ring as int, Color(0.5, 0.5, 0.5, 0.2))
		ring_glow.color = glow_color
	
	# Populate rings from game systems
	match current_ring:
		RingType.ITEMS:
			rings[RingType.ITEMS] = _get_inventory_items()
		RingType.EQUIPMENT:
			rings[RingType.EQUIPMENT] = _get_equipment_items()
		RingType.COMPANIONS:
			rings[RingType.COMPANIONS] = _get_companions()
	
	var items = rings[current_ring]
	
	# Update ring label
	if ring_label:
		ring_label.text = ring_names[current_ring]
	
	# Hide all items first
	for ring_item in ring_items:
		ring_item.visible = false
	
	# Show items for current ring
	var visible_count = min(items.size(), MAX_VISIBLE_ITEMS)
	for i in visible_count:
		ring_items[i].visible = true
		ring_items[i].setup(items[i])
	
	_update_selection()
	_update_item_positions()

func _update_item_positions() -> void:
	var items = rings[current_ring]
	var visible_count = min(items.size(), MAX_VISIBLE_ITEMS)
	
	if visible_count == 0:
		return
	
	var angle_per_item = TAU / max(visible_count, 1)
	var center = container.size / 2 + RING_CENTER_OFFSET  # Offset ring center down
	
	for i in visible_count:
		var angle = current_rotation + (i * angle_per_item) - PI/2  # Start from top
		var pos = center + Vector2(cos(angle), sin(angle)) * RING_RADIUS
		ring_items[i].position = pos - ring_items[i].size / 2

func _update_selection() -> void:
	var items = rings[current_ring]
	
	# Update selected state on all items
	for i in ring_items.size():
		var is_sel = (i == selected_index and i < items.size())
		ring_items[i].set_selected(is_sel)
	
	# Update center display
	if selected_index < items.size():
		var item = items[selected_index]
		if item_name_label:
			item_name_label.text = item.get("name", "???")
		if item_desc_label:
			var desc_text = item.get("desc", "")
			# Show level requirement for equipment that player can't equip
			if current_ring == RingType.EQUIPMENT:
				var min_level = item.get("min_level", 1)
				if min_level > 1 and not item.get("player_can_equip", true):
					desc_text += " [Lv.%d Req]" % min_level
			item_desc_label.text = desc_text
	else:
		if item_name_label:
			item_name_label.text = ""
		if item_desc_label:
			item_desc_label.text = ""

# =============================================================================
# DATA GETTERS (stubs - will be replaced in later plans)
# =============================================================================

func _get_inventory_items() -> Array:
	if GameManager.inventory:
		return GameManager.inventory.get_all_items()
	return []

func _get_equipment_items() -> Array:
	if GameManager.equipment_manager:
		var items = GameManager.equipment_manager.get_equipment_for_ring()
		var player_level = _get_player_level()
		for item in items:
			var min_level = item.get("min_level", 1)
			item["min_level"] = min_level
			item["player_can_equip"] = player_level >= min_level
		return items
	return []

func _get_companions() -> Array:
	if GameManager.party_manager:
		return GameManager.party_manager.get_companions_for_ring()
	return []

# =============================================================================
# ITEM ACTIONS (Stubs - implemented in later plans)
# =============================================================================

func _use_item(item: Dictionary) -> void:
	var item_id = item.get("id", "")
	if item_id.is_empty():
		return
	
	if GameManager.inventory:
		if GameManager.inventory.use_item(item_id):
			_refresh_ring()
			var items = rings[RingType.ITEMS]
			if selected_index >= items.size():
				selected_index = max(0, items.size() - 1)
			_update_selection()

func _equip_item(item: Dictionary) -> void:
	var equip_id = item.get("id", "")
	if equip_id.is_empty():
		return

	# Check level requirement before equipping
	if not item.get("equipped", false):
		var min_level = item.get("min_level", 1)
		if min_level > 1:
			var player_level = _get_player_level()
			if player_level < min_level:
				AudioManager.play_sfx("menu_navigate")
				Events.permission_denied.emit("equipment", "Level %d required" % min_level)
				return

	if GameManager.equipment_manager:
		if item.get("equipped", false):
			GameManager.equipment_manager.unequip(item.get("slot", 0))
		else:
			GameManager.equipment_manager.equip(equip_id)
		_refresh_ring()
		_update_selection()

func _switch_companion(item: Dictionary) -> void:
	var companion_id = item.get("id", "")
	if companion_id.is_empty():
		return
	
	# Check if knocked out
	if item.get("is_knocked_out", false):
		AudioManager.play_sfx("menu_navigate")  # Error sound
		return
	
	if GameManager.party_manager:
		if not item.get("is_active", false):
			GameManager.party_manager._switch_to_companion(companion_id)
		close_menu()

func _handle_option(item: Dictionary) -> void:
	match item.get("id"):
		"quest_log":
			_open_quest_log()
		"save":
			DebugLogger.log_ui("[RingMenu] Save game")
			if has_node("/root/SaveManager"):
				get_node("/root/SaveManager").save_game()
		"settings":
			DebugLogger.log_ui("[RingMenu] Settings")
		"quit":
			close_menu()
			get_tree().change_scene_to_file("res://ui/menus/title_screen.tscn")

# =============================================================================
# HELPERS
# =============================================================================

## Get current player level via group lookup. Returns 1 if player not found.
func _get_player_level() -> int:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var progression = player.get_node_or_null("ProgressionComponent")
		if progression:
			return progression.get_level()
	return 1

# =============================================================================
# PUBLIC API (for other systems to populate rings)
# =============================================================================

func set_ring_items(ring_type: RingType, items: Array) -> void:
	rings[ring_type] = items
	if is_open and current_ring == ring_type:
		_refresh_ring()

func add_ring_item(ring_type: RingType, item: Dictionary) -> void:
	rings[ring_type].append(item)
	if is_open and current_ring == ring_type:
		_refresh_ring()

func remove_ring_item(ring_type: RingType, item_id: String) -> void:
	rings[ring_type] = rings[ring_type].filter(func(i): return i.get("id") != item_id)
	if is_open and current_ring == ring_type:
		_refresh_ring()

# =============================================================================
# QUEST LOG OVERLAY
# =============================================================================

func _open_quest_log() -> void:
	if _quest_log_overlay and is_instance_valid(_quest_log_overlay):
		_close_quest_log()
		return

	close_menu()  # Close ring menu first

	_quest_log_overlay = CanvasLayer.new()
	_quest_log_overlay.name = "QuestLogOverlay"
	_quest_log_overlay.layer = 100
	_quest_log_overlay.process_mode = Node.PROCESS_MODE_ALWAYS

	# Dark background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.anchors_preset = Control.PRESET_FULL_RECT
	_quest_log_overlay.add_child(bg)

	# Quest log panel
	var quest_log_scene = preload("res://ui/quest/quest_log.tscn")
	var quest_log = quest_log_scene.instantiate()
	_quest_log_overlay.add_child(quest_log)

	add_child(_quest_log_overlay)

	# Pause game while viewing
	GameManager.pause_game()

func _close_quest_log() -> void:
	if _quest_log_overlay and is_instance_valid(_quest_log_overlay):
		_quest_log_overlay.queue_free()
		_quest_log_overlay = null
	GameManager.resume_game()
