extends Resource
class_name QuestData
## Resource for defining quest content in the Godot editor.
##
## QuestData is a Resource that can be created and edited in the Godot editor
## and saved as .tres files. It contains all the data needed to instantiate
## a Quest object at runtime.

# =============================================================================
# EXPORTED PROPERTIES
# =============================================================================

## Unique identifier for the quest
@export var id: String = ""

## Display name of the quest
@export var title: String = ""

## Detailed description of the quest
@export_multiline var description: String = ""

## Array of objective descriptions (will be converted to QuestObjective instances)
@export var objective_descriptions: Array[String] = []

## Array marking which objectives are optional (same length as objective_descriptions)
@export var optional_objectives: Array[bool] = []

## Rewards granted upon quest completion (e.g., {"coins": 100, "exp": 50})
@export var rewards: Dictionary = {}

## Whether this is a main story quest (vs. side quest)
@export var is_main_quest: bool = false

## Quest IDs that must be completed before this quest becomes available
@export var prerequisite_quest_ids: Array[String] = []

# =============================================================================
# QUEST CREATION
# =============================================================================

## Create a Quest instance from this QuestData
## Returns a new Quest object with all objectives initialized
func create_quest() -> Quest:
	var quest: Quest = Quest.new(id, title, description, [], rewards)

	# Create QuestObjective instances from the data
	for i in range(objective_descriptions.size()):
		var obj_description: String = objective_descriptions[i]
		var is_optional: bool = false

		# Check if this objective is marked as optional
		if i < optional_objectives.size():
			is_optional = optional_objectives[i]

		var objective: QuestObjective = QuestObjective.new(obj_description, false, is_optional)
		quest.objectives.append(objective)

	return quest

## Validate that the quest data is properly configured
## Returns true if valid, false otherwise with error printed
func is_valid() -> bool:
	if id.is_empty():
		push_error("QuestData validation failed: id is empty")
		return false

	if title.is_empty():
		push_error("QuestData validation failed: title is empty for quest '%s'" % id)
		return false

	if objective_descriptions.is_empty():
		push_error("QuestData validation failed: no objectives defined for quest '%s'" % id)
		return false

	# Warn if optional_objectives array doesn't match objective_descriptions length
	if not optional_objectives.is_empty() and optional_objectives.size() != objective_descriptions.size():
		push_warning("QuestData warning: optional_objectives size (%d) doesn't match objective_descriptions size (%d) for quest '%s'" % [optional_objectives.size(), objective_descriptions.size(), id])

	return true
