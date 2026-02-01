extends RefCounted
class_name DialogueData
## Utility class for loading dialogue data from JSON files.
##
## Provides static methods to load dialogue files and convert them into
## DialogueResource objects for use by the DialogueManager.

## Load dialogue file and return dictionary of DialogueResources keyed by dialogue_id.
##
## @param file_path: Path to the JSON dialogue file (e.g., "res://data/dialogues/npc_dialogue.json")
## @returns Dictionary[String, DialogueResource] mapping dialogue IDs to DialogueResource objects, or empty dict on error
static func load_dialogue_file(file_path: String) -> Dictionary:
	var dialogues: Dictionary = {}

	# Validate file path
	if not FileAccess.file_exists(file_path):
		push_error("DialogueData: File not found: %s" % file_path)
		return dialogues

	# Open and read file
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("DialogueData: Failed to open file: %s (Error: %d)" % [file_path, FileAccess.get_open_error()])
		return dialogues

	var file_content = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(file_content)
	if parse_result != OK:
		push_error("DialogueData: JSON parse error in %s at line %d: %s" % [file_path, json.get_error_line(), json.get_error_message()])
		return dialogues

	var data = json.get_data()

	# Validate JSON structure
	if not data is Dictionary:
		push_error("DialogueData: Root element must be a dictionary in %s" % file_path)
		return dialogues

	if not data.has("dialogues"):
		push_error("DialogueData: Missing 'dialogues' array in %s" % file_path)
		return dialogues

	if not data["dialogues"] is Array:
		push_error("DialogueData: 'dialogues' must be an array in %s" % file_path)
		return dialogues

	# Parse each dialogue entry
	for dialogue_data in data["dialogues"]:
		if not dialogue_data is Dictionary:
			push_warning("DialogueData: Skipping non-dictionary dialogue entry in %s" % file_path)
			continue

		var dialogue_resource = _parse_dialogue_entry(dialogue_data, file_path)
		if dialogue_resource and dialogue_resource.is_valid():
			if dialogues.has(dialogue_resource.dialogue_id):
				push_warning("DialogueData: Duplicate dialogue_id '%s' in %s - overwriting previous entry" % [dialogue_resource.dialogue_id, file_path])
			dialogues[dialogue_resource.dialogue_id] = dialogue_resource

	if dialogues.is_empty():
		push_warning("DialogueData: No valid dialogues loaded from %s" % file_path)

	return dialogues


## Parse a single dialogue entry from JSON data into a DialogueResource.
##
## @param data: Dictionary containing dialogue entry data
## @param file_path: Source file path for error reporting
## @returns DialogueResource instance or null on parse error
static func _parse_dialogue_entry(data: Dictionary, file_path: String) -> DialogueResource:
	# Extract required fields
	var dialogue_id = data.get("id", "")
	if dialogue_id.is_empty():
		push_error("DialogueData: Missing 'id' field in dialogue entry in %s" % file_path)
		return null

	var character_name = data.get("character", "")
	var portrait_path = data.get("portrait", "")
	var dialogue_text = data.get("text", "")

	if dialogue_text.is_empty():
		push_error("DialogueData: Missing 'text' field for dialogue '%s' in %s" % [dialogue_id, file_path])
		return null

	# Extract optional fields
	var next_dialogue_id = data.get("next_id", "")
	var is_cutscene = data.get("is_cutscene", false)

	# Parse choices array
	var choices: Array[Dictionary] = []
	if data.has("choices") and data["choices"] is Array:
		for choice_data in data["choices"]:
			if not choice_data is Dictionary:
				push_warning("DialogueData: Skipping non-dictionary choice in dialogue '%s' in %s" % [dialogue_id, file_path])
				continue

			if not choice_data.has("text") or not choice_data.has("next_id"):
				push_warning("DialogueData: Choice missing 'text' or 'next_id' in dialogue '%s' in %s" % [dialogue_id, file_path])
				continue

			choices.append({
				"text": choice_data["text"],
				"next_id": choice_data["next_id"]
			})

	# Create DialogueResource
	var resource = DialogueResource.new(
		dialogue_id,
		character_name,
		portrait_path,
		dialogue_text,
		choices,
		next_dialogue_id,
		is_cutscene
	)

	return resource


## Load multiple dialogue files and merge them into a single dictionary.
##
## @param file_paths: Array of file paths to load
## @returns Dictionary[String, DialogueResource] containing all loaded dialogues
static func load_multiple_files(file_paths: Array) -> Dictionary:
	var all_dialogues: Dictionary = {}

	for file_path in file_paths:
		var dialogues = load_dialogue_file(file_path)
		for dialogue_id in dialogues:
			if all_dialogues.has(dialogue_id):
				push_warning("DialogueData: Duplicate dialogue_id '%s' found in multiple files - using latest" % dialogue_id)
			all_dialogues[dialogue_id] = dialogues[dialogue_id]

	return all_dialogues
