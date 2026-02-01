extends CanvasLayer
class_name SettingsMenu
## Settings menu for audio, video, and control configuration.
## Displays current settings and allows real-time adjustment.

## Audio controls
@onready var master_slider: HSlider = $CenterContainer/Panel/MarginContainer/VBoxContainer/AudioSection/MasterVolumeContainer/MasterVolumeSlider
@onready var master_value_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/AudioSection/MasterVolumeContainer/MasterVolumeValue
@onready var music_slider: HSlider = $CenterContainer/Panel/MarginContainer/VBoxContainer/AudioSection/MusicVolumeContainer/MusicVolumeSlider
@onready var music_value_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/AudioSection/MusicVolumeContainer/MusicVolumeValue
@onready var sfx_slider: HSlider = $CenterContainer/Panel/MarginContainer/VBoxContainer/AudioSection/SFXVolumeContainer/SFXVolumeSlider
@onready var sfx_value_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/AudioSection/SFXVolumeContainer/SFXVolumeValue

## Video controls
@onready var fullscreen_checkbox: CheckBox = $CenterContainer/Panel/MarginContainer/VBoxContainer/VideoSection/FullscreenContainer/FullscreenCheckBox
@onready var screen_shake_slider: HSlider = $CenterContainer/Panel/MarginContainer/VBoxContainer/VideoSection/ScreenShakeContainer/ScreenShakeSlider
@onready var screen_shake_value_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/VideoSection/ScreenShakeContainer/ScreenShakeValue

## Buttons
@onready var close_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/ButtonContainer/CloseButton

## Controls panel
@onready var controls_grid: GridContainer = $CenterContainer/Panel/MarginContainer/VBoxContainer/ControlsSection/ControlsPanel/ControlsGrid


func _ready() -> void:
	# Load current settings from SettingsManager
	_populate_settings()

	# Connect audio slider signals
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)

	# Connect video control signals
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	screen_shake_slider.value_changed.connect(_on_screen_shake_changed)

	# Connect button signals
	close_button.pressed.connect(_on_close_pressed)

	# Populate controls reference panel from InputMap
	_populate_controls_panel()


func _unhandled_input(event: InputEvent) -> void:
	# ESC closes the settings menu
	if event.is_action_pressed("ui_cancel"):
		_close_menu()
		get_viewport().set_input_as_handled()


## Populate all controls with current settings values
func _populate_settings() -> void:
	if not is_instance_valid(SettingsManager):
		push_error("SettingsMenu: SettingsManager not available")
		return

	# Audio settings
	master_slider.value = SettingsManager.get_master_volume()
	music_slider.value = SettingsManager.get_music_volume()
	sfx_slider.value = SettingsManager.get_sfx_volume()

	# Update labels (sliders won't emit value_changed on set, so update manually)
	_update_volume_label(master_value_label, master_slider.value)
	_update_volume_label(music_value_label, music_slider.value)
	_update_volume_label(sfx_value_label, sfx_slider.value)

	# Video settings
	fullscreen_checkbox.button_pressed = SettingsManager.get_fullscreen()
	screen_shake_slider.value = SettingsManager.get_screen_shake_intensity()
	_update_screen_shake_label(screen_shake_slider.value)


## Update volume percentage label
func _update_volume_label(label: Label, value: float) -> void:
	if label:
		label.text = "%d%%" % int(value * 100)


## Update screen shake intensity label
func _update_screen_shake_label(value: float) -> void:
	if not screen_shake_value_label:
		return

	# Convert 0.0-1.0 to Off/Low/Medium/High
	# Slider step is 0.33, so we get roughly 4 steps
	if value <= 0.0:
		screen_shake_value_label.text = "Off"
	elif value <= 0.35:
		screen_shake_value_label.text = "Low"
	elif value <= 0.65:
		screen_shake_value_label.text = "Medium"
	else:
		screen_shake_value_label.text = "High"


## Called when master volume slider changes
func _on_master_volume_changed(value: float) -> void:
	_update_volume_label(master_value_label, value)
	SettingsManager.set_master_volume(value)


