extends Node2D
## Test scene for verifying NPC dialogue interaction.
##
## This scene tests the connection between NPCBase and DialogueManager.
## Press WASD to move the test player, approach the NPC, and press E to interact.

@onready var test_player: CharacterBody2D = $TestPlayer

# Player movement speed
const MOVE_SPEED = 100.0

func _ready() -> void:
	# Load the example dialogue file
	var dialogue_loaded = DialogueManager.load_dialogue_file("res://data/dialogues/example_dialogue.json")
	if dialogue_loaded:
		print("Test Scene: Example dialogue file loaded successfully")
	else:
		push_error("Test Scene: Failed to load example dialogue file")

	# Connect to dialogue events for debugging
	Events.dialogue_started.connect(_on_dialogue_started)
	Events.dialogue_advanced.connect(_on_dialogue_advanced)
	Events.dialogue_ended.connect(_on_dialogue_ended)
	Events.dialogue_choice_made.connect(_on_dialogue_choice_made)

	print("Test Scene: Ready. Use WASD to move, E to interact with NPC")

func _physics_process(_delta: float) -> void:
	# Simple player movement for testing
	if not test_player:
		return

	var velocity = Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * MOVE_SPEED

	test_player.velocity = velocity
	test_player.move_and_slide()

## Debug: Print when dialogue starts
func _on_dialogue_started(dialogue: DialogueResource) -> void:
	print("Test Scene: Dialogue started - ", dialogue.character_name, ": ", dialogue.dialogue_text)

## Debug: Print when dialogue advances
func _on_dialogue_advanced(dialogue: DialogueResource) -> void:
	print("Test Scene: Dialogue advanced - ", dialogue.character_name, ": ", dialogue.dialogue_text)

## Debug: Print when dialogue ends
func _on_dialogue_ended() -> void:
	print("Test Scene: Dialogue ended")

## Debug: Print when choice is made
func _on_dialogue_choice_made(choice_index: int, choice: Dictionary) -> void:
	print("Test Scene: Choice made - ", choice_index, ": ", choice["text"])
