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
var buff_icons: BuffIcons

## Whether debug panel is visible
var debug_visible: bool = true

func _ready() -> void:
	# Show debug by default (can toggle with F3)
	debug_panel.visible = debug_visible
	
	# Create low HP vignette overlay
	_setup_low_hp_vignette()
	
	# Create buff icons display
	_setup_buff_icons()
	
	# Connect to health changes
	Events.player_health_changed.connect(_on_health_changed)


func _unhandled_input(event: InputEvent) -> void:
	# F3 toggles debug panel
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			debug_visible = not debug_visible
			debug_panel.visible = debug_visible
			print("[HUD] Debug panel: %s (F3 to toggle)" % ("ON" if debug_visible else "OFF"))


func _setup_buff_icons() -> void:
	buff_icons = BuffIcons.new()
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
