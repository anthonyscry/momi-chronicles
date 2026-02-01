extends CanvasLayer
class_name GameHUD
## Main game HUD containing health bar and debug info.
## F3 toggles debug panel visibility.

@onready var health_bar: HealthBar = $MarginContainer/VBoxContainer/HealthBar
@onready var debug_panel: PanelContainer = $MarginContainer/VBoxContainer/DebugPanel
@onready var autobot_label: Label = $MarginContainer/VBoxContainer/DebugPanel/AutoBotLabel

## Low HP vignette overlay
var low_hp_vignette: ColorRect
var vignette_tween: Tween
var is_low_hp: bool = false
const LOW_HP_THRESHOLD: float = 0.25

## Buff status icons
var buff_icons = null  # BuffIcons instance (preloaded to avoid scope issues)

## Save indicator
var save_indicator: Label

## Whether debug panel is visible
var debug_visible: bool = DebugConfig.show_debug_ui

func _ready() -> void:
	# Hide debug panel in release builds
	if not DebugConfig.show_debug_ui:
		debug_panel.visible = false
		debug_visible = false
	else:
		# Show debug by default in debug builds (can toggle with F3)
		debug_panel.visible = debug_visible
	
	# Create low HP vignette overlay
	_setup_low_hp_vignette()
	
	# Create buff icons display
	_setup_buff_icons()
	
	# Create save indicator
	_setup_save_indicator()
	
	# Connect to health changes
	Events.player_health_changed.connect(_on_health_changed)
	
	# Connect to save events
	Events.game_saved.connect(_on_game_saved)
	
	# Connect to game_loaded to refresh all HUD elements after loading a save
	Events.game_loaded.connect(_on_game_loaded)


func _unhandled_input(event: InputEvent) -> void:
	# F3 toggles debug panel (only in debug builds)
	if not DebugConfig.show_debug_ui:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			debug_visible = not debug_visible
			debug_panel.visible = debug_visible
			DebugLogger.log_ui("Debug panel: %s (F3 to toggle)" % ("ON" if debug_visible else "OFF"))


func _setup_save_indicator() -> void:
	save_indicator = Label.new()
	save_indicator.name = "SaveIndicator"
	save_indicator.text = "SAVING..."
	save_indicator.add_theme_font_size_override("font_size", 7)
	save_indicator.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 0.8))
	save_indicator.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	save_indicator.add_theme_constant_override("outline_size", 1)
	# Bottom-right corner
	save_indicator.position = Vector2(320, 200)
	save_indicator.modulate.a = 0.0
	add_child(save_indicator)


func _on_game_saved() -> void:
	if not save_indicator:
		return
	# Brief flash: fade in, hold, fade out
	var tween = create_tween()
	tween.tween_property(save_indicator, "modulate:a", 1.0, 0.15)
	tween.tween_interval(1.0)
	tween.tween_property(save_indicator, "modulate:a", 0.0, 0.4)


func _on_game_loaded() -> void:
	# Wait for player to spawn after zone load (same pattern as save_manager)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Refresh health bar
	var health_comp = player.get_node_or_null("HealthComponent")
	if health_comp:
		Events.player_health_changed.emit(health_comp.current_health, health_comp.max_health)
	
	# Refresh coin counter
	Events.coins_changed.emit(GameManager.coins)
	
	# Refresh EXP bar and level display
	var progression = player.get_node_or_null("ProgressionComponent")
	if progression:
		Events.exp_gained.emit(0, progression.current_level, progression.get_exp_progress(), progression.get_exp_to_next_level())
		Events.player_leveled_up.emit(progression.current_level)
	
	# Refresh guard bar
	var guard_comp = player.get_node_or_null("GuardComponent")
	if guard_comp:
		Events.guard_changed.emit(guard_comp.current_guard, guard_comp.max_guard)


