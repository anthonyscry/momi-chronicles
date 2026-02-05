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
	_register_all_quests()
	DebugLogger.log_system("QuestManager initialized with %d quests" % available_quests.size())

	# Wire event listeners for auto-completion
	Events.dialogue_started.connect(_on_dialogue_started_for_quests)
	Events.zone_entered.connect(_on_zone_entered_for_quests)
	Events.enemy_defeated.connect(_on_enemy_defeated_for_quests)
	Events.pickup_collected.connect(_on_pickup_collected_for_quests)

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

	# Unlock zone if quest gates a zone
	if not quest.zone_unlock.is_empty():
		if has_node("/root/GameManager"):
			var game_manager = get_node("/root/GameManager")
			game_manager.unlock_zone(quest.zone_unlock)
			DebugLogger.log_system("QuestManager: Quest '%s' unlocked zone '%s'" % [quest_id, quest.zone_unlock])
		else:
			push_warning("QuestManager: Cannot unlock zone - GameManager not found")

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
			DebugLogger.log_system("QuestManager: Granted %d coins" % rewards["coins"])

	# Grant EXP
	if rewards.has("exp") and rewards["exp"] > 0:
		var player = get_tree().get_first_node_in_group("player")
		if player and is_instance_valid(player) and player.has_node("ProgressionComponent"):
			var progression = player.get_node("ProgressionComponent")
			progression.add_exp(rewards["exp"])
			DebugLogger.log_system("QuestManager: Granted %d EXP" % rewards["exp"])
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
					DebugLogger.log_system("QuestManager: Granted item '%s' x%d" % [rewards["item"], quantity])
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
					DebugLogger.log_system("QuestManager: Granted equipment '%s'" % rewards["equipment"])
				else:
					push_warning("QuestManager: Failed to grant equipment '%s'" % rewards["equipment"])
			else:
				push_warning("QuestManager: Cannot grant equipment - EquipmentManager not found")

	# Grant reputation
	if rewards.has("reputation") and rewards["reputation"] is Dictionary:
		var rep_data: Dictionary = rewards["reputation"]
		for npc_id in rep_data:
			if has_node("/root/GameManager"):
				var game_manager = get_node("/root/GameManager")
				game_manager.add_reputation(npc_id, int(rep_data[npc_id]))
				DebugLogger.log_system("QuestManager: Granted +%d reputation with '%s'" % [int(rep_data[npc_id]), npc_id])

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

# =============================================================================
# QUEST REGISTRATION (sample quests defined in code)
# =============================================================================

