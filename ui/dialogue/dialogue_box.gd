extends CanvasLayer
class_name DialogueBox
## Displays dialogue text with typewriter effect and character portraits.
## Supports skip-ahead on input and connects to DialogueManager for flow control.

## UI references
@onready var panel: PanelContainer = $PanelContainer
@onready var character_name_label: Label = $PanelContainer/MarginContainer/VBoxContainer/CharacterName
@onready var dialogue_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DialogueText
@onready var continue_indicator: Label = $PanelContainer/MarginContainer/VBoxContainer/ContinueIndicator

## Typewriter effect state
var current_text: String = ""
var displayed_characters: int = 0
var typewriter_speed: float = 30.0  ## Characters per second
var typewriter_timer: float = 0.0
var is_typing: bool = false
var typing_complete: bool = false

## Blink animation for continue indicator
var blink_timer: float = 0.0
var blink_visible: bool = true

func _ready() -> void:
	# Start hidden
	hide()

	# Connect to dialogue events
	Events.dialogue_started.connect(_on_dialogue_started)
	Events.dialogue_advanced.connect(_on_dialogue_advanced)
	Events.dialogue_ended.connect(_on_dialogue_ended)

	# Initialize continue indicator
	if continue_indicator:
		continue_indicator.text = "▼"
		continue_indicator.visible = false


func _process(delta: float) -> void:
	if not is_typing:
		# Blink the continue indicator when typing is complete
		if typing_complete and continue_indicator:
			blink_timer += delta
			if blink_timer >= 0.5:
				blink_timer = 0.0
				blink_visible = not blink_visible
				continue_indicator.visible = blink_visible
		return

	# Typewriter effect - reveal characters over time
	typewriter_timer += delta
	var chars_to_show = int(typewriter_timer * typewriter_speed)

	if chars_to_show > displayed_characters:
		displayed_characters = mini(chars_to_show, current_text.length())
		_update_displayed_text()

		# Check if typing is complete
		if displayed_characters >= current_text.length():
			_finish_typing()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	# Accept on any action press (interact, ui_accept, etc.)
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		if is_typing:
			# Skip to end of current text
			_skip_typewriter()
		elif typing_complete:
			# Advance to next dialogue
			DialogueManager.advance_dialogue()
		get_viewport().set_input_as_handled()


func _on_dialogue_started(dialogue: DialogueResource) -> void:
	show()
	_display_dialogue(dialogue)


func _on_dialogue_advanced(dialogue: DialogueResource) -> void:
	_display_dialogue(dialogue)


func _on_dialogue_ended() -> void:
	hide()
	_reset_state()


func _display_dialogue(dialogue: DialogueResource) -> void:
	if not dialogue:
		return

	# Set character name
	if character_name_label:
		character_name_label.text = dialogue.character_name

	# Start typewriter effect for dialogue text
	current_text = dialogue.dialogue_text
	displayed_characters = 0
	typewriter_timer = 0.0
	is_typing = true
	typing_complete = false

	if continue_indicator:
		continue_indicator.visible = false

	_update_displayed_text()


func _update_displayed_text() -> void:
	if dialogue_label:
		dialogue_label.text = current_text.substr(0, displayed_characters)


func _skip_typewriter() -> void:
	# Immediately show all text
	displayed_characters = current_text.length()
	_update_displayed_text()
	_finish_typing()


func _finish_typing() -> void:
	is_typing = false
	typing_complete = true
	blink_timer = 0.0
	blink_visible = true

	if continue_indicator:
		continue_indicator.visible = true


func _reset_state() -> void:
	current_text = ""
	displayed_characters = 0
	typewriter_timer = 0.0
	is_typing = false
	typing_complete = false

	if dialogue_label:
		dialogue_label.text = ""
	if character_name_label:
		character_name_label.text = ""
	if continue_indicator:
		continue_indicator.visible = false
