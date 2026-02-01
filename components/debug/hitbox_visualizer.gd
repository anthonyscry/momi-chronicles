extends Node2D
class_name HitboxVisualizer
## Debug visualization component for hitboxes and hurtboxes.
## Shows collision shapes with colored overlays and status labels during debug mode.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Color for hitbox visualization (damage-dealing)
const HITBOX_COLOR := Color(1.0, 0.0, 0.0, 0.3)  # Red, semi-transparent

## Color for hurtbox visualization (damage-receiving)
const HURTBOX_COLOR := Color(0.0, 1.0, 0.0, 0.3)  # Green, semi-transparent

## Color for inactive collision shapes
const INACTIVE_COLOR := Color(0.5, 0.5, 0.5, 0.2)  # Gray, more transparent

## Color for text labels
const LABEL_COLOR := Color(1.0, 1.0, 1.0, 1.0)  # White

## Font size for labels
const LABEL_FONT_SIZE := 12

# =============================================================================
# STATE
# =============================================================================

## Whether debug visualization is currently enabled
var is_enabled: bool = false

## Reference to parent entity's hitboxes and hurtboxes
var _tracked_areas: Array[Area2D] = []

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Start hidden by default
	hide()

	# Set to process only when needed
	set_process(false)

func _process(_delta: float) -> void:
	# Redraw every frame to show live state
	queue_redraw()

func _draw() -> void:
	if not is_enabled:
		return

	# Draw all tracked hitboxes and hurtboxes
	for area in _tracked_areas:
		if not is_instance_valid(area):
			continue

		_draw_area(area)

# =============================================================================
# PUBLIC METHODS
# =============================================================================

## Enable debug visualization
func enable() -> void:
	is_enabled = true
	show()
	set_process(true)
	queue_redraw()

## Disable debug visualization
func disable() -> void:
	is_enabled = false
	hide()
	set_process(false)
	queue_redraw()

## Toggle debug visualization on/off
func toggle() -> void:
	if is_enabled:
		disable()
	else:
		enable()

## Track a hitbox or hurtbox for visualization
func track_area(area: Area2D) -> void:
	if area and area not in _tracked_areas:
		_tracked_areas.append(area)

## Stop tracking a specific area
func untrack_area(area: Area2D) -> void:
	_tracked_areas.erase(area)

## Clear all tracked areas
func clear_tracked_areas() -> void:
	_tracked_areas.clear()

## Auto-discover and track all hitboxes/hurtboxes in parent entity
func auto_track_parent() -> void:
	if not owner:
		return

	# Find all Hitbox and Hurtbox children recursively
	_find_and_track_areas(owner)

# =============================================================================
# PRIVATE METHODS
# =============================================================================

## Recursively find and track hitboxes/hurtboxes
func _find_and_track_areas(node: Node) -> void:
	# Check if this node is a Hitbox or Hurtbox
	if node is Hitbox or node is Hurtbox:
		track_area(node as Area2D)

	# Recursively check children
	for child in node.get_children():
		_find_and_track_areas(child)

## Draw a single hitbox or hurtbox
func _draw_area(area: Area2D) -> void:
	# Determine color based on type and state
	var color: Color = _get_area_color(area)

	# Get collision shapes
	for child in area.get_children():
		if not child is CollisionShape2D:
			continue

		var collision_shape: CollisionShape2D = child
		if not collision_shape.shape:
			continue

		# Calculate position relative to visualizer
		var shape_pos := area.global_position - global_position
		if collision_shape.position != Vector2.ZERO:
			shape_pos += collision_shape.position

		# Draw shape based on type
		_draw_shape(collision_shape.shape, shape_pos, collision_shape.rotation, color)

		# Draw label with info
		_draw_label(area, shape_pos)

## Get the appropriate color for an area based on type and state
func _get_area_color(area: Area2D) -> Color:
	# Check if area is active/monitoring
	var is_active := area.monitoring or area.monitorable

	# Inactive areas get gray color
	if not is_active:
		return INACTIVE_COLOR

	# Hitboxes get red, Hurtboxes get green
	if area is Hitbox:
		return HITBOX_COLOR
	elif area is Hurtbox:
		# Check if invincible
		if area.is_invincible:
			return Color(0.0, 0.5, 1.0, 0.3)  # Blue for invincible
		return HURTBOX_COLOR

	# Default color
	return INACTIVE_COLOR

## Draw a collision shape
func _draw_shape(shape: Shape2D, pos: Vector2, rotation: float, color: Color) -> void:
	if shape is CircleShape2D:
		_draw_circle_shape(shape as CircleShape2D, pos, color)
	elif shape is RectangleShape2D:
		_draw_rectangle_shape(shape as RectangleShape2D, pos, rotation, color)
	elif shape is CapsuleShape2D:
		_draw_capsule_shape(shape as CapsuleShape2D, pos, rotation, color)

## Draw a circle collision shape
func _draw_circle_shape(shape: CircleShape2D, pos: Vector2, color: Color) -> void:
	draw_circle(pos, shape.radius, color)
	# Draw outline
	draw_arc(pos, shape.radius, 0, TAU, 32, Color(color.r, color.g, color.b, 1.0), 1.0)

## Draw a rectangle collision shape
func _draw_rectangle_shape(shape: RectangleShape2D, pos: Vector2, rotation: float, color: Color) -> void:
	var size := shape.size
	var rect := Rect2(-size / 2.0, size)

	# Create transform for rotation
	var transform := Transform2D(rotation, pos)

	# Draw filled rectangle
	draw_set_transform_matrix(transform)
	draw_rect(rect, color)

	# Draw outline
	draw_rect(rect, Color(color.r, color.g, color.b, 1.0), false, 1.0)

	# Reset transform
	draw_set_transform_matrix(Transform2D.IDENTITY)

## Draw a capsule collision shape
func _draw_capsule_shape(shape: CapsuleShape2D, pos: Vector2, rotation: float, color: Color) -> void:
	# Approximate capsule as circle (simplified for debug visualization)
	var radius := max(shape.radius, shape.height / 2.0)
	draw_circle(pos, radius, color)
	draw_arc(pos, radius, 0, TAU, 32, Color(color.r, color.g, color.b, 1.0), 1.0)

## Draw info label for an area
func _draw_label(area: Area2D, pos: Vector2) -> void:
	var label_text := ""

	# Build label text based on area type
	if area is Hitbox:
		var hitbox: Hitbox = area as Hitbox
		label_text = "DMG: %d" % hitbox.damage
		if not area.monitoring:
			label_text += " [INACTIVE]"
	elif area is Hurtbox:
		label_text = "HURTBOX"
		if area.is_invincible:
			label_text += " [INVINCIBLE]"

	# Draw label background
	var font := ThemeDB.fallback_font
	var font_size := LABEL_FONT_SIZE
	var text_size := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var label_pos := pos + Vector2(-text_size.x / 2.0, -20)

	# Draw background rectangle
	var bg_rect := Rect2(label_pos - Vector2(2, 2), text_size + Vector2(4, 4))
	draw_rect(bg_rect, Color(0, 0, 0, 0.7))

	# Draw text
	draw_string(font, label_pos + Vector2(0, text_size.y), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, LABEL_COLOR)