func _register_all_quests() -> void:
	# Quest 1: Meet the Neighbors — triggered by talking to Gertrude
	var q1 = QuestData.new()
	q1.id = "meet_neighbors"
	q1.title = "Meet the Neighbors"
	q1.description = "Gertrude suggested you introduce yourself to the other neighbors."
	q1.is_main_quest = false
	q1.quest_giver_id = "gertrude"
	q1.objective_descriptions = ["Talk to Mailman Maurice", "Talk to the Kids Gang", "Talk to Mr. Henderson"]
	q1.optional_objectives = [false, false, false]
	q1.objective_trigger_types = ["dialogue", "dialogue", "dialogue"]
	q1.objective_trigger_ids = ["maurice", "kids_gang", "henderson"]
	q1.objective_target_counts = [1, 1, 1]
	q1.rewards = {"coins": 50, "exp": 25}
	register_quest_data(q1)

	# Quest 2: Community Watch — triggered by talking to Maurice (requires meet_neighbors)
	var q2 = QuestData.new()
	q2.id = "community_watch"
	q2.title = "Community Watch"
	q2.description = "Maurice heard about trouble in other areas. Patrol the Backyard and Sewers."
	q2.is_main_quest = false
	q2.quest_giver_id = "maurice"
	q2.prerequisite_quest_ids = ["meet_neighbors"]
	q2.objective_descriptions = ["Visit the Backyard", "Visit the Sewers"]
	q2.optional_objectives = [false, false]
	q2.objective_trigger_types = ["zone", "zone"]
	q2.objective_trigger_ids = ["backyard", "sewers"]
	q2.objective_target_counts = [1, 1]
	q2.rewards = {"coins": 75, "exp": 30}
	register_quest_data(q2)

	# Quest 3: Fetch — Find the Lost Ball (triggered by talking to Kids Gang, requires meet_neighbors)
	var q3 = QuestData.new()
	q3.id = "find_lost_ball"
	q3.title = "Find the Lost Ball"
	q3.description = "The Kids Gang lost their favorite ball somewhere in the Backyard. Find it and bring it back!"
	q3.is_main_quest = false
	q3.quest_giver_id = "kids_gang"
	q3.prerequisite_quest_ids = ["meet_neighbors"]
	q3.objective_descriptions = ["Find the lost ball in the Backyard", "Return to the Kids Gang"]
	q3.optional_objectives = [false, false]
	q3.objective_trigger_types = ["item_collect", "dialogue"]
	q3.objective_trigger_ids = ["lost_ball", "kids_gang"]
	q3.objective_target_counts = [1, 1]
	q3.objective_requires_prior = [false, true]  # Must find ball before returning
	q3.rewards = {"coins": 60, "exp": 30, "reputation": {"kids_gang": 15}}
	register_quest_data(q3)

	# Quest 4: Elimination — Pest Control (triggered by talking to Henderson, requires rep >= 30)
	var q4 = QuestData.new()
	q4.id = "pest_control"
	q4.title = "Pest Control"
	q4.description = "Mr. Henderson is tired of pests in the Backyard. Defeat 5 enemies there to clean things up."
	q4.is_main_quest = false
	q4.quest_giver_id = "henderson"
	q4.prerequisite_quest_ids = ["meet_neighbors"]
	q4.objective_descriptions = ["Defeat 5 enemies", "Report back to Mr. Henderson"]
	q4.optional_objectives = [false, false]
	q4.objective_trigger_types = ["enemy_kill", "dialogue"]
	q4.objective_trigger_ids = ["any", "henderson"]
	q4.objective_target_counts = [5, 1]
	q4.objective_requires_prior = [false, true]  # Must defeat enemies before reporting
	q4.rewards = {"coins": 100, "exp": 50, "reputation": {"henderson": 20}}
	register_quest_data(q4)

	# Quest 5: Delivery — Special Delivery (triggered by talking to Maurice, requires community_watch)
	var q5 = QuestData.new()
	q5.id = "special_delivery"
	q5.title = "Special Delivery"
	q5.description = "Maurice has a package for Old Lady Gertrude but can't leave his route. Pick it up and deliver it to her."
	q5.is_main_quest = false
	q5.quest_giver_id = "maurice"
	q5.prerequisite_quest_ids = ["community_watch"]
	q5.objective_descriptions = ["Pick up Maurice's package", "Deliver the package to Gertrude"]
	q5.optional_objectives = [false, false]
	q5.objective_trigger_types = ["item_collect", "dialogue"]
	q5.objective_trigger_ids = ["mail_package", "gertrude"]
	q5.objective_target_counts = [1, 1]
	q5.objective_requires_prior = [false, true]  # Must pick up before delivering
	q5.rewards = {"coins": 75, "exp": 35, "reputation": {"maurice": 15, "gertrude": 10}}
	register_quest_data(q5)

	# Quest 6: Chain 1/4 — Investigation: First Patrol (triggered by Gertrude, requires meet_neighbors)
	var q6 = QuestData.new()
	q6.id = "investigation_1"
	q6.title = "Neighborhood Investigation: First Patrol"
	q6.description = "Gertrude heard strange noises from the Backyard at night. Go check it out and report back."
	q6.is_main_quest = true
	q6.quest_giver_id = "gertrude"
	q6.prerequisite_quest_ids = ["meet_neighbors"]
	q6.objective_descriptions = ["Investigate the Backyard", "Report back to Gertrude"]
	q6.optional_objectives = [false, false]
	q6.objective_trigger_types = ["zone", "dialogue"]
	q6.objective_trigger_ids = ["backyard", "gertrude"]
	q6.objective_target_counts = [1, 1]
	q6.objective_requires_prior = [false, true]
	q6.rewards = {"coins": 40, "exp": 20, "reputation": {"gertrude": 10}}
	register_quest_data(q6)

	# Quest 7: Chain 2/4 — Investigation: Cleanup (requires investigation_1)
	var q7 = QuestData.new()
	q7.id = "investigation_2"
	q7.title = "Neighborhood Investigation: Cleanup"
	q7.description = "Gertrude says the pests are getting worse. Clear out some enemies in the Backyard."
	q7.is_main_quest = true
	q7.quest_giver_id = "gertrude"
	q7.prerequisite_quest_ids = ["investigation_1"]
	q7.objective_descriptions = ["Defeat 3 enemies", "Report back to Gertrude"]
	q7.optional_objectives = [false, false]
	q7.objective_trigger_types = ["enemy_kill", "dialogue"]
	q7.objective_trigger_ids = ["any", "gertrude"]
	q7.objective_target_counts = [3, 1]
	q7.objective_requires_prior = [false, true]
	q7.rewards = {"coins": 60, "exp": 30, "reputation": {"gertrude": 10}}
	register_quest_data(q7)

	# Quest 8: Chain 3/4 — Investigation: Sewers Recon (requires investigation_2)
	var q8 = QuestData.new()
	q8.id = "investigation_3"
	q8.title = "Neighborhood Investigation: Sewers Recon"
	q8.description = "Gertrude suspects the source of the pests is in the Sewers. Scout the area."
	q8.is_main_quest = true
	q8.quest_giver_id = "gertrude"
	q8.prerequisite_quest_ids = ["investigation_2"]
	q8.objective_descriptions = ["Explore the Sewers", "Report back to Gertrude"]
	q8.optional_objectives = [false, false]
	q8.objective_trigger_types = ["zone", "dialogue"]
	q8.objective_trigger_ids = ["sewers", "gertrude"]
	q8.objective_target_counts = [1, 1]
	q8.objective_requires_prior = [false, true]
	q8.rewards = {"coins": 80, "exp": 40, "reputation": {"gertrude": 10}}
	register_quest_data(q8)

	# Quest 9: Chain 4/4 — Investigation: The Full Report (requires investigation_3)
	var q9 = QuestData.new()
	q9.id = "investigation_4"
	q9.title = "Neighborhood Investigation: The Full Report"
	q9.description = "Gertrude wants a full report. Talk to all the neighbors about what you've found, then report back."
	q9.is_main_quest = true
	q9.quest_giver_id = "gertrude"
	q9.prerequisite_quest_ids = ["investigation_3"]
	q9.objective_descriptions = ["Talk to Maurice about the sewers", "Talk to the Kids Gang about the backyard", "Talk to Mr. Henderson about the noises", "Deliver the full report to Gertrude"]
	q9.optional_objectives = [false, false, false, false]
	q9.objective_trigger_types = ["dialogue", "dialogue", "dialogue", "dialogue"]
	q9.objective_trigger_ids = ["maurice", "kids_gang", "henderson", "gertrude"]
	q9.objective_target_counts = [1, 1, 1, 1]
	q9.objective_requires_prior = [false, false, false, true]  # First 3 parallel, last requires all prior
	q9.rewards = {"coins": 150, "exp": 75, "reputation": {"gertrude": 20, "maurice": 10, "kids_gang": 10, "henderson": 10}}
	register_quest_data(q9)

	# Quest 10: Missing Bait (requires meet_neighbors)
	var q10 = QuestData.new()
	q10.id = "missing_bait"
	q10.title = "Missing Bait"
	q10.description = "Maurice lost a bait box in the sewers. Recover it so he can finish his route."
	q10.is_main_quest = false
	q10.quest_giver_id = "maurice"
	q10.prerequisite_quest_ids = ["meet_neighbors"]
	q10.objective_descriptions = ["Defeat 3 sewer rats", "Find the bait box in the sewers", "Return to Maurice"]
	q10.optional_objectives = [false, false, false]
	q10.objective_trigger_types = ["enemy_kill", "item_collect", "dialogue"]
	q10.objective_trigger_ids = ["sewer_rat", "bait_box", "maurice"]
	q10.objective_target_counts = [3, 1, 1]
	q10.objective_requires_prior = [false, true, true]
	q10.rewards = {"coins": 60, "exp": 35, "reputation": {"maurice": 10}}
	register_quest_data(q10)

	# Quest 11: Echoes in the Pipes (requires meet_neighbors)
	var q11 = QuestData.new()
	q11.id = "echoes_in_pipes"
	q11.title = "Echoes in the Pipes"
	q11.description = "Gertrude heard a voice in the sewers. Find the Echo Room and report back."
	q11.is_main_quest = true
	q11.quest_giver_id = "gertrude"
	q11.prerequisite_quest_ids = ["meet_neighbors"]
	q11.objective_descriptions = ["Find the Echo Room in the sewers", "Return to Gertrude"]
	q11.optional_objectives = [false, false]
	q11.objective_trigger_types = ["dialogue", "dialogue"]
	q11.objective_trigger_ids = ["echo_room_memory", "gertrude"]
	q11.objective_target_counts = [1, 1]
	q11.objective_requires_prior = [false, true]
	q11.rewards = {"coins": 80, "exp": 45, "reputation": {"gertrude": 10}}
	register_quest_data(q11)

	# Quest 12: Guard the Grate (requires meet_neighbors)
	var q12 = QuestData.new()
	q12.id = "guard_grate"
	q12.title = "Guard the Grate"
	q12.description = "Henderson wants the sewer grate secured. Clear the pests and restore the valve."
	q12.is_main_quest = false
	q12.quest_giver_id = "henderson"
	q12.prerequisite_quest_ids = ["meet_neighbors"]
	q12.objective_descriptions = ["Defeat 5 enemies near the grate", "Restore the broken valve", "Report back to Henderson"]
	q12.optional_objectives = [false, false, false]
	q12.objective_trigger_types = ["enemy_kill", "item_collect", "dialogue"]
	q12.objective_trigger_ids = ["any", "valve_wheel", "henderson"]
	q12.objective_target_counts = [5, 1, 1]
	q12.objective_requires_prior = [false, true, true]
	q12.rewards = {"coins": 90, "exp": 50, "reputation": {"henderson": 15}}
	register_quest_data(q12)

