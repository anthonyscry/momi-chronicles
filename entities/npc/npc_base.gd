extends CharacterBody2D
class_name NPCBase
## Base class for NPCs with dialogue interaction support.
##
## NPCs can be interacted with by the player to trigger dialogue.
## Use the interaction_area to detect player proximity and show interaction prompts.

## The dialogue ID to trigger when interacting with this NPC
@export var dialogue_id: String = ""

## The text to display in the interaction prompt
@export var prompt_text: String = "[E]"

## How far above the NPC to show the prompt (in pixels)
@export var prompt_offset: float = -40.0

## Reference to the interaction area that detects the player
@onready var interaction_area: Area2D = $InteractionArea

## The interaction prompt label
var _prompt_label: Label = null

## Tracks if the player is currently in the interaction area
var _player_in_range: bool = false

## Tracks if dialogue is currently active
var _dialogue_active: bool = false

func _ready() -> void:
	# Create interaction prompt
	_create_prompt_label()

	# Connect interaction area signals
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)

	# Connect to dialogue events
	Events.dialogue_started.connect(_on_dialogue_started)
	Events.dialogue_ended.connect(_on_dialogue_ended)

func _process(_delta: float) -> void:
	# Check for interact input when player is in range
	if _player_in_range and not _dialogue_active:
		if Input.is_action_just_pressed("interact"):
			_trigger_dialogue()

## Triggered when the player enters the interaction area
func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_show_interaction_prompt()

## Triggered when the player exits the interaction area
func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_hide_interaction_prompt()

## Start the dialogue when the player interacts
func _trigger_dialogue() -> void:
	if dialogue_id.is_empty():
		push_warning("NPCBase: No dialogue_id set for NPC at ", global_position)
		return

	DialogueManager.start_dialogue(dialogue_id)

## Called when dialogue starts
func _on_dialogue_started(_dialogue: DialogueResource) -> void:
	_dialogue_active = true
	_hide_interaction_prompt()

## Called when dialogue ends
func _on_dialogue_ended() -> void:
	_dialogue_active = false
	# Re-show prompt if player is still in range
	if _player_in_range:
		_show_interaction_prompt()

## Creates the interaction prompt label
func _create_prompt_label() -> void:
	_prompt_label = Label.new()
	_prompt_label.text = prompt_text
	_prompt_label.modulate = Color.WHITE
	_prompt_label.position = Vector2(0, prompt_offset)

	# Center the label horizontally
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Set up label style for better visibility
	_prompt_label.add_theme_font_size_override("font_size", 16)

	# Start hidden
	_prompt_label.modulate.a = 0.0
	_prompt_label.visible = false

	add_child(_prompt_label)

## Show the interaction prompt with fade-in animation
func _show_interaction_prompt() -> void:
	if not _prompt_label:
		return

	_prompt_label.visible = true

	# Fade in animation
	var tween = create_tween()
	tween.tween_property(_prompt_label, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT)

## Hide the interaction prompt with fade-out animation
func _hide_interaction_prompt() -> void:
	if not _prompt_label:
		return

	# Fade out animation
	var tween = create_tween()
	tween.tween_property(_prompt_label, "modulate:a", 0.0, 0.15).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): _prompt_label.visible = false)
