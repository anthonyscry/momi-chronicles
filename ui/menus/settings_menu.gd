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


## Close the settings menu
func _close_menu() -> void:
	queue_free()
