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
@onready var icon: TextureRect = $Icon
@onready var label: Label = $Label
@onready var glow: ColorRect = $Glow
@onready var quantity_label: Label = $QuantityLabel

const SELECTED_SCALE: float = 1.3
const UNSELECTED_SCALE: float = 0.9
const SELECTED_ALPHA: float = 1.0
const UNSELECTED_ALPHA: float = 0.75
const LERP_SPEED: float = 15.0

func _ready() -> void:
	if glow:
		glow.visible = false
	pivot_offset = size / 2

func _process(delta: float) -> void:
	scale = scale.lerp(Vector2.ONE * target_scale, LERP_SPEED * delta)
	modulate.a = lerp(modulate.a, target_alpha, LERP_SPEED * delta)

## Set up the item display
func setup(data: Dictionary) -> void:
	item_data = data
	is_equipped = data.get("equipped", false)
	
	var color = _get_type_color(data.get("type", "item"))
	if data.has("color"):
		color = data.color
	
	if data.has("player_can_equip") and not data.player_can_equip:
		color *= DIMMED_COLOR_MULTIPLIER
	
	if icon:
		var icon_path = data.get("icon", "")
		if icon_path and ResourceLoader.exists(icon_path):
			icon.texture = load(icon_path)
			icon.visible = true
		else:
			icon.texture = null
			icon.modulate = color
			icon.visible = true

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

	if glow:
		if is_equipped:
			glow.color = EQUIPPED_GLOW_COLOR
			glow.visible = true
		else:
			glow.visible = false

func _get_type_color(type: String) -> Color:
	match type:
		"item": return Color(0.4, 0.8, 0.4)
		"equipment": return Color(0.4, 0.6, 1.0)
		"companion": return Color(1.0, 0.7, 0.3)
		"option": return Color(0.7, 0.7, 0.7)
		_: return Color.WHITE

## Set selected state with animation
func set_selected(selected: bool) -> void:
	is_selected = selected
	target_scale = SELECTED_SCALE if selected else UNSELECTED_SCALE
	target_alpha = SELECTED_ALPHA if selected else UNSELECTED_ALPHA
	
	if glow:
		glow.visible = selected or is_equipped
		if is_equipped and not selected:
			glow.color = EQUIPPED_GLOW_COLOR
	
	if selected:
		z_index = 10
	else:
		z_index = 0

## Activate/use this item
func activate() -> void:
	item_activated.emit(item_data)
