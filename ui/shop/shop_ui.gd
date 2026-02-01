extends CanvasLayer
## Shop UI - Full shop panel for buying items and equipment from Nutkin.
## NOTE: This is an autoload, so don't use class_name.
## Opens via Events.shop_interact_requested, closes with ESC or E.

# =============================================================================
# CONSTANTS
# =============================================================================

## Colors (matching menu_theme.tres palette)
const COLOR_PANEL_BG := Color(0.08, 0.12, 0.08, 0.95)
const COLOR_BORDER := Color(0.25, 0.4, 0.25, 1)
const COLOR_TEXT := Color(0.9, 0.95, 0.85, 1)
const COLOR_PRICE_AFFORD := Color(1.0, 0.84, 0.0)
const COLOR_PRICE_EXPENSIVE := Color(0.8, 0.3, 0.3)
const COLOR_ROW_NORMAL := Color(0.1, 0.15, 0.1, 0.6)
const COLOR_ROW_SELECTED := Color(0.18, 0.28, 0.18, 0.98)
const COLOR_TAB_ACTIVE := Color(0.5, 0.8, 0.4, 1)
const COLOR_TAB_INACTIVE := Color(0.5, 0.55, 0.5, 0.7)
const COLOR_TITLE_GOLD := Color(1.0, 0.84, 0.0)
const COLOR_OWNED_GRAY := Color(0.5, 0.55, 0.5, 0.7)
const COLOR_SUCCESS_FLASH := Color(0.3, 0.8, 0.3, 0.4)
const COLOR_FAIL_FLASH := Color(0.8, 0.2, 0.2, 0.4)
const COLOR_SELL_GOLD_FLASH := Color(1.0, 0.84, 0.0, 0.4)

## Layout
const PANEL_WIDTH: int = 280
const PANEL_HEIGHT: int = 160
const VISIBLE_ROWS: int = 7
const ROW_HEIGHT: int = 14

# =============================================================================
# STATE
# =============================================================================

var is_open: bool = false
var current_tab: int = 0       # 0=BUY, 1=SELL
var current_category: int = 0  # 0=Items, 1=Equipment
var selected_index: int = 0
var scroll_offset: int = 0
var current_list: Array = []

# =============================================================================
# NODE REFERENCES (built in _ready)
# =============================================================================

var panel: Panel
var title_label: Label
var tab_label: Label
var category_label: Label
var item_list_container: VBoxContainer
var detail_panel: Panel
var detail_name: Label
var detail_desc: Label
var detail_price: Label
var detail_stats: Label
var detail_action: Label
var coin_label: Label
var nav_hints: Label
var flash_rect: ColorRect

## Pre-created row controls
var item_rows: Array = []

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	_build_ui()
	
	Events.shop_interact_requested.connect(open_shop)
	Events.coins_changed.connect(_on_coins_changed)
	Events.player_leveled_up.connect(_on_player_leveled_up)


