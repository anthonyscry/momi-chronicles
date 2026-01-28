extends Area2D
class_name InteractiveGrass
## A grass tuft that sways when the player or enemies walk through it.
## Place in zones to add environmental reactivity.
##
## Usage: Add InteractiveGrass nodes to zones, or spawn programmatically.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Grass blade visual
@export var blade_color: Color = Color(0.3, 0.7, 0.25, 0.8)
@export var blade_count: int = 3
@export var blade_height: float = 8.0
@export var sway_strength: float = 0.4  # Max rotation on interact

# =============================================================================
# STATE
# =============================================================================

var _blades: Array[Polygon2D] = []
var _is_swaying: bool = false
var _idle_tween: Tween = null

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Create collision shape for detection
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 10.0
	shape.shape = circle
	add_child(shape)
	
	# Set collision - detect player and enemies
	collision_layer = 0
	collision_mask = 2 | 4  # Player layer (2) + Enemy layer (4)
	monitoring = true
	monitorable = false
	
	# Create grass blades
	_create_blades()
	
	# Connect detection
	body_entered.connect(_on_body_entered)
	
	# Start idle sway
	_start_idle_sway()


func _create_blades() -> void:
	for i in range(blade_count):
		var blade = Polygon2D.new()
		# Triangle shape pointing up
		var width = randf_range(2, 4)
		var height = blade_height + randf_range(-2, 2)
		blade.polygon = PackedVector2Array([
			Vector2(-width / 2, 0),
			Vector2(0, -height),
			Vector2(width / 2, 0)
		])
		
		# Slight color variance
		blade.color = blade_color
		blade.color.h += randf_range(-0.03, 0.03)
		blade.color.s += randf_range(-0.1, 0.1)
		
		# Offset each blade slightly
		blade.position = Vector2(randf_range(-4, 4), randf_range(-2, 2))
		blade.z_index = -1
		
		add_child(blade)
		_blades.append(blade)


## Gentle idle sway
func _start_idle_sway() -> void:
	if _idle_tween and _idle_tween.is_valid():
		_idle_tween.kill()
	
	_idle_tween = create_tween().set_loops()
	var sway = randf_range(0.03, 0.08)
	var speed = randf_range(1.5, 2.5)
	_idle_tween.tween_property(self, "rotation", sway, speed)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_idle_tween.tween_property(self, "rotation", -sway, speed)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


## React when something walks through
func _on_body_entered(body: Node2D) -> void:
	if _is_swaying:
		return
	_is_swaying = true
	
	# Determine sway direction based on body movement
	var sway_dir = 1.0
	if body.velocity.x != 0:
		sway_dir = sign(body.velocity.x)
	elif body.global_position.x < global_position.x:
		sway_dir = 1.0
	else:
		sway_dir = -1.0
	
	# Stop idle sway
	if _idle_tween and _idle_tween.is_valid():
		_idle_tween.kill()
	
	# Dramatic sway in walk direction then settle
	var tween = create_tween()
	tween.tween_property(self, "rotation", sway_strength * sway_dir, 0.1)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", -sway_strength * sway_dir * 0.4, 0.15)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation", sway_strength * sway_dir * 0.15, 0.12)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation", 0.0, 0.2)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func():
		_is_swaying = false
		_start_idle_sway()
	)
	
	# Optionally spawn a tiny leaf particle
	if randf() < 0.3:
		_spawn_leaf_particle()


func _spawn_leaf_particle() -> void:
	var leaf = ColorRect.new()
	leaf.size = Vector2(2, 2)
	leaf.color = Color(blade_color.r, blade_color.g, blade_color.b, 0.5)
	leaf.global_position = global_position + Vector2(randf_range(-4, 4), -blade_height)
	leaf.z_index = 50
	get_tree().current_scene.add_child(leaf)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(leaf, "global_position:y", leaf.global_position.y - randf_range(8, 15), 0.6)
	tween.tween_property(leaf, "global_position:x", leaf.global_position.x + randf_range(-10, 10), 0.6)
	tween.tween_property(leaf, "modulate:a", 0.0, 0.5).set_delay(0.1)
	tween.chain().tween_callback(leaf.queue_free)
