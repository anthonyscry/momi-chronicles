extends MarginContainer
class_name QuestLog
## Quest log UI component showing active, completed, and available quests.
## Displays quest titles, descriptions, objectives, and completion status.

## Quest list containers
@onready var active_quests_list: VBoxContainer = $VBoxContainer/ScrollContainer/ContentContainer/ActiveQuests/QuestsList
@onready var completed_quests_list: VBoxContainer = $VBoxContainer/ScrollContainer/ContentContainer/CompletedQuests/QuestsList
@onready var available_quests_list: VBoxContainer = $VBoxContainer/ScrollContainer/ContentContainer/AvailableQuests/QuestsList

## Section headers
@onready var active_header: Label = $VBoxContainer/ScrollContainer/ContentContainer/ActiveQuests/HeaderLabel
@onready var completed_header: Label = $VBoxContainer/ScrollContainer/ContentContainer/CompletedQuests/HeaderLabel
@onready var available_header: Label = $VBoxContainer/ScrollContainer/ContentContainer/AvailableQuests/HeaderLabel


func _ready() -> void:
	# Connect to quest events
	if has_node("/root/Events"):
		var events = get_node("/root/Events")
		if events.has_signal("quest_started"):
			events.quest_started.connect(_on_quest_started)
		if events.has_signal("quest_completed"):
			events.quest_completed.connect(_on_quest_completed)
		if events.has_signal("quest_updated"):
			events.quest_updated.connect(_on_quest_updated)

	# Initial refresh
	_refresh_all_quest_lists()


## Refresh all quest lists from QuestManager
func _refresh_all_quest_lists() -> void:
	_refresh_active_quests()
	_refresh_completed_quests()
	_refresh_available_quests()


## Refresh the active quests list
func _refresh_active_quests() -> void:
	# Clear existing entries
	for child in active_quests_list.get_children():
		child.queue_free()

	if not has_node("/root/QuestManager"):
		return

	var quest_manager = get_node("/root/QuestManager")
	var active_quests = quest_manager.get_all_active_quests()

	if active_quests.is_empty():
		var no_quests_label = Label.new()
		no_quests_label.text = "No active quests"
		no_quests_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7, 1))
		no_quests_label.add_theme_font_size_override("font_size", 8)
		active_quests_list.add_child(no_quests_label)
		return

	# Add each active quest
	for quest in active_quests:
		var quest_entry = _create_quest_entry(quest, true)
		active_quests_list.add_child(quest_entry)


## Refresh the completed quests list
func _refresh_completed_quests() -> void:
	# Clear existing entries
	for child in completed_quests_list.get_children():
		child.queue_free()

	if not has_node("/root/QuestManager"):
		return

	var quest_manager = get_node("/root/QuestManager")
	var completed_ids = quest_manager.get_completed_quest_ids()

	if completed_ids.is_empty():
		var no_quests_label = Label.new()
		no_quests_label.text = "No completed quests"
		no_quests_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7, 1))
		no_quests_label.add_theme_font_size_override("font_size", 8)
		completed_quests_list.add_child(no_quests_label)
		return

	# Add each completed quest
	for quest_id in completed_ids:
		var quest_data = quest_manager.available_quests.get(quest_id, null)
		if quest_data:
			var quest = quest_data.create_quest()
			quest.state = Quest.State.COMPLETED
			var quest_entry = _create_quest_entry(quest, false)
			completed_quests_list.add_child(quest_entry)


## Refresh the available quests list
func _refresh_available_quests() -> void:
	# Clear existing entries
	for child in available_quests_list.get_children():
		child.queue_free()

	if not has_node("/root/QuestManager"):
		return

	var quest_manager = get_node("/root/QuestManager")
	var available_quest_ids: Array = []

	# Find quests that are available but not started
	for quest_id in quest_manager.available_quests.keys():
		if quest_manager.can_start_quest(quest_id):
			available_quest_ids.append(quest_id)

	if available_quest_ids.is_empty():
		var no_quests_label = Label.new()
		no_quests_label.text = "No available quests"
		no_quests_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7, 1))
		no_quests_label.add_theme_font_size_override("font_size", 8)
		available_quests_list.add_child(no_quests_label)
		return

	# Add each available quest
	for quest_id in available_quest_ids:
		var quest_data = quest_manager.available_quests.get(quest_id, null)
		if quest_data:
			var quest = quest_data.create_quest()
			var quest_entry = _create_quest_entry(quest, false)
			available_quests_list.add_child(quest_entry)


## Create a UI entry for a quest
func _create_quest_entry(quest, show_objectives: bool) -> VBoxContainer:
	var entry = VBoxContainer.new()
	entry.add_theme_constant_override("separation", 4)

	# Quest title
	var title_label = Label.new()
	title_label.text = quest.title
	title_label.add_theme_color_override("font_color", Color(1, 1, 0.8, 1))
	title_label.add_theme_font_size_override("font_size", 10)
	entry.add_child(title_label)

	# Quest description
	var desc_label = Label.new()
	desc_label.text = quest.description
	desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9, 1))
	desc_label.add_theme_font_size_override("font_size", 8)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size.x = 200
	entry.add_child(desc_label)

	# Show objectives for active quests
	if show_objectives and not quest.objectives.is_empty():
		var objectives_container = VBoxContainer.new()
		objectives_container.add_theme_constant_override("separation", 2)

		for i in range(quest.objectives.size()):
			var objective = quest.objectives[i]
			var obj_label = Label.new()

			# Format: [✓] or [ ] + objective description + progress count
			var checkbox = "✓" if objective.is_completed() else " "
			var optional_tag = " (Optional)" if objective.is_optional() else ""
			var progress_text = ""
			if objective.target_count > 1:
				progress_text = " (%d/%d)" % [objective.current_count, objective.target_count]
			obj_label.text = "[%s] %s%s%s" % [checkbox, objective.description, progress_text, optional_tag]

			# Color based on completion
			if objective.is_completed():
				obj_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5, 1))
			elif objective.is_optional():
				obj_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8, 0.8))
			else:
				obj_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1, 1))

			obj_label.add_theme_font_size_override("font_size", 8)
			objectives_container.add_child(obj_label)

		entry.add_child(objectives_container)

	# Spacer between entries
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	entry.add_child(spacer)

	return entry


## Event handlers
func _on_quest_started(_quest_id: String) -> void:
	_refresh_active_quests()
	_refresh_available_quests()


func _on_quest_completed(_quest_id: String) -> void:
	_refresh_active_quests()
	_refresh_completed_quests()


func _on_quest_updated(_quest_id: String, _objective_index: int) -> void:
	_refresh_active_quests()
