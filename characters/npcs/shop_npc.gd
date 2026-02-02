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

## Sprite reference
@onready var sprite: AnimatedSprite2D = $Sprite2D

## Idle animation time accumulator
var _idle_time: float = 0.0

## Base Y position for bobbing
var _base_y: float = 0.0

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	_base_y = position.y
	
	_create_collision_shape()
	_create_name_label()
	_create_prompt_label()
	
	if sprite:
		sprite.play("idle")


func _process(delta: float) -> void:
	_idle_time += delta
	var bob_offset = sin(_idle_time * PI) * 1.0
	if sprite:
		sprite.position.y = bob_offset
	else:
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


func _create_name_label() -> void:
	name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = npc_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.position = Vector2(-20, -26)
	name_label.size = Vector2(40, 12)
	name_label.add_theme_font_size_override("font_size", 7)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
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
		if sprite:
			sprite.play("wave")


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		if prompt_label:
			prompt_label.visible = false
		if sprite:
			sprite.play("idle")
