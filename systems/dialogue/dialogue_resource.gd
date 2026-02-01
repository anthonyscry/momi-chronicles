extends Resource
class_name DialogueResource
## Resource representing a single dialogue entry with character, text, and branching options.
##
## This resource stores all data for a dialogue node in a conversation tree.
## It can be used standalone or loaded from JSON dialogue files.

## Name of the character speaking this dialogue
@export var character_name: String = ""

## Path to the character's portrait image (relative to res://)
@export var portrait_path: String = ""

## The dialogue text to display
@export var dialogue_text: String = ""

## Array of choice dictionaries for branching dialogue.
## Each choice should have: { "text": String, "next_id": String }
@export var choices: Array[Dictionary] = []

## ID of the next dialogue to show (used for linear dialogue chains)
## If choices array is not empty, this is ignored in favor of choice-based navigation
@export var next_dialogue_id: String = ""

## Unique identifier for this dialogue entry
@export var dialogue_id: String = ""

## Whether this dialogue should trigger cutscene mode (disable player input)
@export var is_cutscene: bool = false


func _init(
	p_dialogue_id: String = "",
	p_character_name: String = "",
	p_portrait_path: String = "",
	p_dialogue_text: String = "",
	p_choices: Array[Dictionary] = [],
	p_next_dialogue_id: String = "",
	p_is_cutscene: bool = false
) -> void:
	dialogue_id = p_dialogue_id
	character_name = p_character_name
	portrait_path = p_portrait_path
	dialogue_text = p_dialogue_text
	choices = p_choices
	next_dialogue_id = p_next_dialogue_id
	is_cutscene = p_is_cutscene


## Returns true if this dialogue has branching choices
func has_choices() -> bool:
	return choices.size() > 0


## Returns true if this is the end of a dialogue chain (no next dialogue)
func is_end() -> bool:
	return next_dialogue_id.is_empty() and not has_choices()


## Validates the dialogue data
func is_valid() -> bool:
	if dialogue_id.is_empty():
		push_error("DialogueResource: dialogue_id is required")
		return false

	if character_name.is_empty():
		push_warning("DialogueResource: character_name is empty for dialogue '%s'" % dialogue_id)

	if dialogue_text.is_empty():
		push_error("DialogueResource: dialogue_text is required for dialogue '%s'" % dialogue_id)
		return false

	# Validate choices structure
	for choice in choices:
		if not choice.has("text") or not choice.has("next_id"):
			push_error("DialogueResource: Invalid choice format in dialogue '%s'. Choices must have 'text' and 'next_id' fields" % dialogue_id)
			return false

	return true