func _build_ui() -> void:
	# --- Main Panel ---
	panel = Panel.new()
	panel.name = "ShopPanel"
	var viewport_w: int = 384
	var viewport_h: int = 216
	panel.position = Vector2((viewport_w - PANEL_WIDTH) / 2, (viewport_h - PANEL_HEIGHT) / 2)
	panel.size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	panel.pivot_offset = Vector2(PANEL_WIDTH / 2.0, PANEL_HEIGHT / 2.0)
	
	# Panel stylebox
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL_BG
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = COLOR_BORDER
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 4
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	
	# --- Flash overlay for feedback ---
	flash_rect = ColorRect.new()
	flash_rect.name = "FlashRect"
	flash_rect.position = Vector2.ZERO
	flash_rect.size = Vector2(PANEL_WIDTH, PANEL_HEIGHT)
	flash_rect.color = Color(0, 0, 0, 0)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.z_index = 10
	panel.add_child(flash_rect)
	
	# --- Title ---
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "Nutkin's Shop"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.position = Vector2(8, 4)
	title_label.size = Vector2(PANEL_WIDTH - 16, 14)
	title_label.add_theme_font_size_override("font_size", 9)
	title_label.add_theme_color_override("font_color", COLOR_TITLE_GOLD)
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	title_label.add_theme_constant_override("shadow_offset_x", 1)
	title_label.add_theme_constant_override("shadow_offset_y", 1)
	panel.add_child(title_label)
	
	# --- Tab label (BUY | SELL) ---
	tab_label = Label.new()
	tab_label.name = "TabLabel"
	tab_label.position = Vector2(PANEL_WIDTH - 80, 4)
	tab_label.size = Vector2(72, 14)
	tab_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tab_label.add_theme_font_size_override("font_size", 7)
	panel.add_child(tab_label)
	
	# --- Category label (Items / Equipment) ---
	category_label = Label.new()
	category_label.name = "CategoryLabel"
	category_label.position = Vector2(8, 18)
	category_label.size = Vector2(120, 12)
	category_label.add_theme_font_size_override("font_size", 7)
	category_label.add_theme_color_override("font_color", COLOR_TAB_ACTIVE)
	panel.add_child(category_label)
	
	# --- Item List Area (left 60%) ---
	var list_width: int = int(PANEL_WIDTH * 0.58)
	var list_x: int = 8
	var list_y: int = 32
	var list_height: int = VISIBLE_ROWS * ROW_HEIGHT
	
	# List background
	var list_bg = ColorRect.new()
	list_bg.name = "ListBG"
	list_bg.position = Vector2(list_x - 2, list_y - 1)
	list_bg.size = Vector2(list_width + 4, list_height + 2)
	list_bg.color = Color(0.05, 0.08, 0.05, 0.6)
	panel.add_child(list_bg)
	
	item_list_container = VBoxContainer.new()
	item_list_container.name = "ItemList"
	item_list_container.position = Vector2(list_x, list_y)
	item_list_container.size = Vector2(list_width, list_height)
	item_list_container.add_theme_constant_override("separation", 0)
	panel.add_child(item_list_container)
	
	# Pre-create row panels
	for i in VISIBLE_ROWS:
		var row = _create_item_row(list_width)
		item_list_container.add_child(row)
		item_rows.append(row)
	
	# --- Detail Pane (right 40%) ---
	var detail_x: int = list_x + list_width + 6
	var detail_width: int = PANEL_WIDTH - detail_x - 8
	var detail_y: int = 32
	
	detail_panel = Panel.new()
	detail_panel.name = "DetailPanel"
	detail_panel.position = Vector2(detail_x, detail_y)
	detail_panel.size = Vector2(detail_width, VISIBLE_ROWS * ROW_HEIGHT)
	var detail_style = StyleBoxFlat.new()
	detail_style.bg_color = Color(0.06, 0.1, 0.06, 0.8)
	detail_style.border_width_left = 1
	detail_style.border_width_top = 1
	detail_style.border_width_right = 1
	detail_style.border_width_bottom = 1
	detail_style.border_color = Color(0.2, 0.3, 0.2, 0.6)
	detail_style.corner_radius_top_left = 3
	detail_style.corner_radius_top_right = 3
	detail_style.corner_radius_bottom_right = 3
	detail_style.corner_radius_bottom_left = 3
	detail_panel.add_theme_stylebox_override("panel", detail_style)
	panel.add_child(detail_panel)
	
	# Detail - name
	detail_name = Label.new()
	detail_name.name = "DetailName"
	detail_name.position = Vector2(4, 3)
	detail_name.size = Vector2(detail_width - 8, 12)
	detail_name.add_theme_font_size_override("font_size", 8)
	detail_name.add_theme_color_override("font_color", COLOR_TEXT)
	detail_name.clip_text = true
	detail_panel.add_child(detail_name)
	
	# Detail - description
	detail_desc = Label.new()
	detail_desc.name = "DetailDesc"
	detail_desc.position = Vector2(4, 16)
	detail_desc.size = Vector2(detail_width - 8, 30)
	detail_desc.add_theme_font_size_override("font_size", 6)
	detail_desc.add_theme_color_override("font_color", Color(0.7, 0.75, 0.65, 1))
	detail_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_desc.clip_text = true
	detail_panel.add_child(detail_desc)
	
	# Detail - price
	detail_price = Label.new()
	detail_price.name = "DetailPrice"
	detail_price.position = Vector2(4, 48)
	detail_price.size = Vector2(detail_width - 8, 12)
	detail_price.add_theme_font_size_override("font_size", 7)
	detail_panel.add_child(detail_price)
	
	# Detail - stats (for equipment)
	detail_stats = Label.new()
	detail_stats.name = "DetailStats"
	detail_stats.position = Vector2(4, 60)
	detail_stats.size = Vector2(detail_width - 8, 24)
	detail_stats.add_theme_font_size_override("font_size", 6)
	detail_stats.add_theme_color_override("font_color", Color(0.6, 0.85, 0.5, 1))
	detail_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_stats.clip_text = true
	detail_panel.add_child(detail_stats)
	
	# Detail - action prompt
	detail_action = Label.new()
	detail_action.name = "DetailAction"
	detail_action.position = Vector2(4, VISIBLE_ROWS * ROW_HEIGHT - 14)
	detail_action.size = Vector2(detail_width - 8, 12)
	detail_action.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_action.add_theme_font_size_override("font_size", 7)
	detail_panel.add_child(detail_action)
	
	# --- Coin Display (bottom-left) ---
	coin_label = Label.new()
	coin_label.name = "CoinLabel"
	coin_label.position = Vector2(8, PANEL_HEIGHT - 20)
	coin_label.size = Vector2(100, 12)
	coin_label.add_theme_font_size_override("font_size", 7)
	coin_label.add_theme_color_override("font_color", COLOR_PRICE_AFFORD)
	panel.add_child(coin_label)
	
	# --- Navigation Hints (bottom) ---
	nav_hints = Label.new()
	nav_hints.name = "NavHints"
	nav_hints.text = "[W/S] Select  [A/D] Tab  [Q] Category  [Z] Action  [Esc] Close"
	nav_hints.position = Vector2(8, PANEL_HEIGHT - 10)
	nav_hints.size = Vector2(PANEL_WIDTH - 16, 10)
	nav_hints.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nav_hints.add_theme_font_size_override("font_size", 5)
	nav_hints.add_theme_color_override("font_color", Color(0.5, 0.55, 0.5, 0.7))
	panel.add_child(nav_hints)


