extends "res://characters/enemies/enemy_base.gd"
class_name RoofRat

## Roof Rat enemy - wall-running ambusher that drops from surfaces.
## 45 HP, 20 damage ambush drop attack, raycast-based surface detection.

## Wall-running constants
const WALL_RUN_SPEED: float = 150.0
const WALL_PATROL_SPEED: float = 80.0
const AMBUSH_DAMAGE: float = 20.0
const AMBUSH_DROP_HEIGHT: float = 80.0
const AMBUSH_DURATION: float = 0.35
const RETREAT_SPEED: float = 200.0
const DETECTION_RANGE: float = 280.0
const AMBUSH_TRIGGER_DISTANCE: float = 120.0
const CORNER_DETECTION_RADIUS: float = 64.0
const RAYCAST_LENGTH: float = 24.0
const RAYCAST_OFFSET: float = 8.0
const STEALTH_ALPHA: float = 0.20
const WALL_SQUISH_FACTOR: float = 0.7
const NO_TARGET_TIMEOUT: float = 4.0

## Roof Rat-specific properties
var is_stealthed: bool = true
var stealth_alpha: float = STEALTH_ALPHA
var wall_squish_factor: float = WALL_SQUISH_FACTOR
var current_surface_normal: Vector2 = Vector2.UP
var is_on_wall: bool = false
var no_target_timer: float = 0.0
var last_ambush_position: Vector2 = Vector2.ZERO
var wall_raycast: RayCast2D = null

func _ready() -> void:
	# Set roof rat-specific stats
	patrol_speed = WALL_PATROL_SPEED
	chase_speed = WALL_RUN_SPEED
	detection_range = DETECTION_RANGE
	attack_range = AMBUSH_TRIGGER_DISTANCE
	attack_damage = 20
	attack_cooldown = 2.0
	knockback_force = 100.0
	exp_value = 25
	
	# Call parent ready
	super._ready()
	
	# Setup wall detection
	_setup_wall_detection()
	_setup_detection_area()
	
	# Roof rat appearance: brown/gray
	if sprite:
		sprite.modulate = Color(0.55, 0.45, 0.35)

func _setup_wall_detection() -> void:
	# Create raycast for wall detection if it doesn't exist
	if not has_node("WallRaycast"):
		wall_raycast = RayCast2D.new()
		wall_raycast.name = "WallRaycast"
		wall_raycast.target_position = Vector2(RAYCAST_LENGTH, 0)
		wall_raycast.collide_with_areas = false
		wall_raycast.collide_with_bodies = true
		wall_raycast.enabled = true
		add_child(wall_raycast)
	else:
		wall_raycast = $WallRaycast

func _setup_detection_area() -> void:
	# Ensure detection area has proper radius
	if detection_area and detection_area.has_node("CollisionShape2D"):
		var shape = detection_area.get_node("CollisionShape2D")
		shape.shape = CircleShape2D.new()
		shape.shape.radius = DETECTION_RANGE

## Override to use WallAmbush instead of generic Attack
func get_attack_state_name() -> String:
	return "WallAmbush"

## Check if on wall surface using raycast
func is_on_wall_surface() -> bool:
	if not wall_raycast:
		return false
	wall_raycast.force_raycast_update()
	return wall_raycast.is_colliding()

## Get wall surface normal
func get_wall_normal() -> Vector2:
	if not wall_raycast:
		return Vector2.UP
	wall_raycast.force_raycast_update()
	if wall_raycast.is_colliding():
		return wall_raycast.get_collision_normal()
	return Vector2.UP

## Roof Rat drops: 60% coins, 25% health, 10% speed treat, 5% smoke bomb
func _init_default_drops() -> void:
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 0.6, "min": 1, "max": 2},
		{"scene": HEALTH_PICKUP_SCENE, "chance": 0.25, "min": 1, "max": 1},
		{"item_id": "speed_treat", "chance": 0.1, "min": 1, "max": 1},
		{"item_id": "smoke_bomb", "chance": 0.05, "min": 1, "max": 1},
	]
