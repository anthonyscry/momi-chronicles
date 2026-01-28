extends CanvasLayer
## Ring Menu - Secret of Mana style radial menu
## NOTE: This is an autoload, so don't use class_name (would conflict)

## Ring configuration - Compact design
const RING_RADIUS: float = 38.0          # Distance from center to items (was 70)
const ROTATION_SPEED: float = 10.0       # Animation speed (slightly faster)
const MAX_VISIBLE_ITEMS: int = 6         # Items visible at once (was 8)

## Animation constants - Snappier feel
const OPEN_DURATION: float = 0.12
const CLOSE_DURATION: float = 0.08

## Ring glow colors per type
const RING_GLOW_COLORS: Dictionary = {
	0: Color(0.9, 0.75, 0.3, 0.2),   # ITEMS - Gold
	1: Color(0.4, 0.6, 1.0, 0.2),    # EQUIPMENT - Blue
	2: Color(1.0, 0.6, 0.3, 0.2),    # COMPANIONS - Orange
	3: Color(0.6, 0.6, 0.6, 0.2),    # OPTIONS - Silver
}

## Ring types
enum RingType { ITEMS, EQUIPMENT, COMPANIONS, OPTIONS }

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
	RingType.OPTIONS: []
}

## Ring display names
var ring_names: Dictionary = {
	RingType.ITEMS: "Items",
	RingType.EQUIPMENT: "Equipment",
	RingType.COMPANIONS: "Companions",
	RingType.OPTIONS: "Options"
}

## Node references
@onready var container: Control = $Container
@onready var background: ColorRect = $Container/Background
@onready var ring_glow: ColorRect = $Container/RingGlow
@onready var ring_label: Label = $Container/RingLabel
@onready var item_name_label: Label = $Container/ItemNameLabel
@onready var item_desc_label: Label = $Container/ItemDescLabel

## Pooled ring items
var ring_items: Array = []  # Array of RingItem nodes
var RingItemScene: PackedScene = preload("res://ui/ring_menu/ring_item.tscn")

## Animation tween
var open_tween: Tween

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

func _setup_default_options() -> void:
	rings[RingType.OPTIONS] = [
		{"id": "save", "name": "Save Game", "type": "option", "desc": "Save your progress"},
		{"id": "settings", "name": "Settings", "type": "option", "desc": "Audio and display options"},
		{"id": "quit", "name": "Quit", "type": "option", "desc": "Return to title screen"},
	]

func _unhandled_input(event: InputEvent) -> void:
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
	
	# Animate close
	if open_tween:
		open_tween.kill()
	open_tween = create_tween()
	open_tween.set_ease(Tween.EASE_IN)
	open_tween.set_trans(Tween.TRANS_BACK)
	open_tween.tween_property(container, "scale", Vector2.ZERO, CLOSE_DURATION)
	open_tween.parallel().tween_property(container, "modulate:a", 0.0, CLOSE_DURATION)
	open_tween.tween_callback(func(): visible = false)
	
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
	Events.ring_item_selected.emit(current_ring, item)
	
	# Handle based on type
	match current_ring:
		RingType.ITEMS:
			_use_item(item)
		RingType.EQUIPMENT:
			_equip_item(item)
		RingType.COMPANIONS:
			_switch_companion(item)
		RingType.OPTIONS:
			_handle_option(item)

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
	var center = container.size / 2
	
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
			item_desc_label.text = item.get("desc", "")
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
		return GameManager.equipment_manager.get_equipment_for_ring()
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
		"save":
			print("[RingMenu] Save game")
			if has_node("/root/SaveManager"):
				get_node("/root/SaveManager").save_game()
		"settings":
			print("[RingMenu] Settings")
		"quit":
			close_menu()
			get_tree().change_scene_to_file("res://ui/menus/title_screen.tscn")

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