func _create_item_row(row_width: int) -> Panel:
	var row = Panel.new()
	row.custom_minimum_size = Vector2(row_width, ROW_HEIGHT)
	row.size = Vector2(row_width, ROW_HEIGHT)
	
	var row_style = StyleBoxFlat.new()
	row_style.bg_color = COLOR_ROW_NORMAL
	row_style.corner_radius_top_left = 2
	row_style.corner_radius_top_right = 2
	row_style.corner_radius_bottom_right = 2
	row_style.corner_radius_bottom_left = 2
	row.add_theme_stylebox_override("panel", row_style)
	
	# Color swatch (6x6)
	var swatch = ColorRect.new()
	swatch.name = "Swatch"
	swatch.position = Vector2(3, 4)
	swatch.size = Vector2(6, 6)
	swatch.color = Color.WHITE
	row.add_child(swatch)
	
	# Item name
	var name_lbl = Label.new()
	name_lbl.name = "ItemName"
	name_lbl.position = Vector2(12, 0)
	name_lbl.size = Vector2(row_width - 70, ROW_HEIGHT)
	name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 6)
	name_lbl.add_theme_color_override("font_color", COLOR_TEXT)
	name_lbl.clip_text = true
	row.add_child(name_lbl)
	
	# Quantity owned
	var qty_lbl = Label.new()
	qty_lbl.name = "Quantity"
	qty_lbl.position = Vector2(row_width - 56, 0)
	qty_lbl.size = Vector2(22, ROW_HEIGHT)
	qty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	qty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	qty_lbl.add_theme_font_size_override("font_size", 5)
	qty_lbl.add_theme_color_override("font_color", COLOR_OWNED_GRAY)
	row.add_child(qty_lbl)
	
	# Price
	var price_lbl = Label.new()
	price_lbl.name = "Price"
	price_lbl.position = Vector2(row_width - 32, 0)
	price_lbl.size = Vector2(28, ROW_HEIGHT)
	price_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	price_lbl.add_theme_font_size_override("font_size", 6)
	row.add_child(price_lbl)
	
	return row


# =============================================================================
# OPEN / CLOSE
# =============================================================================

func open_shop() -> void:
	if is_open:
		return
	
	is_open = true
	visible = true
	
	# Pause game
	GameManager.pause_game()
	
	# Reset state
	current_tab = 0
	current_category = 0
	selected_index = 0
	scroll_offset = 0
	
	# Populate
	_refresh_list()
	_update_coin_display()
	_update_tab_label()
	_update_category_label()
	
	# Animate open: scale from 0.8 + fade in
	panel.scale = Vector2(0.8, 0.8)
	panel.modulate.a = 0.0
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.15)
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.1)
	
	AudioManager.play_sfx("menu_select")


