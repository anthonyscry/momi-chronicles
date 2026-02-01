extends Control
class_name PortraitDisplay
## Displays character portrait images during dialogue.

@onready var texture_rect: TextureRect = $TextureRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

## Current portrait texture
var current_portrait: Texture2D = null

## Position of portrait (left or right side)
@export_enum("Left", "Right") var portrait_position: String = "Left"


func _ready() -> void:
	# Connect to dialogue events
	Events.dialogue_started.connect(_on_dialogue_started)
	Events.dialogue_advanced.connect(_on_dialogue_advanced)
	Events.dialogue_ended.connect(_on_dialogue_ended)

	# Initially hidden
	hide()


func _on_dialogue_started(dialogue: DialogueResource) -> void:
	_update_portrait(dialogue)


func _on_dialogue_advanced(dialogue: DialogueResource) -> void:
	_update_portrait(dialogue)


func _on_dialogue_ended() -> void:
	fade_out()


func _update_portrait(dialogue: DialogueResource) -> void:
	if dialogue.portrait_path.is_empty():
		fade_out()
		return

	# Load the portrait texture
	var portrait_texture = load(dialogue.portrait_path) as Texture2D

	if portrait_texture == null:
		push_warning("PortraitDisplay: Failed to load portrait at path: %s" % dialogue.portrait_path)
		fade_out()
		return

	# If same portrait, don't reload
	if current_portrait == portrait_texture:
		if not visible:
			fade_in()
		return

	# Set new portrait
	current_portrait = portrait_texture
	if texture_rect:
		texture_rect.texture = portrait_texture

	# Fade in the portrait
	fade_in()


## Fade in the portrait display
func fade_in() -> void:
	if animation_player and animation_player.has_animation("fade_in"):
		show()
		animation_player.play("fade_in")
	else:
		show()


## Fade out the portrait display
func fade_out() -> void:
	if animation_player and animation_player.has_animation("fade_out"):
		animation_player.play("fade_out")
		# Hide after animation completes
		await animation_player.animation_finished
		hide()
	else:
		hide()


## Manually set portrait from a texture path
func set_portrait(portrait_path: String) -> void:
	if portrait_path.is_empty():
		fade_out()
		return

	var portrait_texture = load(portrait_path) as Texture2D

	if portrait_texture == null:
		push_warning("PortraitDisplay: Failed to load portrait at path: %s" % portrait_path)
		fade_out()
		return

	current_portrait = portrait_texture
	if texture_rect:
		texture_rect.texture = portrait_texture

	fade_in()


## Clear the current portrait
func clear_portrait() -> void:
	current_portrait = null
	if texture_rect:
		texture_rect.texture = null
	fade_out()
