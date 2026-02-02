extends CanvasLayer
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
	quit_button.pressed.connect(_on_quit_pressed)

	# Connect difficulty selection signal
	difficulty_selection.difficulty_selected.connect(_on_difficulty_selected)

	# Hide difficulty selection initially
	difficulty_selection.visible = false

	# Check if save file exists to show/hide Continue button
	_update_continue_button()

	# Update difficulty indicator to show current difficulty
	_update_difficulty_indicator()

	# Focus the first available button for keyboard navigation
	if continue_button.disabled:
		new_game_button.grab_focus()
	else:
		continue_button.grab_focus()


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


func _on_continue_pressed() -> void:
	# Load the most recent save
	if is_instance_valid(SaveManager):
		DebugLogger.log_ui("Loading saved game...")
		var success = SaveManager.load_game()
		if success:
			DebugLogger.log_ui("Game loaded successfully")
		else:
			DebugLogger.log_ui("Failed to load save file")
	else:
		DebugLogger.log_ui("SaveManager not available")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_difficulty_selected(level: DifficultySettings.Difficulty) -> void:
	# Set difficulty for new game
	DifficultyManager.set_difficulty(level)
	DebugLogger.log_ui("Starting new game with difficulty: %s" % DifficultySettings.get_difficulty_name(level))

	# Close difficulty selection
	_close_difficulty_selection()

	# Reset game state for new game
	GameManager.reset_game()

	# Start the game — load the first zone
	get_tree().change_scene_to_file("res://world/zones/neighborhood.tscn")

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


