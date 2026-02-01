extends PanelContainer
class_name DifficultySelection
## UI panel for selecting game difficulty level.
## Displays three difficulty options with descriptions and emits selection signal.

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when a difficulty level is selected
signal difficulty_selected(level: DifficultySettings.Difficulty)

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var story_button: Button = $MarginContainer/VBoxContainer/StoryButton
@onready var story_description: Label = $MarginContainer/VBoxContainer/StoryDescription
@onready var normal_button: Button = $MarginContainer/VBoxContainer/NormalButton
@onready var normal_description: Label = $MarginContainer/VBoxContainer/NormalDescription
@onready var challenge_button: Button = $MarginContainer/VBoxContainer/ChallengeButton
@onready var challenge_description: Label = $MarginContainer/VBoxContainer/ChallengeDescription

# =============================================================================
# STATE
# =============================================================================

var current_difficulty: DifficultySettings.Difficulty = DifficultySettings.Difficulty.NORMAL

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Connect button signals
	story_button.pressed.connect(_on_story_button_pressed)
	normal_button.pressed.connect(_on_normal_button_pressed)
	challenge_button.pressed.connect(_on_challenge_button_pressed)

	# Set up descriptions from DifficultySettings
	_update_descriptions()

	# Highlight current difficulty
	_update_button_states()

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_story_button_pressed() -> void:
	_select_difficulty(DifficultySettings.Difficulty.STORY)

func _on_normal_button_pressed() -> void:
	_select_difficulty(DifficultySettings.Difficulty.NORMAL)

func _on_challenge_button_pressed() -> void:
	_select_difficulty(DifficultySettings.Difficulty.CHALLENGE)

# =============================================================================
# PUBLIC METHODS
# =============================================================================

## Set the currently selected difficulty (updates UI highlighting)
func set_current_difficulty(level: DifficultySettings.Difficulty) -> void:
	current_difficulty = level
	_update_button_states()

# =============================================================================
# PRIVATE METHODS
# =============================================================================

func _select_difficulty(level: DifficultySettings.Difficulty) -> void:
	current_difficulty = level
	_update_button_states()
	difficulty_selected.emit(level)

func _update_descriptions() -> void:
	# Get settings for each difficulty level
	var story_settings = DifficultySettings.get_settings(DifficultySettings.Difficulty.STORY)
	var normal_settings = DifficultySettings.get_settings(DifficultySettings.Difficulty.NORMAL)
	var challenge_settings = DifficultySettings.get_settings(DifficultySettings.Difficulty.CHALLENGE)

	# Update button labels
	story_button.text = story_settings.difficulty_name
	normal_button.text = normal_settings.difficulty_name
	challenge_button.text = challenge_settings.difficulty_name

	# Update descriptions
	story_description.text = story_settings.description
	normal_description.text = normal_settings.description
	challenge_description.text = challenge_settings.description

func _update_button_states() -> void:
	# Reset all buttons to default state
	story_button.modulate = Color(1, 1, 1, 0.7)
	normal_button.modulate = Color(1, 1, 1, 0.7)
	challenge_button.modulate = Color(1, 1, 1, 0.7)

	# Highlight selected button
	match current_difficulty:
		DifficultySettings.Difficulty.STORY:
			story_button.modulate = Color(1, 1, 1, 1)
		DifficultySettings.Difficulty.NORMAL:
			normal_button.modulate = Color(1, 1, 1, 1)
		DifficultySettings.Difficulty.CHALLENGE:
			challenge_button.modulate = Color(1, 1, 1, 1)
