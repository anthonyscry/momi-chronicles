extends Node2D
class_name ShadowBolt
## Shadow bolt projectile - travels in a direction and deals damage on contact.
## Reusable projectile pattern: instantiate, call fire(), add to scene tree.

## Movement speed in pixels/second
var speed: float = 120.0

## Damage dealt on hit (set on hitbox child)
var damage: int = 12

## Time before auto-despawn
var lifetime: float = 3.0

## Travel direction (normalized)
var direction: Vector2 = Vector2.ZERO

## Visual nodes
var visual: Polygon2D
var trail_timer: float = 0.0
const TRAIL_INTERVAL: float = 0.06

@onready var hitbox: Hitbox = $Hitbox


func _ready() -> void:
	# Create visual: diamond shape, dark purple
	visual = Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(0, -5), Vector2(4, 0), Vector2(0, 5), Vector2(-4, 0)
	])
	visual.color = Color(0.5, 0.1, 0.7, 0.9)
	add_child(visual)

	# Create glow layer behind diamond
	var glow = Polygon2D.new()
	glow.polygon = PackedVector2Array([
		Vector2(0, -7), Vector2(6, 0), Vector2(0, 7), Vector2(-6, 0)
	])
	glow.color = Color(0.4, 0.05, 0.6, 0.3)
	glow.z_index = -1
	add_child(glow)

	# Lifetime timer — auto-despawn
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_expired)

	# Connect hitbox area_entered to destroy on hit
	if hitbox:
		hitbox.damage = damage
		hitbox.hit_landed.connect(_on_hit_landed)


func _process(delta: float) -> void:
	# Move in direction
	global_position += direction * speed * delta

	# Spawn trail particles
	trail_timer += delta
	if trail_timer >= TRAIL_INTERVAL:
		trail_timer -= TRAIL_INTERVAL
		_spawn_trail_particle()


## Fire the bolt from a position toward a target position
func fire(from_pos: Vector2, target_pos: Vector2) -> void:
	global_position = from_pos
	direction = (target_pos - from_pos).normalized()
	# Rotate visual to face travel direction
	rotation = direction.angle()


## Spawn a small fading trail particle at current position
func _spawn_trail_particle() -> void:
	var particle = ColorRect.new()
	particle.size = Vector2(3, 3)
	particle.position = Vector2(-1.5, -1.5)
	particle.color = Color(0.4, 0.1, 0.6, 0.6)
	particle.global_position = global_position
	# Add to parent scene so trail persists after bolt moves
	if get_parent():
		get_parent().add_child(particle)
	else:
		return

	var tween = particle.create_tween()
	tween.tween_property(particle, "modulate:a", 0.0, 0.25)
	tween.tween_callback(particle.queue_free)


func _on_hit_landed(_hurtbox: Hurtbox) -> void:
	# Destroy bolt on hit
	_spawn_impact_particles()
	queue_free()


func _on_lifetime_expired() -> void:
	if is_instance_valid(self):
		queue_free()


## Purple burst on impact
func _spawn_impact_particles() -> void:
	if not get_parent():
		return
	for i in range(5):
		var particle = ColorRect.new()
		particle.size = Vector2(3, 3)
		particle.color = Color(0.5, 0.15, 0.7, 0.8)
		particle.global_position = global_position
		get_parent().add_child(particle)

		var angle = randf() * TAU
		var end_pos = global_position + Vector2(cos(angle), sin(angle)) * randf_range(8, 16)
		var tween = particle.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, 0.2).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, 0.25)
		tween.tween_callback(particle.queue_free)
