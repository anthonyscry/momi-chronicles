extends Control
class_name RingItem

## Emitted when this item is selected/confirmed
signal item_activated(item_data: Dictionary)

## The data for this ring item
var item_data: Dictionary = {}

## Visual state
var is_selected: bool = false
var target_scale: float = 1.0
var target_alpha: float = 1.0

## Node references
@onready var icon: ColorRect = $Icon
@onready var label: Label = $Label
@onready var glow: ColorRect = $Glow
@onready var quantity_label: Label = $QuantityLabel

const SELECTED_SCALE: float = 1.4
const UNSELECTED_SCALE: float = 0.9
const SELECTED_ALPHA: float = 1.0
const UNSELECTED_ALPHA: float = 0.6
const LERP_SPEED: float = 12.0

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
	
	# Set icon color based on type
	var color = _get_type_color(data.get("type", "item"))
	if data.has("color"):
		color = data.color
	
	if icon:
		icon.color = color
		icon.visible = true
	
	# Set label
	if label and data.has("name"):
		label.text = data.name
	
	# Set quantity (for stackable items)
	if quantity_label:
		var qty = data.get("quantity", 1)
		quantity_label.visible = qty > 1
		quantity_label.text = "x%d" % qty

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
	
	# Show glow when selected
	if glow:
		glow.visible = selected
	
	# Bring to front when selected
	if selected:
		z_index = 10
	else:
		z_index = 0

## Activate/use this item
func activate() -> void:
	item_activated.emit(item_data)
