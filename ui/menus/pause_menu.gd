extends CanvasLayer
class_name PauseMenu
## Pause menu displayed during gameplay.
## Provides options to resume, access settings, or return to title screen.

## Button references
@onready var resume_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/ButtonContainer/ResumeButton
@onready var settings_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/ButtonContainer/SettingsButton
@onready var quit_to_title_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/ButtonContainer/QuitToTitleButton

## Settings menu scene reference
const SETTINGS_MENU_SCENE: PackedScene = preload("res://ui/menus/settings_menu.tscn")

## Current settings menu instance (if open)
var settings_menu_instance: SettingsMenu = null


func _ready() -> void:
	# Pause the game when menu appears
	get_tree().paused = true

	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_to_title_button.pressed.connect(_on_quit_to_title_pressed)

	# Focus the Resume button for keyboard navigation
	resume_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	# ESC resumes the game (closes pause menu)
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		# Only handle if settings menu is not open
		if settings_menu_instance == null or not is_instance_valid(settings_menu_instance):
			_resume_game()
			get_viewport().set_input_as_handled()


## Called when Resume button is pressed
func _on_resume_pressed() -> void:
	_resume_game()


## Called when Settings button is pressed
func _on_settings_pressed() -> void:
	# Open settings menu if not already open
	if settings_menu_instance == null or not is_instance_valid(settings_menu_instance):
		settings_menu_instance = SETTINGS_MENU_SCENE.instantiate()
		add_child(settings_menu_instance)

		# Connect to the settings menu's tree_exited signal to clear our reference
		settings_menu_instance.tree_exited.connect(_on_settings_menu_closed)


## Called when settings menu is closed
func _on_settings_menu_closed() -> void:
	settings_menu_instance = null
	# Return focus to Settings button for keyboard navigation
	if is_instance_valid(settings_button):
		settings_button.grab_focus()


## Called when Quit to Title button is pressed
func _on_quit_to_title_pressed() -> void:
	# Unpause before changing scenes
	get_tree().paused = false

	# Change to title screen
	print("PauseMenu: Returning to title screen...")
	get_tree().change_scene_to_file("res://ui/menus/title_screen.tscn")


## Resume the game and close the pause menu
func _resume_game() -> void:
	# Unpause the game
	get_tree().paused = false

	# Remove the pause menu
	queue_free()
