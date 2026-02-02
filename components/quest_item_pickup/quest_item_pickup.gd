extends Area2D
## A quest-specific collectible item.
## Emits Events.pickup_collected(item_id, 1) when player touches it.
## Optionally only visible/active when a specific quest is active.
##
## Usage: Create via code, set item_id and optionally quest_id, add to scene.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Pickup identifier (matches quest objective trigger_id)
@export var item_id: String = ""

## If set, only visible/active when this quest is active
@export var quest_id: String = ""

## Visual color of the pickup diamond
@export var pickup_color: Color = Color(0.3, 0.9, 0.5)

## Optional floating label text
@export var label_text: String = ""

# =============================================================================
# STATE
# =============================================================================

var _collected: bool = false
var _bob_time: float = 0.0
var _base_y: float = 0.0
var _visual: Polygon2D = null
var _label: Label = null

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	add_to_group("quest_items")
	collision_layer = 0
	collision_mask = 2  # Player layer
	body_entered.connect(_on_body_entered)
	_base_y = position.y

	_create_collision_shape()
	_create_visual()
	if not label_text.is_empty():
		_create_label()

	# If quest-gated, check visibility
	if not quest_id.is_empty():
		_update_visibility()
		Events.quest_started.connect(func(_qid): _update_visibility())
		Events.quest_completed.connect(func(_qid): _update_visibility())


func _process(delta: float) -> void:
	if _collected:
		return
	# Gentle bob animation
	_bob_time += delta
	if _visual:
		_visual.position.y = sin(_bob_time * 2.5) * 2.0
	# Sparkle rotation
	if _visual:
		_visual.rotation += delta * 0.5

# =============================================================================
# VISUAL CONSTRUCTION
# =============================================================================

func _create_collision_shape() -> void:
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 10.0
	shape.shape = circle
	add_child(shape)


func _create_visual() -> void:
	# Diamond shape (rotated square)
	_visual = Polygon2D.new()
	_visual.polygon = PackedVector2Array([
		Vector2(0, -6),  # top
		Vector2(5, 0),   # right
		Vector2(0, 6),   # bottom
		Vector2(-5, 0),  # left
	])
	_visual.color = pickup_color
	_visual.z_index = 3
	add_child(_visual)

	# Inner highlight
	var highlight = Polygon2D.new()
	highlight.polygon = PackedVector2Array([
		Vector2(0, -3),
		Vector2(2.5, 0),
		Vector2(0, 3),
		Vector2(-2.5, 0),
	])
	highlight.color = pickup_color.lightened(0.4)
	highlight.z_index = 4
	add_child(highlight)


func _create_label() -> void:
	_label = Label.new()
	_label.text = label_text
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(-20, -18)
	_label.size = Vector2(40, 12)
	_label.add_theme_font_size_override("font_size", 6)
	_label.add_theme_color_override("font_color", Color(1, 1, 0.9, 0.8))
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_label.add_theme_constant_override("shadow_offset_x", 1)
	_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(_label)

# =============================================================================
# QUEST GATING
# =============================================================================

func _update_visibility() -> void:
	if quest_id.is_empty():
		visible = true
		return
	# Only show if the quest is active
	if has_node("/root/QuestManager"):
		visible = QuestManager.is_quest_active(quest_id)
	else:
		visible = false

# =============================================================================
# COLLECTION
# =============================================================================

func _on_body_entered(body: Node2D) -> void:
	if _collected:
		return
	if not body.is_in_group("player"):
		return
	if not visible:
		return

	_collected = true

	# Emit pickup event for quest system
	Events.pickup_collected.emit(item_id, 1)
	DebugLogger.log_system("Quest item collected: %s" % item_id)

	# Collection animation: scale up + fade out
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.2).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