## Called when music volume slider changes
func _on_music_volume_changed(value: float) -> void:
	_update_volume_label(music_value_label, value)
	SettingsManager.set_music_volume(value)


## Called when SFX volume slider changes
func _on_sfx_volume_changed(value: float) -> void:
	_update_volume_label(sfx_value_label, value)
	SettingsManager.set_sfx_volume(value)


## Called when fullscreen checkbox is toggled
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	SettingsManager.set_fullscreen(toggled_on)


## Called when screen shake slider changes
func _on_screen_shake_changed(value: float) -> void:
	_update_screen_shake_label(value)
	SettingsManager.set_screen_shake_intensity(value)


## Called when close button is pressed
func _on_close_pressed() -> void:
	_close_menu()


## Populate the controls reference panel with key bindings from InputMap
func _populate_controls_panel() -> void:
	if not controls_grid:
		push_error("SettingsMenu: ControlsGrid not found")
		return

	# Clear existing controls (from scene template)
	for child in controls_grid.get_children():
		child.queue_free()

	# Define the actions we want to display with friendly names
	var actions_to_display: Array[Dictionary] = [
		{"action": "move_up", "label": "Move Up"},
		{"action": "move_down", "label": "Move Down"},
		{"action": "move_left", "label": "Move Left"},
		{"action": "move_right", "label": "Move Right"},
		{"action": "run", "label": "Run"},
		{"action": "attack", "label": "Attack"},
		{"action": "special_attack", "label": "Special Attack"},
		{"action": "dodge", "label": "Dodge"},
		{"action": "block", "label": "Block"},
		{"action": "interact", "label": "Interact"},
		{"action": "ring_menu", "label": "Ring Menu"},
		{"action": "cycle_companion", "label": "Cycle Companion"},
		{"action": "pause", "label": "Pause"},
	]

	# Create label pairs for each action
	for action_data in actions_to_display:
		var action_name: String = action_data["action"]
		var display_label: String = action_data["label"]

		# Skip if action doesn't exist in InputMap
		if not InputMap.has_action(action_name):
			continue

		# Create action label (left column)
		var action_label := Label.new()
		action_label.text = display_label + ":"
		action_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75, 1))
		action_label.add_theme_font_size_override("font_size", 12)
		controls_grid.add_child(action_label)

		# Get all input events for this action
		var events: Array[InputEvent] = InputMap.action_get_events(action_name)
		var key_names: Array[String] = []

		for event in events:
			if event is InputEventKey:
				var key_event := event as InputEventKey
				key_names.append(_get_key_name(key_event.physical_keycode))
			elif event is InputEventMouseButton:
				var mouse_event := event as InputEventMouseButton
				key_names.append(_get_mouse_button_name(mouse_event.button_index))

		# Create keys label (right column)
		var keys_label := Label.new()
		keys_label.text = " / ".join(key_names) if key_names.size() > 0 else "Not bound"
		keys_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65, 1))
		keys_label.add_theme_font_size_override("font_size", 12)
		controls_grid.add_child(keys_label)


## Convert a keycode to a readable key name
func _get_key_name(keycode: int) -> String:
	match keycode:
		KEY_SPACE:
			return "Space"
		KEY_SHIFT:
			return "Shift"
		KEY_ESCAPE:
			return "ESC"
		KEY_ENTER:
			return "Enter"
		KEY_TAB:
			return "Tab"
		KEY_UP:
			return "Up"
		KEY_DOWN:
			return "Down"
		KEY_LEFT:
			return "Left"
		KEY_RIGHT:
			return "Right"
		_:
			# For letter keys and others, use OS.get_keycode_string
			var key_string := OS.get_keycode_string(keycode)
			# Capitalize single letters
			if key_string.length() == 1:
				return key_string.to_upper()
			return key_string


## Convert a mouse button index to a readable name
func _get_mouse_button_name(button_index: int) -> String:
	match button_index:
		MOUSE_BUTTON_LEFT:
			return "LMB"
		MOUSE_BUTTON_RIGHT:
			return "RMB"
		MOUSE_BUTTON_MIDDLE:
			return "MMB"
		_:
			return "Mouse " + str(button_index)


## Close the settings menu
func _close_menu() -> void:
	queue_free()
