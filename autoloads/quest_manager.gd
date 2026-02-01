extends Node
## QuestManager: Autoload singleton for managing quest state and progression.
##
## This autoload handles quest lifecycle (start, update, complete, fail),
## tracks active/completed/failed quests, manages the active quest for HUD display,
## and provides quest state serialization for save/load functionality.

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when a quest is started
signal quest_started(quest_id: String)

## Emitted when a quest objective is updated
signal quest_updated(quest_id: String, objective_index: int)

## Emitted when a quest is completed
signal quest_completed(quest_id: String)

## Emitted when a quest fails
signal quest_failed(quest_id: String)

## Emitted when the active quest changes (for HUD display)
signal active_quest_changed(quest_id: String)

# =============================================================================
# PROPERTIES
# =============================================================================

## Dictionary of all available quests by ID (populated from QuestData resources)
var available_quests: Dictionary = {}

## Dictionary of active quest instances by ID
var active_quests: Dictionary = {}

## Array of completed quest IDs
var completed_quest_ids: Array[String] = []

## Array of failed quest IDs
var failed_quest_ids: Array[String] = []

## The currently active quest ID for HUD display (player's focus)
var current_active_quest_id: String = ""

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready() -> void:
	# Quest data will be loaded via load_quest_data() or load from save
	pass

# =============================================================================
# QUEST DATA LOADING
# =============================================================================

## Load a quest from a QuestData resource
## This registers the quest as available but doesn't start it
func register_quest_data(quest_data: QuestData) -> void:
	if not quest_data.is_valid():
		push_error("QuestManager: Failed to register invalid quest data")
		return

	if available_quests.has(quest_data.id):
		push_warning("QuestManager: Quest '%s' is already registered" % quest_data.id)
		return

	available_quests[quest_data.id] = quest_data

## Load multiple quest data resources at once
func register_quest_data_batch(quest_data_array: Array) -> void:
	for quest_data in quest_data_array:
		if quest_data is QuestData:
			register_quest_data(quest_data)

## Check if a quest is available (registered)
func is_quest_available(quest_id: String) -> bool:
	return available_quests.has(quest_id)

## Check if prerequisites for a quest are met
func can_start_quest(quest_id: String) -> bool:
	if not is_quest_available(quest_id):
		return false

	var quest_data: QuestData = available_quests[quest_id]

	# Check if already active, completed, or failed
	if active_quests.has(quest_id):
		return false
	if completed_quest_ids.has(quest_id):
		return false
	if failed_quest_ids.has(quest_id):
		return false

	# Check prerequisites
	for prereq_id in quest_data.prerequisite_quest_ids:
		if not completed_quest_ids.has(prereq_id):
			return false

	return true

# =============================================================================
# QUEST LIFECYCLE
# =============================================================================

## Start a quest by ID
## Returns true if the quest was started, false otherwise
func start_quest(quest_id: String) -> bool:
	if not can_start_quest(quest_id):
		push_warning("QuestManager: Cannot start quest '%s' (not available or prerequisites not met)" % quest_id)
		return false

	var quest_data: QuestData = available_quests[quest_id]
	var quest: Quest = quest_data.create_quest()
	quest.start()

	active_quests[quest_id] = quest

	# If no active quest is set, make this the active one for HUD
	if current_active_quest_id.is_empty():
		set_active_quest(quest_id)

	quest_started.emit(quest_id)

	# Also emit to Events autoload if it exists
	if has_node("/root/Events"):
		var events = get_node("/root/Events")
		if events.has_signal("quest_started"):
			events.quest_started.emit(quest_id)

	return true

## Complete a quest objective by index
## Returns true if the objective was updated, false otherwise
func complete_objective(quest_id: String, objective_index: int) -> bool:
	if not active_quests.has(quest_id):
		push_warning("QuestManager: Cannot complete objective for inactive quest '%s'" % quest_id)
		return false

	var quest: Quest = active_quests[quest_id]

	if objective_index < 0 or objective_index >= quest.objectives.size():
		push_error("QuestManager: Invalid objective index %d for quest '%s'" % [objective_index, quest_id])
		return false

	var objective: QuestObjective = quest.objectives[objective_index]
	if objective.is_completed():
		return false  # Already completed

	objective.complete()
	quest_updated.emit(quest_id, objective_index)

	# Also emit to Events autoload if it exists
	if has_node("/root/Events"):
		var events = get_node("/root/Events")
		if events.has_signal("quest_updated"):
			events.quest_updated.emit(quest_id, objective_index)

	# Check if all objectives are complete
	if quest.all_objectives_completed():
		complete_quest(quest_id)

	return true

