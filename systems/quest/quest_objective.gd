extends RefCounted
class_name QuestObjective
## Represents a single objective within a quest.
##
## Quest objectives track individual tasks that must be completed.
## They can be marked as optional and can be completed independently.

# =============================================================================
# PROPERTIES
# =============================================================================

## Description of what needs to be accomplished
var description: String = ""

## Whether this objective has been completed
var completed: bool = false

## Whether this objective is optional (not required for quest completion)
var optional: bool = false

# =============================================================================
# INITIALIZATION
# =============================================================================

func _init(
	p_description: String = "",
	p_completed: bool = false,
	p_optional: bool = false
) -> void:
	description = p_description
	completed = p_completed
	optional = p_optional

# =============================================================================
# STATE MANAGEMENT
# =============================================================================

## Mark this objective as completed
func complete() -> void:
	completed = true

## Check if this objective is completed
func is_completed() -> bool:
	return completed

## Check if this objective is optional
func is_optional() -> bool:
	return optional

## Reset the objective to incomplete state
func reset() -> void:
	completed = false

# =============================================================================
# SERIALIZATION
# =============================================================================

## Serialize objective state to a dictionary for saving
func to_dict() -> Dictionary:
	return {
		"description": description,
		"completed": completed,
		"optional": optional
	}

## Load objective state from a dictionary
func from_dict(data: Dictionary) -> void:
	if data.has("description"):
		description = data["description"]
	if data.has("completed"):
		completed = data["completed"]
	if data.has("optional"):
		optional = data["optional"]
