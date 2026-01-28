extends Control
class_name BuffIcons
## Shows active buff/debuff icons above the player as colored squares with text.
## Connects to Events.buff_applied / buff_expired.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Icon colors by effect type (matches BuffConsumable.EffectType enum)
const ICON_COLORS: Dictionary = {
	0: Color(1, 0.4, 0.3),      # ATTACK_BOOST - Red
	1: Color(0.3, 0.5, 1),      # DEFENSE_BOOST - Blue
	2: Color(0.3, 1, 0.5),      # SPEED_BOOST - Green
	3: Color(1, 1, 0.3),        # HEAL_OVER_TIME - Yellow
	4: Color(0.7, 0.3, 1),      # CRIT_BOOST - Purple
}

const ICON_LABELS: Dictionary = {
	0: "ATK",
	1: "DEF",
	2: "SPD",
	3: "HOT",
	4: "CRT",
}

const ICON_SIZE: float = 14.0
const ICON_SPACING: float = 2.0

# =============================================================================
# STATE
# =============================================================================

var _active_buffs: Dictionary = {}  # effect_type -> {node, timer}

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	Events.buff_applied.connect(_on_buff_applied)
	Events.buff_expired.connect(_on_buff_expired)
	
	# Position at bottom-right of HUD (near health bar area)
	# Will be repositioned by parent


func _on_buff_applied(effect_type: int, value: float, duration: float) -> void:
	# Remove existing icon for this buff (refresh)
	if _active_buffs.has(effect_type):
		_remove_buff_icon(effect_type)
	
	# Create icon
	var icon = _create_buff_icon(effect_type)
	add_child(icon)
	
	# Position based on active buff count
	_reposition_icons()
	
	# Pop-in animation
	icon.scale = Vector2(0.3, 0.3)
	icon.pivot_offset = Vector2(ICON_SIZE / 2, ICON_SIZE / 2)
	var tween = create_tween()
	tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Store reference
	_active_buffs[effect_type] = {"node": icon}
	
	# Flash when about to expire (last 3 seconds)
	if duration > 3.0:
		get_tree().create_timer(duration - 3.0).timeout.connect(func():
			if _active_buffs.has(effect_type) and is_instance_valid(_active_buffs[effect_type].node):
				_start_expire_flash(_active_buffs[effect_type].node)
		)


func _on_buff_expired(effect_type: int) -> void:
	_remove_buff_icon(effect_type)


func _create_buff_icon(effect_type: int) -> Control:
	var container = Control.new()
	container.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
	
	# Background square
	var bg = ColorRect.new()
	bg.size = Vector2(ICON_SIZE, ICON_SIZE)
	bg.color = ICON_COLORS.get(effect_type, Color(0.5, 0.5, 0.5))
	bg.color.a = 0.8
	container.add_child(bg)
	
	# Border
	var border = ColorRect.new()
	border.size = Vector2(ICON_SIZE, ICON_SIZE)
	border.color = Color(1, 1, 1, 0.3)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(border)
	
	# Inner (slightly smaller)
	var inner = ColorRect.new()
	inner.size = Vector2(ICON_SIZE - 2, ICON_SIZE - 2)
	inner.position = Vector2(1, 1)
	inner.color = ICON_COLORS.get(effect_type, Color(0.5, 0.5, 0.5))
	container.add_child(inner)
	
	# Label
	var label = Label.new()
	label.text = ICON_LABELS.get(effect_type, "?")
	label.add_theme_font_size_override("font_size", 6)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 1)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(0, 1)
	label.size = Vector2(ICON_SIZE, ICON_SIZE)
	container.add_child(label)
	
	return container


func _remove_buff_icon(effect_type: int) -> void:
	if not _active_buffs.has(effect_type):
		return
	
	var icon = _active_buffs[effect_type].node
	_active_buffs.erase(effect_type)
	
	if is_instance_valid(icon):
		# Pop-out animation
		var tween = create_tween()
		tween.tween_property(icon, "scale", Vector2(0.1, 0.1), 0.1)
		tween.tween_callback(icon.queue_free)
		tween.tween_callback(_reposition_icons)


func _reposition_icons() -> void:
	var idx = 0
	for effect_type in _active_buffs:
		var data = _active_buffs[effect_type]
		if is_instance_valid(data.node):
			data.node.position = Vector2(idx * (ICON_SIZE + ICON_SPACING), 0)
			idx += 1


func _start_expire_flash(icon: Control) -> void:
	if not is_instance_valid(icon):
		return
	var flash = create_tween().set_loops()
	flash.tween_property(icon, "modulate:a", 0.3, 0.3)
	flash.tween_property(icon, "modulate:a", 1.0, 0.3)
