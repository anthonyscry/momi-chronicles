extends Node2D
class_name DifficultyTestScene
## Simple test scene for verifying difficulty system works correctly.
## Allows selecting different difficulties and seeing immediate feedback on test enemy.

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var difficulty_panel: PanelContainer = $UI/DifficultyPanel
@onready var difficulty_buttons: VBoxContainer = $UI/DifficultyPanel/MarginContainer/VBoxContainer
@onready var info_label: Label = $UI/InfoPanel/MarginContainer/InfoLabel
@onready var test_enemy: TestEnemy = $TestEnemy
@onready var player_marker: ColorRect = $PlayerMarker

# =============================================================================
# STATE
# =============================================================================

## Current selected difficulty
var current_difficulty: DifficultySettings.Difficulty = DifficultySettings.Difficulty.NORMAL

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Connect to difficulty change events
	Events.difficulty_changed.connect(_on_difficulty_changed)

	# Set up difficulty buttons
	_setup_difficulty_buttons()

	# Add player marker to player group so enemy can find it
	player_marker.add_to_group("player")

	# Initial info update
	_update_info_display()

	print("=== DIFFICULTY TEST SCENE ===")
	print("Click the difficulty buttons to change difficulty and see the effects on the test enemy")
	print("The enemy will attack the player marker with scaled damage")
	print("Watch the console output to see difficulty multipliers in action")


# =============================================================================
# UI SETUP
# =============================================================================

func _setup_difficulty_buttons() -> void:
	# Create buttons for each difficulty level
	_add_difficulty_button("Story Mode", DifficultySettings.Difficulty.STORY,
		"Enemy damage: 0.5x | Drops: 2.0x | AI speed: 0.7x")

	_add_difficulty_button("Normal", DifficultySettings.Difficulty.NORMAL,
		"Enemy damage: 1.0x | Drops: 1.0x | AI speed: 1.0x")

	_add_difficulty_button("Challenge", DifficultySettings.Difficulty.CHALLENGE,
		"Enemy damage: 1.5x | Drops: 0.5x | AI speed: 1.3x")


func _add_difficulty_button(button_text: String, difficulty: DifficultySettings.Difficulty, description: String) -> void:
	# Create button container
	var button_container = VBoxContainer.new()
	button_container.name = "Button_%s" % button_text.replace(" ", "_")
	difficulty_buttons.add_child(button_container)

	# Create button
	var button = Button.new()
	button.name = "Button"
	button.text = button_text
	button.custom_minimum_size = Vector2(200, 40)
	button.pressed.connect(_on_difficulty_button_pressed.bind(difficulty))
	button_container.add_child(button)

	# Create description label
	var desc_label = Label.new()
	desc_label.name = "Description"
	desc_label.text = description
	desc_label.add_theme_font_size_override("font_size", 10)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	button_container.add_child(desc_label)

	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	button_container.add_child(spacer)

	# Highlight if this is the current difficulty
	if difficulty == current_difficulty:
		button.modulate = Color(1.2, 1.2, 0.8)


# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_difficulty_button_pressed(difficulty: DifficultySettings.Difficulty) -> void:
	print("\n--- Changing difficulty to: %s ---" % DifficultySettings.get_difficulty_name(difficulty))
	DifficultyManager.set_difficulty(difficulty)


func _on_difficulty_changed(new_difficulty: int) -> void:
	current_difficulty = new_difficulty
	_update_info_display()
	_update_button_highlights()

	print("Difficulty changed! New multipliers:")
	print("  Damage: %.2fx" % DifficultyManager.get_damage_multiplier())
	print("  Drops: %.2fx" % DifficultyManager.get_drop_multiplier())
	print("  AI Aggression: %.2fx" % DifficultyManager.get_ai_aggression_multiplier())


# =============================================================================
# PRIVATE METHODS
# =============================================================================

func _update_info_display() -> void:
	var difficulty_name = DifficultySettings.get_difficulty_name(current_difficulty)
	var settings = DifficultySettings.get_settings(current_difficulty)

	var info_text = "Current Difficulty: %s\n\n" % difficulty_name
	info_text += "Multipliers Applied:\n"
	info_text += "• Enemy Damage: %.2fx\n" % settings.damage_multiplier
	info_text += "• Health Drops: %.2fx\n" % settings.drop_multiplier
	info_text += "• AI Aggression: %.2fx\n" % settings.ai_aggression_multiplier
	info_text += "\nTest Enemy:\n"
	info_text += "• Base Damage: %.1f\n" % test_enemy.base_damage
	info_text += "• Scaled Damage: %.1f\n" % (test_enemy.base_damage * settings.damage_multiplier)
	info_text += "• Base Cooldown: %.1fs\n" % test_enemy.base_attack_cooldown
	info_text += "• Scaled Cooldown: %.2fs\n" % (test_enemy.base_attack_cooldown / settings.ai_aggression_multiplier)

	info_label.text = info_text


func _update_button_highlights() -> void:
	# Reset all button highlights
	for child in difficulty_buttons.get_children():
		var button = child.get_node_or_null("Button")
		if button:
			button.modulate = Color.WHITE

	# Highlight current difficulty button
	var button_names = ["Button_Story_Mode", "Button_Normal", "Button_Challenge"]
	var difficulty_index = current_difficulty

	if difficulty_index >= 0 and difficulty_index < button_names.size():
		var button_container = difficulty_buttons.get_node_or_null(button_names[difficulty_index])
		if button_container:
			var button = button_container.get_node_or_null("Button")
			if button:
				button.modulate = Color(1.2, 1.2, 0.8)
