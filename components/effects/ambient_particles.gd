extends Node2D
class_name AmbientParticles
## Spawns floating ambient particles around the camera viewport.
## Automatically adapts to zone type (dust motes, leaves, fireflies).
##
## Add as child of a zone or auto-spawn via EffectsManager.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Particle styles per zone type
enum ParticleStyle { DUST_MOTES, LEAVES, FIREFLIES }

@export var style: ParticleStyle = ParticleStyle.DUST_MOTES
@export var max_particles: int = 15
@export var spawn_interval: float = 0.8
@export var viewport_size: Vector2 = Vector2(384, 216)

# =============================================================================
# STATE
# =============================================================================

var _spawn_timer: float = 0.0
var _active_particles: Array[Node2D] = []

# =============================================================================
# LIFECYCLE
# =============================================================================

func _process(delta: float) -> void:
	_spawn_timer += delta
	if _spawn_timer >= spawn_interval and _active_particles.size() < max_particles:
		_spawn_timer = 0.0
		_spawn_particle()
	
	# Clean up finished particles
	_active_particles = _active_particles.filter(func(p): return is_instance_valid(p))


func _spawn_particle() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var cam_center = player.global_position
	
	match style:
		ParticleStyle.DUST_MOTES:
			_spawn_dust_mote(cam_center)
		ParticleStyle.LEAVES:
			_spawn_leaf(cam_center)
		ParticleStyle.FIREFLIES:
			_spawn_firefly(cam_center)


## Floating dust motes - gentle upward drift
func _spawn_dust_mote(center: Vector2) -> void:
	var mote = ColorRect.new()
	mote.size = Vector2(2, 2)
	mote.color = Color(1, 1, 0.9, randf_range(0.15, 0.3))
	mote.z_index = 50
	
	# Random position within viewport
	var offset = Vector2(
		randf_range(-viewport_size.x / 2, viewport_size.x / 2),
		randf_range(-viewport_size.y / 2, viewport_size.y / 2)
	)
	mote.global_position = center + offset
	get_tree().current_scene.add_child(mote)
	_active_particles.append(mote)
	
	# Gentle drift upward + slight horizontal sway
	var drift_time = randf_range(3.0, 5.0)
	var drift_x = randf_range(-20, 20)
	var drift_y = randf_range(-30, -15)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(mote, "global_position:x", mote.global_position.x + drift_x, drift_time)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(mote, "global_position:y", mote.global_position.y + drift_y, drift_time)
	# Fade in then out
	mote.modulate.a = 0.0
	tween.tween_property(mote, "modulate:a", 1.0, 0.5)
	tween.chain().tween_property(mote, "modulate:a", 0.0, 1.0).set_delay(drift_time - 1.5)
	tween.chain().tween_callback(func():
		_active_particles.erase(mote)
		mote.queue_free()
	)


## Falling leaves - drift down with side-to-side sway
func _spawn_leaf(center: Vector2) -> void:
	var leaf = ColorRect.new()
	leaf.size = Vector2(4, 3)
	leaf.pivot_offset = leaf.size / 2
	# Autumn leaf colors
	var colors = [Color(0.8, 0.5, 0.2), Color(0.7, 0.3, 0.1), Color(0.9, 0.7, 0.2), Color(0.6, 0.4, 0.15)]
	leaf.color = colors[randi() % colors.size()]
	leaf.color.a = randf_range(0.4, 0.7)
	leaf.z_index = 45
	
	# Spawn above viewport
	var x_pos = center.x + randf_range(-viewport_size.x / 2, viewport_size.x / 2)
	leaf.global_position = Vector2(x_pos, center.y - viewport_size.y / 2 - 10)
	get_tree().current_scene.add_child(leaf)
	_active_particles.append(leaf)
	
	# Fall with sinusoidal sway
	var fall_time = randf_range(4.0, 7.0)
	var fall_y = viewport_size.y + 30
	var sway_amount = randf_range(20, 40)
	
	var tween = create_tween()
	tween.set_parallel(true)
	# Fall down
	tween.tween_property(leaf, "global_position:y", leaf.global_position.y + fall_y, fall_time)
	# Sway left-right (multiple back-and-forth)
	var sway_tween = create_tween().set_loops(int(fall_time / 1.5))
	sway_tween.tween_property(leaf, "global_position:x", leaf.global_position.x + sway_amount, 0.75)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	sway_tween.tween_property(leaf, "global_position:x", leaf.global_position.x - sway_amount, 0.75)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	# Rotate gently
	var rot_tween = create_tween().set_loops(int(fall_time / 2.0))
	rot_tween.tween_property(leaf, "rotation", 0.3, 1.0).set_ease(Tween.EASE_IN_OUT)
	rot_tween.tween_property(leaf, "rotation", -0.3, 1.0).set_ease(Tween.EASE_IN_OUT)
	
	# Cleanup after falling
	tween.chain().tween_callback(func():
		sway_tween.kill()
		rot_tween.kill()
		_active_particles.erase(leaf)
		leaf.queue_free()
	)


## Fireflies - gentle glow that fades in/out while wandering
func _spawn_firefly(center: Vector2) -> void:
	var fly = ColorRect.new()
	fly.size = Vector2(3, 3)
	fly.color = Color(0.8, 1, 0.3, 0)  # Yellow-green glow
	fly.z_index = 55
	
	var offset = Vector2(
		randf_range(-viewport_size.x / 2, viewport_size.x / 2),
		randf_range(-viewport_size.y / 4, viewport_size.y / 4)  # More centered
	)
	fly.global_position = center + offset
	get_tree().current_scene.add_child(fly)
	_active_particles.append(fly)
	
	# Wander in lazy circles
	var life_time = randf_range(4.0, 8.0)
	var wander_radius = randf_range(10, 25)
	var start_pos = fly.global_position
	var angle_offset = randf() * TAU
	
	# Pulsing glow
	var glow_tween = create_tween().set_loops(int(life_time / 1.2))
	glow_tween.tween_property(fly, "color:a", randf_range(0.5, 0.8), 0.6)\
		.set_ease(Tween.EASE_IN_OUT)
	glow_tween.tween_property(fly, "color:a", randf_range(0.05, 0.15), 0.6)\
		.set_ease(Tween.EASE_IN_OUT)
	
	# Circular wander
	var move_tween = create_tween().set_loops(int(life_time / 2.0))
	var steps = 8
	for i in range(steps):
		var a = angle_offset + (float(i) / steps) * TAU
		var target = start_pos + Vector2(cos(a), sin(a)) * wander_radius
		move_tween.tween_property(fly, "global_position", target, 2.0 / steps)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	# Cleanup
	get_tree().create_timer(life_time).timeout.connect(func():
		glow_tween.kill()
		move_tween.kill()
		if is_instance_valid(fly):
			_active_particles.erase(fly)
			fly.queue_free()
	)


## Set style based on zone name
func set_style_for_zone(zone_name: String) -> void:
	match zone_name:
		"neighborhood", "test_zone":
			style = ParticleStyle.DUST_MOTES
			max_particles = 12
		"backyard":
			style = ParticleStyle.LEAVES
			max_particles = 10
		"boss_arena":
			style = ParticleStyle.FIREFLIES
			max_particles = 18
		_:
			style = ParticleStyle.DUST_MOTES
			max_particles = 12