# =============================================================================
# EVENT-DRIVEN QUEST COMPLETION
# =============================================================================

func _on_dialogue_started_for_quests(dialogue) -> void:
	# Find the dialogue_id from DialogueManager's loaded dialogues
	var dialogue_id: String = ""
	if dialogue:
		for did in DialogueManager._dialogues:
			if DialogueManager._dialogues[did] == dialogue:
				dialogue_id = did
				break

	if dialogue_id.is_empty():
		return

	# Auto-start quests where this NPC is the quest giver (data-driven, no hardcoded map)
	for qid in available_quests.keys():
		var qdata: QuestData = available_quests[qid]
		if qdata.quest_giver_id == dialogue_id and can_start_quest(qid):
			# Reputation gate for Henderson quests (requires rep >= 30)
			if dialogue_id == "henderson" and has_node("/root/GameManager"):
				if get_node("/root/GameManager").get_reputation("henderson") < 30:
					continue
			start_quest(qid)
			DebugLogger.log_system("Quest auto-started: %s (talked to %s)" % [qid, dialogue_id])

	# Complete "talk to" objectives for active quests
	_check_dialogue_objectives(dialogue_id)

func _on_zone_entered_for_quests(zone_name: String) -> void:
	_check_zone_objectives(zone_name)

func _check_dialogue_objectives(dialogue_id: String) -> void:
	for quest_id in active_quests.keys():
		var quest: Quest = active_quests[quest_id]
		for i in range(quest.objectives.size()):
			var obj: QuestObjective = quest.objectives[i]
			if obj.trigger_type == "dialogue" and obj.trigger_id == dialogue_id and not obj.is_completed():
				# Check requires_prior_complete
				if obj.requires_prior_complete:
					var blocked = false
					for j in range(i):
						if not quest.objectives[j].is_completed():
							blocked = true
							break
					if blocked:
						continue
				if obj.advance():
					DebugLogger.log_system("Quest objective completed: %s [%d] — %s" % [quest_id, i, obj.description])
					quest_updated.emit(quest_id, i)
					Events.quest_updated.emit(quest_id, i)
					if quest.all_objectives_completed():
						complete_quest(quest_id)

