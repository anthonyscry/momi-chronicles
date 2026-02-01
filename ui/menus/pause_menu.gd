extends CanvasLayer
class_name PauseMenu
## Pause menu overlay with Resume, Change Difficulty, Options, and Quit buttons.
## Toggles with ESC key, pauses game tree when visible.

# =============================================================================
# SIGNALS
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

	# Connect difficulty selection signal
	difficulty_selection.difficulty_selected.connect(_on_difficulty_selected)

	# Hide difficulty selection initially
	difficulty_selection.visible = false

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
	difficulty_selection.set_current_difficulty(DifficultyManager.current_difficulty)

	# Hide main pause menu buttons (but keep pause menu layer active)
	panel.visible = false

func _on_options_pressed() -> void:
	# TODO: Implement options menu
	DebugLogger.log_ui("Options menu not yet implemented")

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

	# Close difficulty selection and return to pause menu
	_close_difficulty_selection()

func _on_visibility_changed() -> void:
	if visible and resume_button:
		resume_button.grab_focus()

# =============================================================================
# PRIVATE METHODS
# =============================================================================

func _close_difficulty_selection() -> void:
	difficulty_selection.visible = false
	panel.visible = true
	resume_button.grab_focus()