## Complete a quest and grant rewards
func complete_quest(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		push_warning("QuestManager: Cannot complete inactive quest '%s'" % quest_id)
		return

	var quest: Quest = active_quests[quest_id]
	quest.complete()

	# Move from active to completed
	active_quests.erase(quest_id)
	completed_quest_ids.append(quest_id)

	# If this was the active quest, clear it
	if current_active_quest_id == quest_id:
		current_active_quest_id = ""
		# Try to set another active quest if available
		if not active_quests.is_empty():
			var next_quest_id = active_quests.keys()[0]
			set_active_quest(next_quest_id)

	quest_completed.emit(quest_id)

	# Also emit to Events autoload if it exists
	if has_node("/root/Events"):
		var events = get_node("/root/Events")
		if events.has_signal("quest_completed"):
			events.quest_completed.emit(quest_id)

	# Grant rewards (will be implemented in later phase)
	_grant_rewards(quest.rewards)

## Fail a quest
func fail_quest(quest_id: String) -> void:
	if not active_quests.has(quest_id):
		push_warning("QuestManager: Cannot fail inactive quest '%s'" % quest_id)
		return

	var quest: Quest = active_quests[quest_id]
	quest.fail()

	# Move from active to failed
	active_quests.erase(quest_id)
	failed_quest_ids.append(quest_id)

	# If this was the active quest, clear it
	if current_active_quest_id == quest_id:
		current_active_quest_id = ""
		# Try to set another active quest if available
		if not active_quests.is_empty():
			var next_quest_id = active_quests.keys()[0]
			set_active_quest(next_quest_id)

	quest_failed.emit(quest_id)

	# Also emit to Events autoload if it exists
	if has_node("/root/Events"):
		var events = get_node("/root/Events")
		if events.has_signal("quest_failed"):
			events.quest_failed.emit(quest_id)

## Set which quest is the "active" quest for HUD display
func set_active_quest(quest_id: String) -> void:
	if quest_id.is_empty():
		current_active_quest_id = ""
		active_quest_changed.emit("")
		if has_node("/root/Events"):
			var events = get_node("/root/Events")
			if events.has_signal("active_quest_changed"):
				events.active_quest_changed.emit("")
		return

	if not active_quests.has(quest_id):
		push_warning("QuestManager: Cannot set inactive quest '%s' as active" % quest_id)
		return

	current_active_quest_id = quest_id
	active_quest_changed.emit(quest_id)

	# Also emit to Events autoload if it exists
	if has_node("/root/Events"):
		var events = get_node("/root/Events")
		if events.has_signal("active_quest_changed"):
			events.active_quest_changed.emit(quest_id)

# =============================================================================
# QUEST QUERIES
# =============================================================================

## Get an active quest by ID
func get_active_quest(quest_id: String) -> Quest:
	return active_quests.get(quest_id, null)

## Get the currently active quest for HUD display
func get_current_active_quest() -> Quest:
	if current_active_quest_id.is_empty():
		return null
	return get_active_quest(current_active_quest_id)

## Get all active quests
func get_all_active_quests() -> Array:
	return active_quests.values()

## Get all completed quest IDs
func get_completed_quest_ids() -> Array[String]:
	return completed_quest_ids.duplicate()

## Get all failed quest IDs
func get_failed_quest_ids() -> Array[String]:
	return failed_quest_ids.duplicate()

## Check if a quest is active
func is_quest_active(quest_id: String) -> bool:
	return active_quests.has(quest_id)

## Check if a quest is completed
func is_quest_completed(quest_id: String) -> bool:
	return completed_quest_ids.has(quest_id)

## Check if a quest is failed
func is_quest_failed(quest_id: String) -> bool:
	return failed_quest_ids.has(quest_id)

# =============================================================================
# QUEST REWARDS
# =============================================================================

## Grant quest rewards (coins, EXP, items, equipment)
func _grant_rewards(rewards: Dictionary) -> void:
	if rewards.is_empty():
		return

	# Grant coins
	if rewards.has("coins") and rewards["coins"] > 0:
		if has_node("/root/GameManager"):
			var game_manager = get_node("/root/GameManager")
			game_manager.add_coins(rewards["coins"])
			print("QuestManager: Granted %d coins" % rewards["coins"])

	# Grant EXP
	if rewards.has("exp") and rewards["exp"] > 0:
		var player = get_tree().get_first_node_in_group("player")
		if player and is_instance_valid(player) and player.has_node("ProgressionComponent"):
			var progression = player.get_node("ProgressionComponent")
			progression.add_exp(rewards["exp"])
			print("QuestManager: Granted %d EXP" % rewards["exp"])
		else:
			push_warning("QuestManager: Cannot grant EXP - player or ProgressionComponent not found")

	# Grant items
	if rewards.has("item") and not rewards["item"].is_empty():
		if has_node("/root/GameManager"):
			var game_manager = get_node("/root/GameManager")
			if game_manager.inventory and is_instance_valid(game_manager.inventory):
				var quantity = rewards.get("item_quantity", 1)
				var success = game_manager.inventory.add_item(rewards["item"], quantity)
				if success:
					print("QuestManager: Granted item '%s' x%d" % [rewards["item"], quantity])
				else:
					push_warning("QuestManager: Failed to grant item '%s'" % rewards["item"])
			else:
				push_warning("QuestManager: Cannot grant item - Inventory not found")

	# Grant equipment
	if rewards.has("equipment") and not rewards["equipment"].is_empty():
		if has_node("/root/GameManager"):
			var game_manager = get_node("/root/GameManager")
			if game_manager.equipment_manager and is_instance_valid(game_manager.equipment_manager):
				var success = game_manager.equipment_manager.add_equipment(rewards["equipment"])
				if success:
					print("QuestManager: Granted equipment '%s'" % rewards["equipment"])
				else:
					push_warning("QuestManager: Failed to grant equipment '%s'" % rewards["equipment"])
			else:
				push_warning("QuestManager: Cannot grant equipment - EquipmentManager not found")

	# Emit event for reward notification UI (future enhancement)
	if has_node("/root/Events"):
		var events = get_node("/root/Events")
		if events.has_signal("quest_rewards_granted"):
			events.quest_rewards_granted.emit(rewards)

# =============================================================================
# SERIALIZATION (Save/Load Support)
# =============================================================================

## Get quest state data for saving
func get_save_data() -> Dictionary:
	var active_quests_data: Dictionary = {}
	for quest_id in active_quests.keys():
		var quest: Quest = active_quests[quest_id]
		active_quests_data[quest_id] = quest.to_dict()

	return {
		"active_quests": active_quests_data,
		"completed_quest_ids": completed_quest_ids,
		"failed_quest_ids": failed_quest_ids,
		"current_active_quest_id": current_active_quest_id
	}

## Load quest state data from save
func load_save_data(data: Dictionary) -> void:
	if data.has("completed_quest_ids"):
		completed_quest_ids = data["completed_quest_ids"]

	if data.has("failed_quest_ids"):
		failed_quest_ids = data["failed_quest_ids"]

	if data.has("current_active_quest_id"):
		current_active_quest_id = data["current_active_quest_id"]

	# Load active quests
	if data.has("active_quests"):
		var active_quests_data: Dictionary = data["active_quests"]
		for quest_id in active_quests_data.keys():
			if not available_quests.has(quest_id):
				push_warning("QuestManager: Cannot load quest '%s' - not registered" % quest_id)
				continue

			var quest_data: QuestData = available_quests[quest_id]
			var quest: Quest = quest_data.create_quest()

			# Apply saved state
			var saved_quest_data: Dictionary = active_quests_data[quest_id]
			if saved_quest_data.has("state"):
				quest.state = saved_quest_data["state"]

			# Apply saved objective states
			if saved_quest_data.has("objectives"):
				var objectives_data: Array = saved_quest_data["objectives"]
				for i in range(min(quest.objectives.size(), objectives_data.size())):
					var objective: QuestObjective = quest.objectives[i]
					objective.from_dict(objectives_data[i])

			active_quests[quest_id] = quest
