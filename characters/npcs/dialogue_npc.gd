extends Area2D
## Reusable story NPC with dialogue interaction.
## Walk near and press E to start dialogue. Follows ShopNPC Area2D pattern.
##
## Usage: Instantiate via code, set npc_name + dialogue_id + npc_color, add to scene.

# =============================================================================
# CONFIGURATION
# =============================================================================

## NPC display name shown above the character
@export var npc_name: String = "NPC"

## The dialogue_id passed to DialogueManager.start_dialogue()
@export var dialogue_id: String = ""

## NPC body color for the placeholder shape
@export var npc_color: Color = Color(0.5, 0.5, 0.8)

## Prompt text shown when player is nearby
@export var prompt_text: String = "[E] Talk"

## Stable NPC identifier for quest system (doesn't change with dialogue variants)
@export var npc_id: String = ""

# =============================================================================
# STATE
# =============================================================================

## Whether the player is close enough to interact
var player_in_range: bool = false

## Floating prompt label
var prompt_label: Label = null

## Name label above NPC
var name_label: Label = null

## Body visual (placeholder colored shape)
var body_shape: Polygon2D = null

## Idle animation time accumulator
var _idle_time: float = 0.0

## Base Y position for bobbing
var _base_y: float = 0.0

## Tracks if dialogue is currently active (prevent re-trigger)
var _dialogue_active: bool = false

## Quest marker label (! or ?)
var quest_marker: Label = null

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  # Player layer

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_base_y = position.y

	_create_collision_shape()
	_create_body_visual()
	_create_name_label()
	_create_prompt_label()
	_create_quest_marker()

	# Listen for dialogue end to re-enable interaction
	Events.dialogue_ended.connect(_on_dialogue_ended)

	# Listen to quest events to update marker
	Events.quest_started.connect(func(_qid): _update_quest_marker())
	Events.quest_updated.connect(func(_qid, _idx): _update_quest_marker())
	Events.quest_completed.connect(func(_qid): _update_quest_marker())

	# Initial quest marker state
	_update_quest_marker()


func _process(delta: float) -> void:
	# Gentle bob animation
	_idle_time += delta
	var bob_offset = sin(_idle_time * PI) * 1.0
	if body_shape:
		body_shape.position.y = bob_offset

	# Quest marker float animation (faster than body bob)
	if quest_marker and quest_marker.visible:
		quest_marker.position.y = -34 + sin(_idle_time * 3.0) * 1.5


func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and not _dialogue_active and event.is_action_pressed("interact"):
		_start_dialogue()
		get_viewport().set_input_as_handled()

# =============================================================================
# VISUAL CONSTRUCTION (programmatic UI)
# =============================================================================

func _create_collision_shape() -> void:
	var shape = CollisionShape2D.new()
	shape.name = "CollisionShape2D"
	var rect = RectangleShape2D.new()
	rect.size = Vector2(28, 28)
	shape.shape = rect
	add_child(shape)


func _create_body_visual() -> void:
	# Simple humanoid placeholder — rounded body shape
	body_shape = Polygon2D.new()
	body_shape.name = "BodyShape"
	# Oval body (8 points)
	var points: PackedVector2Array = []
	for i in range(8):
		var angle = i * TAU / 8.0
		points.append(Vector2(cos(angle) * 6.0, sin(angle) * 8.0))
	body_shape.polygon = points
	body_shape.color = npc_color
	body_shape.position = Vector2(0, -4)
	body_shape.z_index = 1
	add_child(body_shape)

	# Head circle (smaller, above body)
	var head = Polygon2D.new()
	head.name = "HeadShape"
	var head_points: PackedVector2Array = []
	for i in range(8):
		var angle = i * TAU / 8.0
		head_points.append(Vector2(cos(angle) * 4.0, sin(angle) * 4.0))
	head.polygon = head_points
	head.color = npc_color.lightened(0.15)
	head.position = Vector2(0, -14)
	head.z_index = 2
	add_child(head)