func _check_zone_objectives(zone_name: String) -> void:
	for quest_id in active_quests.keys():
		var quest: Quest = active_quests[quest_id]
		for i in range(quest.objectives.size()):
			var obj: QuestObjective = quest.objectives[i]
			if obj.trigger_type == "zone" and obj.trigger_id == zone_name and not obj.is_completed():
				# Check requires_prior_complete
				if obj.requires_prior_complete:
					var blocked = false
					for j in range(i):
						if not quest.objectives[j].is_completed():
							blocked = true
							break
					if blocked:
						continue
				if obj.advance():
					DebugLogger.log_system("Quest objective completed: %s [%d] — %s" % [quest_id, i, obj.description])
					quest_updated.emit(quest_id, i)
					Events.quest_updated.emit(quest_id, i)
					if quest.all_objectives_completed():
						complete_quest(quest_id)

# =============================================================================
# NEW TRIGGER TYPE HANDLERS (enemy_kill, item_collect)
# =============================================================================

func _on_enemy_defeated_for_quests(enemy: Node) -> void:
	# Extract enemy type from script path: "res://characters/enemies/raccoon.gd" -> "raccoon"
	var enemy_type: String = "unknown"
	if enemy and is_instance_valid(enemy) and enemy.get_script():
		enemy_type = enemy.get_script().resource_path.get_file().get_basename()
	_check_enemy_kill_objectives(enemy_type)