func close_shop() -> void:
	if not is_open:
		return
	
	is_open = false
	
	# Animate close
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "scale", Vector2(0.8, 0.8), 0.1)
	tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func(): visible = false)
	
	# Resume game
	GameManager.resume_game()
	
	Events.shop_closed.emit()
	AudioManager.play_sfx("menu_navigate")


# =============================================================================
# INPUT
# =============================================================================

func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	
	if not event.is_pressed() or event.is_echo():
		return
	
	# Close shop
	if event.is_action_pressed("pause") or event.is_action_pressed("interact"):
		close_shop()
		get_viewport().set_input_as_handled()
		return
	
	# Navigate up
	if event.is_action_pressed("ui_up") or event.is_action_pressed("move_up"):
		_navigate(-1)
		get_viewport().set_input_as_handled()
		return
	
	# Navigate down
	if event.is_action_pressed("ui_down") or event.is_action_pressed("move_down"):
		_navigate(1)
		get_viewport().set_input_as_handled()
		return
	
	# Switch tab (left/right)
	if event.is_action_pressed("ui_left") or event.is_action_pressed("move_left"):
		_switch_tab(-1)
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("ui_right") or event.is_action_pressed("move_right"):
		_switch_tab(1)
		get_viewport().set_input_as_handled()
		return
	
	# Toggle category (Q = cycle_companion action)
	if event.is_action_pressed("cycle_companion"):
		_toggle_category()
		get_viewport().set_input_as_handled()
		return
	
	# Buy / Sell (Z / attack)
	if event.is_action_pressed("attack"):
		if current_tab == 0:
			_buy_selected()
		else:
			_sell_selected()
		get_viewport().set_input_as_handled()
		return


# =============================================================================
# NAVIGATION
# =============================================================================

func _navigate(direction: int) -> void:
	if current_list.is_empty():
		return
	
	selected_index = clampi(selected_index + direction, 0, current_list.size() - 1)
	
	# Scroll if needed
	if selected_index < scroll_offset:
		scroll_offset = selected_index
	elif selected_index >= scroll_offset + VISIBLE_ROWS:
		scroll_offset = selected_index - VISIBLE_ROWS + 1
	
	_update_rows()
	_update_detail()
	AudioManager.play_sfx("menu_navigate")


func _switch_tab(direction: int) -> void:
	var new_tab = clampi(current_tab + direction, 0, 1)
	if new_tab == current_tab:
		return
	
	current_tab = new_tab
	selected_index = 0
	scroll_offset = 0
	_refresh_list()
	_update_tab_label()
	AudioManager.play_sfx("menu_navigate")


func _toggle_category() -> void:
	current_category = 1 - current_category
	selected_index = 0
	scroll_offset = 0
	_refresh_list()
	_update_category_label()
	AudioManager.play_sfx("menu_navigate")


# =============================================================================
# LIST MANAGEMENT
# =============================================================================

func _refresh_list() -> void:
	if current_tab == 0:  # BUY
		if current_category == 0:  # Items
			current_list = ShopCatalog.get_all_shop_items()
		else:  # Equipment
			current_list = ShopCatalog.get_all_shop_equipment()
	else:  # SELL
		if current_category == 0:  # Items
			current_list = _get_sell_items()
		else:  # Equipment
			current_list = _get_sell_equipment()
	
	selected_index = clampi(selected_index, 0, maxi(current_list.size() - 1, 0))
	scroll_offset = clampi(scroll_offset, 0, maxi(current_list.size() - VISIBLE_ROWS, 0))
	
	_update_rows()
	_update_detail()
	_update_tab_label()
	_update_category_label()


