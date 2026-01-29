class_name ShopNPC
extends Area2D
## Nutkin the Squirrel — Shop NPC with interaction prompt.
## Walk near and press E to open the shop.

# =============================================================================
# CONFIGURATION
# =============================================================================

## NPC display name
@export var npc_name: String = "Nutkin"

# =============================================================================
# STATE
# =============================================================================

## Whether the player is close enough to interact
var player_in_range: bool = false

## Floating prompt label
var prompt_label: Label = null

## Name label above NPC
var name_label: Label = null

## Squirrel body polygon
var body_polygon: Polygon2D = null

## Tail polygon
var tail_polygon: Polygon2D = null

## Idle animation time accumulator
var _idle_time: float = 0.0

## Base Y position for bobbing
var _base_y: float = 0.0

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Collision setup — detect player (layer 2), same as ZoneExit
	collision_layer = 0
	collision_mask = 2
	
	# Connect area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Store base Y for idle bobbing
	_base_y = position.y
	
	# Build visual elements
	_create_collision_shape()
	_create_squirrel_visual()
	_create_name_label()
	_create_prompt_label()


func _process(delta: float) -> void:
	# Gentle idle bobbing — 1px up/down at 0.5Hz
	_idle_time += delta
	var bob_offset = sin(_idle_time * PI) * 1.0
	position.y = _base_y + bob_offset


func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		Events.shop_interact_requested.emit()
		get_viewport().set_input_as_handled()

# =============================================================================
# VISUAL CONSTRUCTION
# =============================================================================

func _create_collision_shape() -> void:
	var shape = CollisionShape2D.new()
	shape.name = "CollisionShape2D"
	var rect = RectangleShape2D.new()
	rect.size = Vector2(24, 24)
	shape.shape = rect
	add_child(shape)


func _create_squirrel_visual() -> void:
	# Body — orange-brown oval squirrel body
	body_polygon = Polygon2D.new()
	body_polygon.name = "Body"
	body_polygon.polygon = PackedVector2Array([
		Vector2(-5, -8),   # Top left
		Vector2(0, -10),   # Top center
		Vector2(5, -8),    # Top right
		Vector2(6, -3),    # Right upper
		Vector2(6, 4),     # Right lower
		Vector2(4, 7),     # Bottom right
		Vector2(-4, 7),    # Bottom left
		Vector2(-6, 4),    # Left lower
		Vector2(-6, -3),   # Left upper
	])
	body_polygon.color = Color(0.75, 0.5, 0.25)  # Orange-brown
	add_child(body_polygon)
	
	# Belly — lighter patch
	var belly = Polygon2D.new()
	belly.name = "Belly"
	belly.polygon = PackedVector2Array([
		Vector2(-3, -2),
		Vector2(3, -2),
		Vector2(3, 5),
		Vector2(-3, 5),
	])
	belly.color = Color(0.92, 0.82, 0.65)  # Light cream
	add_child(belly)
	
	# Tail — bushy curved tail behind body
	tail_polygon = Polygon2D.new()
	tail_polygon.name = "Tail"
	tail_polygon.polygon = PackedVector2Array([
		Vector2(-6, -2),
		Vector2(-8, -6),
		Vector2(-10, -10),
		Vector2(-8, -14),
		Vector2(-4, -15),
		Vector2(-2, -13),
		Vector2(-4, -9),
		Vector2(-5, -5),
	])
	tail_polygon.color = Color(0.7, 0.45, 0.2)  # Slightly darker orange-brown
	# Move tail behind body
	move_child(tail_polygon, 0)
	
	# Eyes — two small dots
	var left_eye = Polygon2D.new()
	left_eye.name = "LeftEye"
	left_eye.polygon = PackedVector2Array([
		Vector2(-3, -6), Vector2(-1, -6), Vector2(-1, -4), Vector2(-3, -4),
	])
	left_eye.color = Color(0.1, 0.1, 0.1)  # Black
	add_child(left_eye)
	
	var right_eye = Polygon2D.new()
	right_eye.name = "RightEye"
	right_eye.polygon = PackedVector2Array([
		Vector2(1, -6), Vector2(3, -6), Vector2(3, -4), Vector2(1, -4),
	])
	right_eye.color = Color(0.1, 0.1, 0.1)  # Black
	add_child(right_eye)
	
	# Nose — tiny triangle
	var nose = Polygon2D.new()
	nose.name = "Nose"
	nose.polygon = PackedVector2Array([
		Vector2(-1, -3), Vector2(1, -3), Vector2(0, -2),
	])
	nose.color = Color(0.3, 0.15, 0.1)  # Dark brown
	add_child(nose)
	
	# Ears — two small triangles on top
	var left_ear = Polygon2D.new()
	left_ear.name = "LeftEar"
	left_ear.polygon = PackedVector2Array([
		Vector2(-5, -8), Vector2(-3, -13), Vector2(-1, -8),
	])
	left_ear.color = Color(0.7, 0.45, 0.2)
	add_child(left_ear)
	
	var right_ear = Polygon2D.new()
	right_ear.name = "RightEar"
	right_ear.polygon = PackedVector2Array([
		Vector2(1, -8), Vector2(3, -13), Vector2(5, -8),
	])
	right_ear.color = Color(0.7, 0.45, 0.2)
	add_child(right_ear)


func _create_name_label() -> void:
	name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = npc_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.position = Vector2(-20, -26)
	name_label.size = Vector2(40, 12)
	name_label.add_theme_font_size_override("font_size", 7)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))  # Gold
	name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(name_label)


func _create_prompt_label() -> void:
	prompt_label = Label.new()
	prompt_label.name = "PromptLabel"
	prompt_label.text = "[E] Shop"
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

# =============================================================================
# INTERACTION SIGNALS
# =============================================================================

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true
		if prompt_label:
			prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		if prompt_label:
			prompt_label.visible = false
