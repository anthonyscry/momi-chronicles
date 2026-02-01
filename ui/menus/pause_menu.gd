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
## Pause menu overlay with Resume, Change Difficulty, Options, and Quit buttons.
## Toggles with ESC key, pauses game tree when visible.

# ======================================================================# SIGNALS
# =============================================================================

## Emitted when resume is clicked
signal resumed()

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var panel: PanelContainer = $PausePanel
@onready var resume_button: Button = $PausePanel/MarginContainer/VBoxContainer/ResumeButton
@onready var change_difficulty_button: Button = $PausePanel/MarginContainer/VBoxContainer/ChangeDifficultyButton
@onready var options_button: Button = $PausePanel/MarginContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $PausePanel/MarginContainer/VBoxContainer/QuitButton
@onready var difficulty_selection: DifficultySelection = $DifficultySelection

# =============================================================================
# STATE
# =============================================================================

var is_paused: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Start hidden
	visible = false
	is_paused = false

	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	change_difficulty_button.pressed.connect(_on_change_difficulty_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
=======
## Pause menu overlay with tabs for quest log and other pause menu features.
## Press ESC to open/close. Pauses game tree when visible.

## Container for tab content
@onready var panel: PanelContainer = $CenterContainer/PanelContainer
@onready var tab_container: TabContainer = $CenterContainer/PanelContainer/MarginContainer/TabContainer
@onready var resume_button: Button = $CenterContainer/PanelContainer/MarginContainer/TabContainer/General/VBoxContainer/ResumeButton

## Whether menu is currently visible
var is_paused: bool = false


func _ready() -> void:
	# Hide menu by default
	visible = false
	is_paused = false

	# Set process mode to always process even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect resume button
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)

	# Connect difficulty selection signal
	difficulty_selection.difficulty_selected.connect(_on_difficulty_selected)

	# Hide difficulty selection initially
	difficulty_selection.visible = false
func _unhandled_input(event: InputEvent) -> void:
	# Toggle pause menu with ESC key
	if event.is_action_pressed("pause"):
		_toggle_pause()
		get_viewport().set_input_as_handled()

	# Focus resume button when menu opens
	visibility_changed.connect(_on_visibility_changed)

func _unhandled_input(event: InputEvent) -> void:
	# Toggle pause with ESC key
	if event.is_action_pressed("pause"):
		if difficulty_selection.visible:
			# If difficulty selection is open, close it instead
			_close_difficulty_selection()
			get_viewport().set_input_as_handled()
		else:
			toggle_pause()
			get_viewport().set_input_as_handled()

# ======================================================================# PUBLIC METHODS
# =============================================================================
=======
func _toggle_pause() -> void:
	is_paused = not is_paused

	if is_paused:
		_open_menu()
	else:
		_close_menu()

## Toggle pause menu on/off
func toggle_pause() -> void:
	if is_paused:
		unpause()
	else:
		pause()

## Show pause menu and pause game
func pause() -> void:
	is_paused = true
	visible = true
	get_tree().paused = true

	# Focus resume button
	resume_button.grab_focus()

## Hide pause menu and unpause game
func unpause() -> void:
	is_paused = false
	visible = false
	difficulty_selection.visible = false
	get_tree().paused = false
	resumed.emit()

func _unhandled_input(event: InputEvent) -> void:
	# ESC resumes the game (closes pause menu)
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		# Only handle if settings menu is not open
		if settings_menu_instance == null or not is_instance_valid(settings_menu_instance):
			_resume_game()
			get_viewport().set_input_as_handled()
func _open_menu() -> void:
	visible = true
	is_paused = true
	get_tree().paused = true

	# Focus resume button for keyboard navigation
	if resume_button:
		resume_button.grab_focus()


func _close_menu() -> void:
	visible = false
	is_paused = false
	get_tree().paused = false

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

## Called when Resume button is pressed
func _on_resume_pressed() -> void:
	_resume_game()
	unpause()

func _on_change_difficulty_pressed() -> void:
	# Show difficulty selection overlay
	difficulty_selection.visible = true
	difficulty_selection.set_current_difficulty(DifficultyManager.current_difficulty)

## Called when Settings button is pressed
func _on_settings_pressed() -> void:
	# Open settings menu if not already open
	if settings_menu_instance == null or not is_instance_valid(settings_menu_instance):
		settings_menu_instance = SETTINGS_MENU_SCENE.instantiate()
		add_child(settings_menu_instance)

		# Connect to the settings menu's tree_exited signal to clear our reference
		settings_menu_instance.tree_exited.connect(_on_settings_menu_closed)
	# Hide main pause menu buttons (but keep pause menu layer active)
	panel.visible = false

func _on_options_pressed() -> void:
	# TODO: Implement options menu
	DebugLogger.log_ui("Options menu not yet implemented")

## Called when settings menu is closed
func _on_settings_menu_closed() -> void:
	settings_menu_instance = null
	# Return focus to Settings button for keyboard navigation
	if is_instance_valid(settings_button):
		settings_button.grab_focus()
func _on_quit_pressed() -> void:
	# Quit to title screen
	unpause()
	# Reset game state
	GameManager.reset_game()
	# Load title screen
	get_tree().change_scene_to_file("res://ui/menus/title_screen.tscn")

func _on_difficulty_selected(level: DifficultySettings.Difficulty) -> void:
	# Apply new difficulty
	DifficultyManager.set_difficulty(level)
	DebugLogger.log_ui("Difficulty changed to: %s" % DifficultySettings.get_difficulty_name(level))

## Called when Quit to Title button is pressed
func _on_quit_to_title_pressed() -> void:
	# Unpause before changing scenes
	get_tree().paused = false

	# Change to title screen
	print("PauseMenu: Returning to title screen...")
	get_tree().change_scene_to_file("res://ui/menus/title_screen.tscn")
	# Close difficulty selection and return to pause menu
	_close_difficulty_selection()

func _on_visibility_changed() -> void:
	if visible and resume_button:
		resume_button.grab_focus()

## Resume the game and close the pause menu
func _resume_game() -> void:
	# Unpause the game
	get_tree().paused = false

	# Remove the pause menu
	queue_free()
# ======================================================================# PRIVATE METHODS
# =============================================================================

func _close_difficulty_selection() -> void:
	difficulty_selection.visible = false
	panel.visible = true
	resume_button.grab_focus()
=======
	_close_menu()
