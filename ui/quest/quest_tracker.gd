extends Control
class_name QuestTracker
## Displays active quest title and current objective on HUD.

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var quest_title: Label = $VBoxContainer/QuestTitle
@onready var objective_label: Label = $VBoxContainer/ObjectiveLabel

# =============================================================================
# STATE
# =============================================================================

var current_quest: Quest = null
var fade_tween: Tween

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Connect to quest signals
	Events.active_quest_changed.connect(_on_active_quest_changed)
	Events.quest_updated.connect(_on_quest_updated)
	Events.quest_completed.connect(_on_quest_completed)

	# Hide when ring menu opens, re-show when closed (if quest active)
	Events.ring_menu_opened.connect(func(): visible = false)
	Events.ring_menu_closed.connect(func():
		if current_quest:
			visible = true
	)

	# Initial state - hidden until quest is active
	visible = false
	_update_display()

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_active_quest_changed(quest_id: String) -> void:
	# Cancel any existing fade
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()

	if quest_id.is_empty():
		# No active quest - fade out
		_fade_out()
		return

	# Get the quest from QuestManager (safety check for load order)
	if not has_node("/root/QuestManager"):
		return
	current_quest = QuestManager.get_active_quest(quest_id)

	if current_quest:
		# Show tracker with new quest
		visible = true
		modulate.a = 1.0
		_update_display()
		_pop_animation()
	else:
		_fade_out()

func _on_quest_updated(quest_id: String, _objective_index: int) -> void:
	# Only update if this is the current active quest
	if current_quest and current_quest.id == quest_id:
		_update_display()
		_pop_animation()

func _on_quest_completed(quest_id: String) -> void:
	# If current quest was completed, fade out
	if current_quest and current_quest.id == quest_id:
		current_quest = null
		_fade_out()

# =============================================================================
# DISPLAY UPDATES
# =============================================================================

func _update_display() -> void:
	if not current_quest:
		quest_title.text = ""
		objective_label.text = ""
		return

	# Update quest title
	quest_title.text = current_quest.title

	# Update current objective
	var current_objective = current_quest.get_current_objective()
	if current_objective:
		if current_objective.target_count > 1:
			objective_label.text = "%s (%d/%d)" % [current_objective.description, current_objective.current_count, current_objective.target_count]
		else:
			objective_label.text = current_objective.description
	else:
		# No incomplete objectives - show completion message
		objective_label.text = "All objectives complete!"

func _pop_animation() -> void:
	# Quick scale pop on quest update
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.08)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.12).set_ease(Tween.EASE_OUT)

func _fade_out() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.3)
	fade_tween.tween_callback(func():
		visible = false
		current_quest = null
	)
