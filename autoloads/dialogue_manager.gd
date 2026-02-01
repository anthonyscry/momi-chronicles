extends Node
## DialogueManager singleton - Manages dialogue state and flow.
##
## This autoload singleton handles loading dialogue data, tracking the current dialogue,
## advancing through dialogue chains, managing player choices, and controlling cutscene mode.
## It emits signals via the Events autoload to notify other systems of dialogue state changes.

## Dictionary storing all loaded dialogues, keyed by dialogue_id
var _dialogues: Dictionary = {}

## Current active dialogue being displayed
var _current_dialogue: DialogueResource = null

## Whether the dialogue system is currently active
var _is_active: bool = false

## Whether we're currently in cutscene mode (player input disabled)
var _in_cutscene: bool = false


func _ready() -> void:
	# Load any initial dialogue files here if needed
	pass


## Load a dialogue file and add its dialogues to the manager.
##
## @param file_path: Path to the JSON dialogue file (e.g., "res://data/dialogues/npc_dialogue.json")
## @returns true if loading succeeded, false otherwise
func load_dialogue_file(file_path: String) -> bool:
	var loaded_dialogues = DialogueData.load_dialogue_file(file_path)
	if loaded_dialogues.is_empty():
		push_error("DialogueManager: Failed to load dialogue file: %s" % file_path)
		return false

	# Merge loaded dialogues into our dictionary
	for dialogue_id in loaded_dialogues:
		if _dialogues.has(dialogue_id):
			push_warning("DialogueManager: Overwriting existing dialogue_id '%s' from %s" % [dialogue_id, file_path])
		_dialogues[dialogue_id] = loaded_dialogues[dialogue_id]

	return true


## Load multiple dialogue files at once.
##
## @param file_paths: Array of file paths to load
## @returns true if at least one file loaded successfully
func load_multiple_files(file_paths: Array) -> bool:
	var success_count = 0
	for file_path in file_paths:
		if load_dialogue_file(file_path):
			success_count += 1
	return success_count > 0


## Start a dialogue by its ID.
##
## @param dialogue_id: The ID of the dialogue to start
## @returns true if dialogue started successfully, false if dialogue not found
func start_dialogue(dialogue_id: String) -> bool:
	if not _dialogues.has(dialogue_id):
		push_error("DialogueManager: Dialogue ID '%s' not found" % dialogue_id)
		return false

	var dialogue = _dialogues[dialogue_id]
	if not dialogue.is_valid():
		push_error("DialogueManager: Dialogue '%s' is invalid" % dialogue_id)
		return false

	_current_dialogue = dialogue
	_is_active = true

	# Handle cutscene mode
	if dialogue.is_cutscene and not _in_cutscene:
		_enter_cutscene_mode()

	# Emit signal that dialogue has started
	Events.dialogue_started.emit(dialogue)

	return true


## Advance to the next dialogue in a linear chain.
##
## @returns true if advanced successfully, false if at end of dialogue
func advance_dialogue() -> bool:
	if not _is_active or _current_dialogue == null:
		push_warning("DialogueManager: Cannot advance - no active dialogue")
		return false

	# If current dialogue has choices, we can't auto-advance
	if _current_dialogue.has_choices():
		push_warning("DialogueManager: Cannot advance - dialogue has choices. Use make_choice() instead")
		return false

	# Check if there's a next dialogue
	if _current_dialogue.next_dialogue_id.is_empty():
		# End of dialogue chain
		end_dialogue()
		return false

	# Load next dialogue
	var next_id = _current_dialogue.next_dialogue_id
	if not _dialogues.has(next_id):
		push_error("DialogueManager: Next dialogue '%s' not found" % next_id)
		end_dialogue()
		return false

	_current_dialogue = _dialogues[next_id]

	# Check if new dialogue triggers cutscene mode
	if _current_dialogue.is_cutscene and not _in_cutscene:
		_enter_cutscene_mode()

	# Emit signal that dialogue advanced
	Events.dialogue_advanced.emit(_current_dialogue)

	return true


## Make a choice in branching dialogue.
##
## @param choice_index: Index of the choice to make (0-based)
## @returns true if choice was valid and dialogue advanced
func make_choice(choice_index: int) -> bool:
	if not _is_active or _current_dialogue == null:
		push_warning("DialogueManager: Cannot make choice - no active dialogue")
		return false

	if not _current_dialogue.has_choices():
		push_warning("DialogueManager: Current dialogue has no choices")
		return false

	if choice_index < 0 or choice_index >= _current_dialogue.choices.size():
		push_error("DialogueManager: Invalid choice index %d (choices: %d)" % [choice_index, _current_dialogue.choices.size()])
		return false

	var choice = _current_dialogue.choices[choice_index]
	var next_id = choice["next_id"]

	# Emit signal that choice was made
	Events.dialogue_choice_made.emit(choice_index, choice)

	# If next_id is empty, end dialogue
	if next_id.is_empty():
		end_dialogue()
		return true

	# Load next dialogue
	if not _dialogues.has(next_id):
		push_error("DialogueManager: Next dialogue '%s' not found" % next_id)
		end_dialogue()
		return false

	_current_dialogue = _dialogues[next_id]

	# Check if new dialogue triggers cutscene mode
	if _current_dialogue.is_cutscene and not _in_cutscene:
		_enter_cutscene_mode()

	# Emit signal that dialogue advanced
	Events.dialogue_advanced.emit(_current_dialogue)

	return true


## End the current dialogue.
func end_dialogue() -> void:
	if not _is_active:
		return

	_is_active = false
	var was_cutscene = _in_cutscene

	# Exit cutscene mode if active
	if _in_cutscene:
		_exit_cutscene_mode()

	# Emit signal that dialogue ended
	Events.dialogue_ended.emit()

	_current_dialogue = null


## Get the current active dialogue.
##
## @returns The current DialogueResource, or null if no dialogue is active
func get_current_dialogue() -> DialogueResource:
	return _current_dialogue


## Check if dialogue system is currently active.
##
## @returns true if a dialogue is currently being displayed
func is_dialogue_active() -> bool:
	return _is_active


## Check if currently in cutscene mode.
##
## @returns true if cutscene mode is active (player input should be disabled)
func is_in_cutscene() -> bool:
	return _in_cutscene


## Enter cutscene mode (disables player input).
func _enter_cutscene_mode() -> void:
	if _in_cutscene:
		return

	_in_cutscene = true
	# Emit signal that cutscene started
	Events.cutscene_started.emit()


## Exit cutscene mode (re-enables player input).
func _exit_cutscene_mode() -> void:
	if not _in_cutscene:
		return

	_in_cutscene = false
	# Emit signal that cutscene ended
	Events.cutscene_ended.emit()


## Clear all loaded dialogues (useful for cleanup or testing).
func clear_dialogues() -> void:
	_dialogues.clear()
	if _is_active:
		end_dialogue()


## Get the total number of loaded dialogues.
##
## @returns Count of loaded dialogue entries
func get_dialogue_count() -> int:
	return _dialogues.size()


## Check if a dialogue ID exists in loaded dialogues.
##
## @param dialogue_id: The dialogue ID to check
## @returns true if the dialogue exists
func has_dialogue(dialogue_id: String) -> bool:
	return _dialogues.has(dialogue_id)
