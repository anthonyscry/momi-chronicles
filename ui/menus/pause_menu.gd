extends CanvasLayer
## Pause menu overlay with Resume, Change Difficulty, Options, and Quit buttons.
## Toggles with ESC key, pauses game tree when visible.

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when resume is clicked
signal resumed()

# =============================================================================
# CONSTANTS
# =============================================================================

const SETTINGS_MENU_SCENE: PackedScene = preload("res://ui/menus/settings_menu.tscn")

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
var settings_menu_instance: Node = null

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Start hidden
	visible = false
	is_paused = false

	# Set process mode to always process even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	change_difficulty_button.pressed.connect(_on_change_difficulty_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Connect difficulty selection signal
	difficulty_selection.difficulty_selected.connect(_on_difficulty_selected)

	# Hide difficulty selection initially
	difficulty_selection.visible = false


func _unhandled_input(event: InputEvent) -> void:
	# Toggle pause with ESC key
	if event.is_action_pressed("pause"):
		if difficulty_selection.visible:
			# If difficulty selection is open, close it instead
			_close_difficulty_selection()
			get_viewport().set_input_as_handled()
		elif settings_menu_instance != null and is_instance_valid(settings_menu_instance):
			# Let settings menu handle its own close
			pass
		else:
			toggle_pause()
			get_viewport().set_input_as_handled()

# =============================================================================
# PUBLIC METHODS
# =============================================================================

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

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_resume_pressed() -> void:
	unpause()


func _on_change_difficulty_pressed() -> void:
	# Show difficulty selection overlay
	difficulty_selection.visible = true
	difficulty_selection.set_current_difficulty(DifficultyManager.get_difficulty())
	panel.visible = false


func _on_options_pressed() -> void:
	# Open settings menu
	if settings_menu_instance == null or not is_instance_valid(settings_menu_instance):
		settings_menu_instance = SETTINGS_MENU_SCENE.instantiate()
		add_child(settings_menu_instance)
		settings_menu_instance.tree_exited.connect(_on_settings_menu_closed)
		# Hide pause panel while settings are open
		panel.visible = false


func _on_settings_menu_closed() -> void:
	settings_menu_instance = null
	# Show pause panel again
	panel.visible = true
	# Return focus to Options button
	if is_instance_valid(options_button):
		options_button.grab_focus()


func _on_quit_pressed() -> void:
	# Quit to title screen
	unpause()
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://ui/menus/title_screen.tscn")


func _on_difficulty_selected(level: DifficultySettings.Difficulty) -> void:
	# Apply new difficulty
	DifficultyManager.set_difficulty(level)
	DebugLogger.log_ui("Difficulty changed to: %s" % DifficultySettings.get_difficulty_name(level))
	# Close difficulty selection and return to pause menu
	_close_difficulty_selection()

# =============================================================================
# PRIVATE METHODS
# =============================================================================

func _close_difficulty_selection() -> void:
	difficulty_selection.visible = false
	panel.visible = true
	resume_button.grab_focus()