func _update_rows() -> void:
	for i in VISIBLE_ROWS:
		var row = item_rows[i]
		var list_index = scroll_offset + i
		
		if list_index >= current_list.size():
			# Empty row
			row.visible = false
			continue
		
		row.visible = true
		var item = current_list[list_index]
		var is_selected = (list_index == selected_index)
		
		# Update row background color
		var row_style = row.get_theme_stylebox("panel") as StyleBoxFlat
		if row_style:
			row_style.bg_color = COLOR_ROW_SELECTED if is_selected else COLOR_ROW_NORMAL
		
		# Swatch color
		var swatch = row.get_node("Swatch") as ColorRect
		if swatch:
			swatch.color = item.get("color", Color.WHITE)
		
		# Item name
		var name_lbl = row.get_node("ItemName") as Label
		if name_lbl:
			name_lbl.text = item.get("name", "???")
		
		# Price and Quantity depend on tab
		var price_lbl = row.get_node("Price") as Label
		var qty_lbl = row.get_node("Quantity") as Label
		
		if current_tab == 0:  # BUY
			var price = item.get("buy_price", 0)
			var stock = item.get("stock", 0)
			var can_afford = GameManager.coins >= price
			if price_lbl:
				price_lbl.text = str(price) + "g"
				price_lbl.add_theme_color_override("font_color", COLOR_PRICE_AFFORD if can_afford else COLOR_PRICE_EXPENSIVE)
			if qty_lbl:
				if item.get("type") == "equipment":
					if GameManager.equipment_manager and GameManager.equipment_manager.has_equipment(item.get("id", "")):
						qty_lbl.text = "Own"
					else:
						qty_lbl.text = "x%d" % stock
				else:
					qty_lbl.text = "x%d" % stock
		else:  # SELL
			var sell_price = item.get("sell_price", 0)
			if price_lbl:
				price_lbl.text = str(sell_price) + "g"
				price_lbl.add_theme_color_override("font_color", COLOR_PRICE_AFFORD)
			if qty_lbl:
				if item.get("type") == "equipment":
					qty_lbl.text = "x1"
				else:
					var qty = item.get("quantity", 1)
					qty_lbl.text = "x%d" % qty


func _update_detail() -> void:
	if current_list.is_empty():
		detail_name.text = ""
		detail_desc.text = ""
		detail_price.text = ""
		detail_stats.text = ""
		detail_action.text = ""
		
		if current_tab == 1:
			detail_name.text = "Nothing to sell!"
			detail_desc.text = ""
			detail_action.text = ""
		return
	
	var item = current_list[selected_index]
	var item_id = item.get("id", "")
	var is_equipment = item.get("type") == "equipment"
	
	# Name
	detail_name.text = item.get("name", "???")
	
	# Description
	detail_desc.text = item.get("desc", "")
	
	if current_tab == 1:  # SELL detail
		var sell_price = item.get("sell_price", 0)
		
		# Price in gold
		detail_price.text = "Sell: %d coins" % sell_price
		detail_price.add_theme_color_override("font_color", COLOR_PRICE_AFFORD)
		
		# Stats (equipment only)
		if is_equipment and item.has("stats"):
			var stat_text = ""
			var stats = item.get("stats", {})
			for stat_type in stats:
				var val = stats[stat_type]
				var stat_name = _get_stat_name(stat_type)
				if stat_text != "":
					stat_text += ", "
				stat_text += "+%s %s" % [str(val), stat_name]
			detail_stats.text = stat_text
		else:
			detail_stats.text = ""
		
		# Action prompt
		detail_action.text = "[Z] Sell"
		detail_action.add_theme_color_override("font_color", COLOR_PRICE_AFFORD)
		return
	
	# BUY detail
	var price = item.get("buy_price", 0)
	var can_afford = GameManager.coins >= price
	var already_owned = false
	
	if is_equipment and GameManager.equipment_manager:
		already_owned = GameManager.equipment_manager.has_equipment(item_id)
	
	# Price
	detail_price.text = "Price: %d coins" % price
	detail_price.add_theme_color_override("font_color", COLOR_PRICE_AFFORD if can_afford else COLOR_PRICE_EXPENSIVE)
	
	# Stats (equipment only)
	var level_too_low := false
	if is_equipment and item.has("stats"):
		var stat_text = ""
		var stats = item.get("stats", {})
		for stat_type in stats:
			var val = stats[stat_type]
			var stat_name = _get_stat_name(stat_type)
			if stat_text != "":
				stat_text += ", "
			stat_text += "+%s %s" % [str(val), stat_name]

		# Check level requirement
		var min_level = item.get("min_level", 1)
		if min_level > 1:
			var player_level = _get_player_level()
			if player_level < min_level:
				level_too_low = true
				stat_text += "\nRequires Lv.%d" % min_level

		detail_stats.text = stat_text
		detail_stats.add_theme_color_override("font_color", COLOR_PRICE_EXPENSIVE if level_too_low else Color(0.6, 0.85, 0.5, 1))
	else:
		detail_stats.text = ""
		detail_stats.add_theme_color_override("font_color", Color(0.6, 0.85, 0.5, 1))

	# Action prompt
	if already_owned:
		detail_action.text = "Already owned"
		detail_action.add_theme_color_override("font_color", COLOR_OWNED_GRAY)
	elif level_too_low:
		var min_level = item.get("min_level", 1)
		detail_action.text = "Lv.%d Required" % min_level
		detail_action.add_theme_color_override("font_color", COLOR_PRICE_EXPENSIVE)
	elif not can_afford:
		detail_action.text = "Not enough coins"
		detail_action.add_theme_color_override("font_color", COLOR_PRICE_EXPENSIVE)
	else:
		detail_action.text = "[Z] Buy"
		detail_action.add_theme_color_override("font_color", COLOR_TAB_ACTIVE)


