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

## Zone ID to unlock when this quest is completed (empty if no zone unlock)
@export var zone_unlock: String = ""

## Stable NPC identifier for the quest giver (used for quest markers and auto-start)
@export var quest_giver_id: String = ""

## Trigger types for each objective ("dialogue", "zone", "enemy_kill", "item_collect", "manual", "")
@export var objective_trigger_types: Array[String] = []

## Trigger IDs for each objective (dialogue_id, zone_name, etc.)
@export var objective_trigger_ids: Array[String] = []

## Target counts for each objective (default 1 = boolean completion)
@export var objective_target_counts: Array[int] = []

## Whether each objective requires all prior objectives to be complete before advancing
@export var objective_requires_prior: Array[bool] = []

# =============================================================================
# QUEST CREATION
# =============================================================================

## Create a Quest instance from this QuestData
## Returns a new Quest object with all objectives initialized
func create_quest() -> Quest:
	var quest: Quest = Quest.new(id, title, description, [], rewards, zone_unlock)

	# Create QuestObjective instances from the data
	for i in range(objective_descriptions.size()):
		var obj_description: String = objective_descriptions[i]
		var is_optional: bool = false
		var trigger_type: String = ""
		var trigger_id: String = ""
		var target_count: int = 1

		# Check if this objective is marked as optional
		if i < optional_objectives.size():
			is_optional = optional_objectives[i]
		if i < objective_trigger_types.size():
			trigger_type = objective_trigger_types[i]
		if i < objective_trigger_ids.size():
			trigger_id = objective_trigger_ids[i]
		if i < objective_target_counts.size():
			target_count = objective_target_counts[i]

		var requires_prior: bool = false
		if i < objective_requires_prior.size():
			requires_prior = objective_requires_prior[i]

		var objective: QuestObjective = QuestObjective.new(obj_description, false, is_optional, trigger_type, trigger_id, target_count, requires_prior)
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