func _create_name_label() -> void:
	name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = npc_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.position = Vector2(-24, -26)
	name_label.size = Vector2(48, 12)
	name_label.add_theme_font_size_override("font_size", 7)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7))
	name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(name_label)


func _create_prompt_label() -> void:
	prompt_label = Label.new()
	prompt_label.name = "PromptLabel"
	prompt_label.text = prompt_text
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.position = Vector2(-24, 10)
	prompt_label.size = Vector2(48, 12)
	prompt_label.add_theme_font_size_override("font_size", 7)
	prompt_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	prompt_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	prompt_label.add_theme_constant_override("shadow_offset_x", 1)
	prompt_label.add_theme_constant_override("shadow_offset_y", 1)
	prompt_label.visible = false
	add_child(prompt_label)

func _create_quest_marker() -> void:
	quest_marker = Label.new()
	quest_marker.name = "QuestMarker"
	quest_marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quest_marker.position = Vector2(-6, -34)
	quest_marker.size = Vector2(12, 14)
	quest_marker.add_theme_font_size_override("font_size", 12)
	quest_marker.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	quest_marker.add_theme_constant_override("outline_size", 2)
	quest_marker.z_index = 5
	quest_marker.visible = false
	add_child(quest_marker)


func _update_quest_marker() -> void:
	if not quest_marker or dialogue_id.is_empty():
		if quest_marker:
			quest_marker.visible = false
		return
	if not has_node("/root/QuestManager"):
		quest_marker.visible = false
		return

	# Use stable npc_id if set, otherwise fall back to dialogue_id
	var lookup_id = npc_id if not npc_id.is_empty() else dialogue_id

	var show_exclamation = false
	var show_question = false

	# Check if this NPC has a "dialogue" objective in any active quest
	# Only show "?" if the objective can actually advance (not blocked by prior objectives)
	for qid in QuestManager.active_quests.keys():
		var quest = QuestManager.get_active_quest(qid)
		if quest:
			for obj_idx in range(quest.objectives.size()):
				var obj = quest.objectives[obj_idx]
				if obj.trigger_type == "dialogue" and obj.trigger_id == lookup_id and not obj.is_completed():
					# Check if blocked by requires_prior_complete
					var blocked = false
					if obj.requires_prior_complete:
						for j in range(obj_idx):
							if not quest.objectives[j].is_completed():
								blocked = true
								break
					if not blocked:
						show_question = true
						break
			if show_question:
				break

	# Check if talking to this NPC would start any available quest (data-driven via quest_giver_id)
	for qid in QuestManager.available_quests.keys():
		var qdata = QuestManager.available_quests[qid]
		if qdata.quest_giver_id == lookup_id and QuestManager.can_start_quest(qid):
			show_exclamation = true
			break

	# Exclamation takes priority over question mark
	if show_exclamation:
		quest_marker.text = "!"
		quest_marker.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
		quest_marker.visible = true
	elif show_question:
		quest_marker.text = "?"
		quest_marker.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8, 1))
		quest_marker.visible = true
	else:
		quest_marker.visible = false


# =============================================================================
# DIALOGUE INTERACTION
# =============================================================================

func _start_dialogue() -> void:
	if dialogue_id.is_empty():
		DebugLogger.log_system("DialogueNPC '%s': No dialogue_id set" % npc_name)
		return

	_dialogue_active = true
	if prompt_label:
		prompt_label.visible = false

	DialogueManager.start_dialogue(dialogue_id)


func _on_dialogue_ended() -> void:
	_dialogue_active = false
	# Re-show prompt if player still nearby
	if player_in_range and prompt_label:
		prompt_label.visible = true
	# Refresh quest marker after dialogue (quest may have started/progressed)
	_update_quest_marker()

# =============================================================================
# INTERACTION SIGNALS
# =============================================================================

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if prompt_label and not _dialogue_active:
			prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if prompt_label:
			prompt_label.visible = false