func _get_stat_name(stat_type: int) -> String:
	match stat_type:
		0: return "Max HP"
		1: return "Attack"
		2: return "Speed"
		3: return "Defense"
		4: return "Guard Regen"
		5: return "EXP%"
	return "???"


# =============================================================================
# BUY TRANSACTION
# =============================================================================

func _buy_selected() -> void:
	if current_list.is_empty() or current_tab != 0:
		return
	
	var item = current_list[selected_index]
	var item_id = item.get("id", "")
	var price = item.get("buy_price", 0)
	var is_equipment = item.get("type") == "equipment"
	
	# Check already owned (equipment)
	if is_equipment and GameManager.equipment_manager:
		if GameManager.equipment_manager.has_equipment(item_id):
			_flash_feedback(COLOR_OWNED_GRAY)
			AudioManager.play_sfx("menu_navigate")
			print("[Shop] Already owned: %s" % item.get("name", ""))
			return

	# Check level requirement (equipment)
	if is_equipment:
		var min_level = item.get("min_level", 1)
		if min_level > 1:
			var player_level = _get_player_level()
			if player_level < min_level:
				_flash_feedback(COLOR_FAIL_FLASH)
				AudioManager.play_sfx("menu_navigate")
				Events.permission_denied.emit("shop", "Level %d required" % min_level)
				return

	# Attempt purchase
	if not GameManager.spend_coins(price):
		_flash_feedback(COLOR_FAIL_FLASH)
		_shake_coin_label()
		AudioManager.play_sfx("menu_navigate")
		print("[Shop] Not enough coins for: %s (need %d, have %d)" % [item.get("name", ""), price, GameManager.coins])
		return
	
	# Success - add to inventory
	if is_equipment:
		if GameManager.equipment_manager:
			GameManager.equipment_manager.add_equipment(item_id)
	else:
		if GameManager.inventory:
			GameManager.inventory.add_item(item_id)
	
	# Reduce stock
	ShopCatalog.reduce_stock(item_id)
	
	# Feedback
	_flash_feedback(COLOR_SUCCESS_FLASH)
	AudioManager.play_sfx("health_pickup")
	print("[Shop] Bought: %s for %d coins" % [item.get("name", ""), price])
	
	# Refresh display (items with 0 stock disappear)
	_refresh_list()
	_update_coin_display()


# =============================================================================
# SELL TRANSACTION
# =============================================================================

func _sell_selected() -> void:
	if current_list.is_empty() or current_tab != 1:
		return
	
	var item = current_list[selected_index]
	var item_id = item.get("id", "")
	var sell_price = item.get("sell_price", 0)
	var item_name = item.get("name", "???")
	var is_equipment = item.get("type") == "equipment"

	# Safety net: prevent selling equipped items
	if is_equipment and GameManager.equipment_manager:
		if GameManager.equipment_manager.is_equipped(item_id):
			_flash_feedback(COLOR_FAIL_FLASH)
			AudioManager.play_sfx("menu_navigate")
			Events.permission_denied.emit("shop", "Cannot sell equipped item")
			return

	# Perform sell
	if is_equipment:
		if GameManager.equipment_manager:
			GameManager.equipment_manager.remove_equipment(item_id)
	else:
		if GameManager.inventory:
			GameManager.inventory.remove_item(item_id, 1)
	
	# Add coins
	GameManager.add_coins(sell_price)
	
	# Feedback
	_flash_feedback(COLOR_SELL_GOLD_FLASH)
	_spawn_sell_coin_text(sell_price)
	AudioManager.play_sfx("health_pickup")
	print("[Shop] Sold: %s for %d coins" % [item_name, sell_price])
	
	# Refresh display
	_refresh_list()
	_update_coin_display()
	
	# Clamp selected_index if list shrank
	if current_list.is_empty():
		selected_index = 0
	elif selected_index >= current_list.size():
		selected_index = current_list.size() - 1
	
	_update_rows()
	_update_detail()


