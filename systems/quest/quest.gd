extends RefCounted
class_name Quest
## Represents a quest with objectives, rewards, and state tracking.
##
## A quest can be in various states (not_started, active, completed, failed)
## and contains objectives that must be completed to finish the quest.

# =============================================================================
# ENUMS
# =============================================================================

enum State {
	NOT_STARTED,  ## Quest is available but not yet started
	ACTIVE,       ## Quest is currently being pursued
	COMPLETED,    ## Quest has been successfully completed
	FAILED        ## Quest has failed and cannot be completed
}

# =============================================================================
# PROPERTIES
# =============================================================================

## Unique identifier for the quest
var id: String = ""

## Display name of the quest
var title: String = ""

## Detailed description of the quest
var description: String = ""

## Array of QuestObjective instances
var objectives: Array = []

## Rewards granted upon quest completion (e.g., {"coins": 100, "exp": 50})
var rewards: Dictionary = {}

## Current state of the quest
var state: State = State.NOT_STARTED

# =============================================================================
# INITIALIZATION
# =============================================================================

func _init(
	p_id: String = "",
	p_title: String = "",
	p_description: String = "",
	p_objectives: Array = [],
	p_rewards: Dictionary = {},
	p_state: State = State.NOT_STARTED
) -> void:
	id = p_id
	title = p_title
	description = p_description
	objectives = p_objectives
	rewards = p_rewards
	state = p_state

# =============================================================================
# STATE MANAGEMENT
# =============================================================================

## Start the quest, changing state from NOT_STARTED to ACTIVE
func start() -> void:
	if state == State.NOT_STARTED:
		state = State.ACTIVE

## Complete the quest, changing state to COMPLETED
func complete() -> void:
	if state == State.ACTIVE:
		state = State.COMPLETED

## Fail the quest, changing state to FAILED
func fail() -> void:
	if state == State.ACTIVE:
		state = State.FAILED

## Check if the quest is currently active
func is_active() -> bool:
	return state == State.ACTIVE

## Check if the quest is completed
func is_completed() -> bool:
	return state == State.COMPLETED

## Check if the quest has failed
func is_failed() -> bool:
	return state == State.FAILED

## Get the current active objective (first incomplete objective)
func get_current_objective():
	for objective in objectives:
		if objective.has_method("is_completed") and not objective.is_completed():
			return objective
	return null

## Check if all objectives are completed
func all_objectives_completed() -> bool:
	if objectives.is_empty():
		return false

	for objective in objectives:
		if objective.has_method("is_completed") and not objective.is_completed():
			return false

	return true

## Get quest progress as a percentage (0.0 to 1.0)
func get_progress() -> float:
	if objectives.is_empty():
		return 0.0

	var completed_count: int = 0
	for objective in objectives:
		if objective.has_method("is_completed") and objective.is_completed():
			completed_count += 1

	return float(completed_count) / float(objectives.size())

# =============================================================================
# SERIALIZATION
# =============================================================================

## Serialize quest state to a dictionary for saving
func to_dict() -> Dictionary:
	var objectives_data: Array = []
	for objective in objectives:
		if objective.has_method("to_dict"):
			objectives_data.append(objective.to_dict())

	return {
		"id": id,
		"title": title,
		"description": description,
		"objectives": objectives_data,
		"rewards": rewards,
		"state": state
	}

## Load quest state from a dictionary
func from_dict(data: Dictionary) -> void:
	if data.has("id"):
		id = data["id"]
	if data.has("title"):
		title = data["title"]
	if data.has("description"):
		description = data["description"]
	if data.has("rewards"):
		rewards = data["rewards"]
	if data.has("state"):
		state = data["state"]
	# Note: objectives loading requires QuestObjective instances to be created
	# This will be handled by QuestManager when loading from QuestData
