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

## Main title screen with New Game, Continue, and difficulty selection.
## Entry point for the game showing menu options and initial difficulty selection.

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var new_game_button: Button = $CenterContainer/VBoxContainer/NewGameButton
@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var difficulty_indicator: Label = $CenterContainer/VBoxContainer/DifficultyIndicator
@onready var main_menu: VBoxContainer = $CenterContainer/VBoxContainer
@onready var difficulty_selection: DifficultySelection = $DifficultySelection

# =============================================================================
# STATE
# =============================================================================

var showing_difficulty_selection: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Connect button signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Connect difficulty selection signal
	difficulty_selection.difficulty_selected.connect(_on_difficulty_selected)

	# Hide difficulty selection initially
	difficulty_selection.visible = false

	# Check if save file exists to show/hide Continue button
	_update_continue_button()

	# Update difficulty indicator to show current difficulty
	_update_difficulty_indicator()

	# Focus New Game button
	new_game_button.grab_focus()

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
func _unhandled_input(event: InputEvent) -> void:
	# ESC closes difficulty selection if open
	if event.is_action_pressed("pause") and showing_difficulty_selection:
		_close_difficulty_selection()
		get_viewport().set_input_as_handled()

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_new_game_pressed() -> void:
	# Show difficulty selection before starting new game
	_show_difficulty_selection()


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
	# Load saved game
	var success = SaveManager.load_game()
	if success:
		# SaveManager will restore difficulty and game state
		# For now, just show a message since there's no actual game scene yet
		DebugLogger.log_ui("Game loaded! (No game scene to load yet)")
		_show_game_start_placeholder()
	else:
		DebugLogger.log_ui("Failed to load save file")


## Called when Quit button is pressed
func _on_quit_pressed() -> void:
	print("TitleScreen: Quitting game...")
	get_tree().quit()
	# Quit the game
	get_tree().quit()


func _on_difficulty_selected(level: DifficultySettings.Difficulty) -> void:
	# Set difficulty for new game
	DifficultyManager.set_difficulty(level)
	DebugLogger.log_ui("Starting new game with difficulty: %s" % DifficultySettings.get_difficulty_name(level))

	# Close difficulty selection
	_close_difficulty_selection()

	# Reset game state for new game
	GameManager.reset_game()

	# Start the game (placeholder for now since no game scene exists yet)
	_show_game_start_placeholder()

# =============================================================================
# PRIVATE METHODS
# =============================================================================

func _update_continue_button() -> void:
	# Show/hide Continue button based on save file existence
	if SaveManager.has_save_file():
		continue_button.visible = true
		continue_button.disabled = false
	else:
		continue_button.visible = false


func _update_difficulty_indicator() -> void:
	# Show current difficulty at bottom of menu
	var current_difficulty = DifficultyManager.get_difficulty()
	var difficulty_name = DifficultySettings.get_difficulty_name(current_difficulty)
	difficulty_indicator.text = "Current Difficulty: %s" % difficulty_name


func _show_difficulty_selection() -> void:
	showing_difficulty_selection = true
	difficulty_selection.visible = true
	difficulty_selection.set_current_difficulty(DifficultyManager.get_difficulty())
	main_menu.visible = false


func _close_difficulty_selection() -> void:
	showing_difficulty_selection = false
	difficulty_selection.visible = false
	main_menu.visible = true
	new_game_button.grab_focus()
	_update_difficulty_indicator()


func _show_game_start_placeholder() -> void:
	# Placeholder message since no actual game scene exists yet
	# In a real game, this would load the first zone/level
	var placeholder = Label.new()
	placeholder.text = "Game would start here!\n(No game scene implemented yet)\n\nPress ESC to return to title"
	placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	placeholder.add_theme_font_size_override("font_size", 16)

	# Center the placeholder
	var container = CenterContainer.new()
	container.anchors_preset = Control.PRESET_FULL_RECT
	container.add_child(placeholder)

	# Hide main menu and show placeholder
	main_menu.visible = false
	difficulty_selection.visible = false
	add_child(container)

	# Wait for ESC to return to title
	var return_to_title = func():
		container.queue_free()
		main_menu.visible = true
		new_game_button.grab_focus()
		_update_continue_button()
		_update_difficulty_indicator()

	# Connect input handler for returning to title
	var input_handler = func(event: InputEvent):
		if event.is_action_pressed("pause"):
			return_to_title.call()
			get_viewport().set_input_as_handled()

	# Store the handler so we can disconnect later
	set_process_unhandled_input(true)