func _on_pickup_collected_for_quests(item_id: String, _amount: int) -> void:
	_check_item_collect_objectives(item_id)

func _check_enemy_kill_objectives(enemy_type: String) -> void:
	for quest_id in active_quests.keys():
		var quest: Quest = active_quests[quest_id]
		for i in range(quest.objectives.size()):
			var obj: QuestObjective = quest.objectives[i]
			if obj.trigger_type == "enemy_kill" and not obj.is_completed():
				# Check requires_prior_complete
				if obj.requires_prior_complete:
					var blocked = false
					for j in range(i):
						if not quest.objectives[j].is_completed():
							blocked = true
							break
					if blocked:
						continue
				# "any" matches all enemy types, otherwise match specific type
				if obj.trigger_id == "any" or obj.trigger_id == enemy_type:
					if obj.advance():
						DebugLogger.log_system("Quest objective advanced: %s [%d] — %s (%d/%d)" % [quest_id, i, obj.description, obj.current_count, obj.target_count])
					quest_updated.emit(quest_id, i)
					Events.quest_updated.emit(quest_id, i)
					if quest.all_objectives_completed():
						complete_quest(quest_id)

func _check_item_collect_objectives(item_id: String) -> void:
	for quest_id in active_quests.keys():
		var quest: Quest = active_quests[quest_id]
		for i in range(quest.objectives.size()):
			var obj: QuestObjective = quest.objectives[i]
			if obj.trigger_type == "item_collect" and obj.trigger_id == item_id and not obj.is_completed():
				# Check requires_prior_complete
				if obj.requires_prior_complete:
					var blocked = false
					for j in range(i):
						if not quest.objectives[j].is_completed():
							blocked = true
							break
					if blocked:
						continue
				if obj.advance():
					DebugLogger.log_system("Quest objective completed: %s [%d] — %s" % [quest_id, i, obj.description])
					quest_updated.emit(quest_id, i)
					Events.quest_updated.emit(quest_id, i)
					if quest.all_objectives_completed():
						complete_quest(quest_id)
