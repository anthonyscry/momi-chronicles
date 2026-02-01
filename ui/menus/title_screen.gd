extends CanvasLayer
class_name TitleScreen
## Main title screen menu.
## Provides options to start a new game, continue a saved game, access settings, or quit.

## Button references
@onready var new_game_button: Button = $CenterContainer/VBoxContainer/ButtonContainer/NewGameButton
@onready var continue_button: Button = $CenterContainer/VBoxContainer/ButtonContainer/ContinueButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/ButtonContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/ButtonContainer/QuitButton

## Settings menu scene reference
const SETTINGS_MENU_SCENE: PackedScene = preload("res://ui/menus/settings_menu.tscn")

## Current settings menu instance (if open)
var settings_menu_instance: SettingsMenu = null


func _ready() -> void:
	# Connect button signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Check if a save file exists and enable/disable Continue button accordingly
	_update_continue_button()

	# Focus the first available button for keyboard navigation
	if continue_button.disabled:
		new_game_button.grab_focus()
	else:
		continue_button.grab_focus()


## Update Continue button availability based on save file existence
func _update_continue_button() -> void:
	# Check if SaveManager exists and has a save file
	if is_instance_valid(SaveManager):
		var save_exists: bool = SaveManager.save_exists()
		continue_button.disabled = not save_exists
	else:
		# If SaveManager doesn't exist yet, disable Continue button
		continue_button.disabled = true


## Called when New Game button is pressed
func _on_new_game_pressed() -> void:
	# TODO: Start a new game
	# For now, just print a message - this will be implemented when game scenes are ready
	print("TitleScreen: New Game pressed - game scene loading not yet implemented")

	# Example implementation when ready:
	# if is_instance_valid(GameManager):
	#     GameManager.start_new_game()
	# else:
	#     get_tree().change_scene_to_file("res://levels/starter_zone.tscn")


## Called when Continue button is pressed
func _on_continue_pressed() -> void:
	# Load the most recent save
	if is_instance_valid(SaveManager):
		print("TitleScreen: Loading saved game...")
		SaveManager.load_game()
	else:
		push_error("TitleScreen: SaveManager not available")


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


## Called when Quit button is pressed
func _on_quit_pressed() -> void:
	print("TitleScreen: Quitting game...")
	get_tree().quit()