## Build sell list from player's inventory items
func _get_sell_items() -> Array:
	var result: Array = []
	if not GameManager.inventory:
		return result
	
	var all_items = GameManager.inventory.get_all_items()
	for item in all_items:
		var item_id = item.get("id", "")
		var sell_price = ShopCatalog.get_sell_price(item_id)
		if sell_price >= 0:
			item["sell_price"] = sell_price
			result.append(item)
	return result


## Build sell list from player's unequipped equipment inventory
func _get_sell_equipment() -> Array:
	var result: Array = []
	if not GameManager.equipment_manager:
		return result
	
	for equip_id in GameManager.equipment_manager.equipment_inventory:
		var data = EquipmentDatabase.get_equipment(equip_id)
		if data.is_empty():
			continue
		var sell_price = ShopCatalog.get_sell_price(equip_id)
		if sell_price >= 0:
			data["sell_price"] = sell_price
			result.append(data)
	return result


## Floating "+coins" text near coin display
func _spawn_sell_coin_text(amount: int) -> void:
	var float_label = Label.new()
	float_label.text = "+%d" % amount
	float_label.add_theme_font_size_override("font_size", 8)
	float_label.add_theme_color_override("font_color", COLOR_PRICE_AFFORD)
	float_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	float_label.add_theme_constant_override("shadow_offset_x", 1)
	float_label.add_theme_constant_override("shadow_offset_y", 1)
	float_label.position = Vector2(coin_label.position.x + 65, coin_label.position.y - 2)
	float_label.z_index = 20
	panel.add_child(float_label)
	
	# Tween up and fade out
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.tween_property(float_label, "position:y", float_label.position.y - 16, 0.6).set_ease(Tween.EASE_OUT)
	tween.tween_property(float_label, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN).set_delay(0.2)
	tween.set_parallel(false)
	tween.tween_callback(float_label.queue_free)


# =============================================================================
# UI UPDATES
# =============================================================================

func _update_coin_display() -> void:
	if coin_label:
		coin_label.text = "Coins: %d" % GameManager.coins


func _on_coins_changed(_total: int) -> void:
	_update_coin_display()


func _on_player_leveled_up(_new_level: int) -> void:
	if is_open:
		_refresh_list()


## Get current player level via group lookup. Returns 1 if player not found.
func _get_player_level() -> int:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("ProgressionComponent"):
		return player.get_node("ProgressionComponent").get_level()
	return 1


func _update_tab_label() -> void:
	if not tab_label:
		return
	
	# Build rich tab text with active highlighting
	var buy_color = COLOR_TAB_ACTIVE if current_tab == 0 else COLOR_TAB_INACTIVE
	var sell_color = COLOR_TAB_ACTIVE if current_tab == 1 else COLOR_TAB_INACTIVE
	
	# Since Label can't do inline colors easily, just use text indication
	if current_tab == 0:
		tab_label.text = "> BUY <  SELL"
		tab_label.add_theme_color_override("font_color", COLOR_TAB_ACTIVE)
	else:
		tab_label.text = "BUY  > SELL <"
		tab_label.add_theme_color_override("font_color", COLOR_TAB_ACTIVE)


func _update_category_label() -> void:
	if not category_label:
		return
	
	if current_category == 0:
		category_label.text = "[Q] Items (%d)" % current_list.size()
	else:
		category_label.text = "[Q] Equipment (%d)" % current_list.size()


# =============================================================================
# FEEDBACK ANIMATIONS
# =============================================================================

func _flash_feedback(color: Color) -> void:
	if not flash_rect:
		return
	flash_rect.color = color
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(flash_rect, "color:a", 0.0, 0.25).set_ease(Tween.EASE_OUT)


func _shake_coin_label() -> void:
	if not coin_label:
		return
	var original_x = coin_label.position.x
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(coin_label, "position:x", original_x + 3, 0.04)
	tween.tween_property(coin_label, "position:x", original_x - 3, 0.04)
	tween.tween_property(coin_label, "position:x", original_x + 2, 0.04)
	tween.tween_property(coin_label, "position:x", original_x, 0.04)
