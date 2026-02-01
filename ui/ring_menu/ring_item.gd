extends Control
class_name RingItem

## Emitted when this item is selected/confirmed
signal item_activated(item_data: Dictionary)

## The data for this ring item
var item_data: Dictionary = {}

## Visual state
var is_selected: bool = false
var is_equipped: bool = false
var target_scale: float = 1.0
var target_alpha: float = 1.0

## Level gating colors
const DIMMED_COLOR_MULTIPLIER: Color = Color(0.4, 0.4, 0.5, 0.7)
const LEVEL_REQ_COLOR: Color = Color(0.8, 0.3, 0.3)
const EQUIPPED_GLOW_COLOR: Color = Color(0.3, 1.0, 0.3, 0.3)

## Node references
@onready var icon: ColorRect = $Icon
@onready var label: Label = $Label
@onready var glow: ColorRect = $Glow
@onready var quantity_label: Label = $QuantityLabel

const SELECTED_SCALE: float = 1.3       # Selected item stands out
const UNSELECTED_SCALE: float = 0.9     # Unselected still visible
const SELECTED_ALPHA: float = 1.0
const UNSELECTED_ALPHA: float = 0.75    # Unselected items more visible
const LERP_SPEED: float = 15.0

func _ready() -> void:
	# Start with glow hidden
	if glow:
		glow.visible = false
	# Set pivot to center for scaling
	pivot_offset = size / 2

func _process(delta: float) -> void:
	# Smooth scale transition
	scale = scale.lerp(Vector2.ONE * target_scale, LERP_SPEED * delta)
	modulate.a = lerp(modulate.a, target_alpha, LERP_SPEED * delta)

## Set up the item display
func setup(data: Dictionary) -> void:
	item_data = data
	is_equipped = data.get("equipped", false)

	# Set icon color based on type
	var color = _get_type_color(data.get("type", "item"))
	if data.has("color"):
		color = data.color

	# Dim icon for level-gated equipment the player can't equip
	if data.has("player_can_equip") and not data.player_can_equip:
		color *= DIMMED_COLOR_MULTIPLIER

	if icon:
		icon.color = color
		icon.visible = true

	# Label is now hidden - item name shown in center of ring menu
	# if label and data.has("name"):
	# 	label.text = data.name

	# Show level requirement for gated items, otherwise show quantity
	if quantity_label:
		var min_level = data.get("min_level", 1)
		if min_level > 1 and data.has("player_can_equip") and not data.player_can_equip:
			quantity_label.visible = true
			quantity_label.text = "Lv.%d" % min_level
			quantity_label.add_theme_color_override("font_color", LEVEL_REQ_COLOR)
		else:
			quantity_label.remove_theme_color_override("font_color")
			var qty = data.get("quantity", 1)
			quantity_label.visible = qty > 1
			quantity_label.text = "x%d" % qty

	# Show green glow for equipped items
	if glow:
		if is_equipped:
			glow.color = EQUIPPED_GLOW_COLOR
			glow.visible = true
		else:
			glow.visible = false

func _get_type_color(type: String) -> Color:
	match type:
		"item": return Color(0.4, 0.8, 0.4)      # Green for items
		"equipment": return Color(0.4, 0.6, 1.0) # Blue for equipment
		"companion": return Color(1.0, 0.7, 0.3) # Orange for companions
		"option": return Color(0.7, 0.7, 0.7)    # Gray for options
		_: return Color.WHITE

## Set selected state with animation
func set_selected(selected: bool) -> void:
	is_selected = selected
	target_scale = SELECTED_SCALE if selected else UNSELECTED_SCALE
	target_alpha = SELECTED_ALPHA if selected else UNSELECTED_ALPHA

	# Show glow when selected, or keep visible for equipped items
	if glow:
		glow.visible = selected or is_equipped
		if is_equipped and not selected:
			glow.color = EQUIPPED_GLOW_COLOR

	# Bring to front when selected
	if selected:
		z_index = 10
	else:
		z_index = 0

## Activate/use this item
func activate() -> void:
	item_activated.emit(item_data)