func _setup_buff_icons() -> void:
	var BuffIconsScript = preload("res://ui/hud/buff_icons.gd")
	buff_icons = BuffIconsScript.new()
	buff_icons.name = "BuffIcons"
	# Position bottom-left below health bar
	buff_icons.position = Vector2(8, 60)
	add_child(buff_icons)


func _setup_low_hp_vignette() -> void:
	# Red vignette overlay for when HP is low
	low_hp_vignette = ColorRect.new()
	low_hp_vignette.name = "LowHPVignette"
	low_hp_vignette.color = Color(0.8, 0, 0, 0)  # Transparent red initially
	low_hp_vignette.anchors_preset = Control.PRESET_FULL_RECT
	low_hp_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	low_hp_vignette.show_behind_parent = true
	# Use a gradient-like effect: full color at edges, transparent center
	# Since we can't do real gradient in ColorRect, we'll pulse it subtly
	add_child(low_hp_vignette)
	low_hp_vignette.visible = false


func _on_health_changed(current: int, max_health: int) -> void:
	var health_percent = float(current) / float(max_health) if max_health > 0 else 1.0
	
	if health_percent <= LOW_HP_THRESHOLD and not is_low_hp:
		# Just went low HP - start pulsing red vignette
		is_low_hp = true
		_start_vignette_pulse()
	elif health_percent > LOW_HP_THRESHOLD and is_low_hp:
		# Recovered above threshold - stop vignette
		is_low_hp = false
		_stop_vignette_pulse()


func _start_vignette_pulse() -> void:
	if not low_hp_vignette:
		return
	low_hp_vignette.visible = true
	
	# Kill existing tween
	if vignette_tween and vignette_tween.is_valid():
		vignette_tween.kill()
	
	# Looping pulse: fade in -> fade out -> repeat
	vignette_tween = create_tween().set_loops()
	vignette_tween.tween_property(low_hp_vignette, "color:a", 0.18, 0.6)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	vignette_tween.tween_property(low_hp_vignette, "color:a", 0.04, 0.6)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func _stop_vignette_pulse() -> void:
	if vignette_tween and vignette_tween.is_valid():
		vignette_tween.kill()
	if low_hp_vignette:
		# Fade out smoothly
		var fade_out = create_tween()
		fade_out.tween_property(low_hp_vignette, "color:a", 0.0, 0.3)
		fade_out.tween_callback(func(): low_hp_vignette.visible = false)


func _process(_delta: float) -> void:
	# Only update if debug panel is visible
	if not debug_visible or not debug_panel.visible:
		return
	
	# Update AutoBot status label
	if autobot_label and is_instance_valid(AutoBot):
		var status = AutoBot.get_status()
		if AutoBot.enabled:
			# Show detailed debug info
			autobot_label.text = AutoBot.get_debug_info() + "\nF1=Bot | F3=Hide"
			
			# Color based on state
			match status:
				"ATTACKING", "DESPERATE_ATTACK":
					autobot_label.modulate = Color(1, 0.4, 0.4, 1)  # Red when attacking
				"CLOSING":
					autobot_label.modulate = Color(1, 0.7, 0.3, 1)  # Orange when closing
				"HUNTING", "FINISH_THEM":
					autobot_label.modulate = Color(1, 0.9, 0.3, 1)  # Yellow when hunting
				"WANDERING":
					autobot_label.modulate = Color(0.4, 1, 0.6, 1)  # Green when wandering
				"KITING", "ESCAPING", "RETREATING":
					autobot_label.modulate = Color(0.4, 0.8, 1, 1)  # Blue when defensive
				"LAST_STAND":
					autobot_label.modulate = Color(1, 0.2, 0.8, 1)  # Purple for last stand
				_:
					autobot_label.modulate = Color(0.7, 0.7, 0.7, 1)  # Gray for other
		else:
			autobot_label.text = "[AutoBot: OFF]\nF1=Bot | F3=Hide"
			autobot_label.modulate = Color(1, 0.5, 0.4, 1)
