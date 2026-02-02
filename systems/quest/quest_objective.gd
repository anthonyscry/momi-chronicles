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

## What event type triggers completion: "dialogue", "zone", "manual", ""
var trigger_type: String = ""

## The specific ID to match (dialogue_id for "dialogue", zone_name for "zone")
var trigger_id: String = ""

## Target count for counter-based objectives (default 1 = boolean completion)
var target_count: int = 1

## Current progress count
var current_count: int = 0

## Whether all prior objectives must be completed before this one can advance
var requires_prior_complete: bool = false

# =============================================================================
# INITIALIZATION
# =============================================================================

func _init(
	p_description: String = "",
	p_completed: bool = false,
	p_optional: bool = false,
	p_trigger_type: String = "",
	p_trigger_id: String = "",
	p_target_count: int = 1,
	p_requires_prior_complete: bool = false
) -> void:
	description = p_description
	completed = p_completed
	optional = p_optional
	trigger_type = p_trigger_type
	trigger_id = p_trigger_id
	target_count = p_target_count
	requires_prior_complete = p_requires_prior_complete

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

## Advance progress by 1. Returns true if objective just completed.
func advance() -> bool:
	if completed:
		return false
	current_count += 1
	if current_count >= target_count:
		completed = true
		return true
	return false

## Reset the objective to incomplete state
func reset() -> void:
	completed = false
	current_count = 0

# =============================================================================
# SERIALIZATION
# =============================================================================

## Serialize objective state to a dictionary for saving
func to_dict() -> Dictionary:
	return {
		"description": description,
		"completed": completed,
		"optional": optional,
		"trigger_type": trigger_type,
		"trigger_id": trigger_id,
		"target_count": target_count,
		"current_count": current_count,
		"requires_prior_complete": requires_prior_complete,
	}

## Load objective state from a dictionary
func from_dict(data: Dictionary) -> void:
	if data.has("description"):
		description = data["description"]
	if data.has("completed"):
		completed = data["completed"]
	if data.has("optional"):
		optional = data["optional"]
	trigger_type = data.get("trigger_type", "")
	trigger_id = data.get("trigger_id", "")
	target_count = data.get("target_count", 1)
	current_count = data.get("current_count", 0)
	requires_prior_complete = data.get("requires_prior_complete", false)
