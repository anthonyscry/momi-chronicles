extends Node
## Manages spawning and pooling of visual effects.
## Call EffectsManager.spawn_effect("hit_spark", position) to create effects.

# =============================================================================
# EFFECT SCENES
# =============================================================================

var effect_scenes: Dictionary = {
	"hit_spark": preload("res://components/effects/hit_spark.tscn"),
	"dust_puff": preload("res://components/effects/dust_puff.tscn"),
	"death_poof": preload("res://components/effects/death_poof.tscn"),
	"damage_number": preload("res://components/effects/damage_number.tscn")
}

# =============================================================================
# PICKUP SYSTEM
# =============================================================================

var health_pickup_scene: PackedScene = preload("res://components/health/health_pickup.tscn")

## Base drop chance (0.0 to 1.0)
const BASE_DROP_CHANCE: float = 0.35

## Bonus drop chance per missing 10% of player health
const LOW_HEALTH_DROP_BONUS: float = 0.08

## Drop chance caps
const MIN_DROP_CHANCE: float = 0.2
const MAX_DROP_CHANCE: float = 0.85

## Heal amounts by enemy type
const HEAL_AMOUNTS: Dictionary = {
	"default": 15,
	"crow": 10,      # Weaker enemy = less heal
	"raccoon": 20,   # Standard enemy
	"boss": 50       # Boss drops big heal
}

# =============================================================================
# EFFECT POOLING (for performance)
# =============================================================================

var effect_pools: Dictionary = {}
const POOL_SIZE: int = 10

# =============================================================================
# SCREEN SHAKE
# =============================================================================

var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var original_camera_offset: Vector2 = Vector2.ZERO

# =============================================================================
# IMPACT FREEZE (HITSTOP)
# =============================================================================

var freeze_timer: SceneTreeTimer = null
var is_frozen: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Pre-warm pools
	for effect_name in effect_scenes.keys():
		effect_pools[effect_name] = []
	
	# Connect to combat events for automatic effects
	_connect_signals()
	print("EffectsManager ready")


func _process(delta: float) -> void:
	_process_screen_shake(delta)


func _process_screen_shake(delta: float) -> void:
	if shake_timer <= 0.0:
		return
	
	shake_timer -= delta
	
	var player = get_tree().get_first_node_in_group("player")
	if player == null or not player.has_node("Camera2D"):
		return
	
	var camera: Camera2D = player.get_node("Camera2D")
	
	if shake_timer > 0.0:
		# Apply random shake offset based on remaining intensity
		var current_intensity = shake_intensity * (shake_timer / shake_duration)
		var offset = Vector2(
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity)
		)
		camera.offset = original_camera_offset + offset
	else:
		# Reset camera when shake ends
		camera.offset = original_camera_offset
		shake_timer = 0.0


## Combo shake scaling multipliers
const COMBO_SHAKE_MULTIPLIERS = [1.0, 1.5, 2.5]

func _connect_signals() -> void:
	Events.player_hit_enemy.connect(_on_player_hit_enemy)
	Events.enemy_damaged.connect(_on_enemy_damaged)
	Events.enemy_defeated.connect(_on_enemy_defeated)
	Events.player_dodged.connect(_on_player_dodged)
	Events.player_damaged.connect(_on_player_damaged)
	Events.player_special_attacked.connect(_on_player_special_attacked)
	Events.combo_changed.connect(_on_combo_hit)
	Events.combo_completed.connect(_on_combo_completed)
	Events.player_leveled_up.connect(_on_player_level_up)
	Events.exp_gained.connect(_on_exp_gained)
	# Combat juice - special abilities
	Events.player_ground_pound_impact.connect(_on_ground_pound_impact)
	Events.player_charge_started.connect(_on_charge_started)
	Events.player_charge_released.connect(_on_charge_released)
	Events.player_parried.connect(_on_parry_success)

# =============================================================================
# SPAWN EFFECTS
# =============================================================================

## Spawn an effect at a world position
func spawn_effect(effect_name: String, position: Vector2, params: Dictionary = {}) -> Node:
	if not effect_scenes.has(effect_name):
		push_warning("EffectsManager: Unknown effect '%s'" % effect_name)
		return null
	
	var effect = _get_or_create_effect(effect_name)
	if effect == null:
		return null
	
	# Add to scene tree if needed
	if not effect.is_inside_tree():
		_get_effects_container().add_child(effect)
	
	# Position and configure
	effect.global_position = position
	effect.show()
	
	# Apply any custom parameters
	if effect.has_method("setup"):
		effect.setup(params)
	
	# Start the effect
	if effect.has_method("play"):
		effect.play()
	
	return effect


## Spawn hit spark between attacker and target
func spawn_hit_spark(attacker_pos: Vector2, target_pos: Vector2) -> void:
	var mid_point = (attacker_pos + target_pos) / 2.0
	# Offset slightly toward target
	var direction = (target_pos - attacker_pos).normalized()
	var spawn_pos = mid_point + direction * 5.0
	spawn_effect("hit_spark", spawn_pos)


## Spawn dust puff at position
func spawn_dust(position: Vector2, direction: Vector2 = Vector2.ZERO) -> void:
	spawn_effect("dust_puff", position, {"direction": direction})


## Spawn death poof at position
func spawn_death_poof(position: Vector2) -> void:
	spawn_effect("death_poof", position)


## Spawn floating damage number
func spawn_damage_number(position: Vector2, amount: int, is_critical: bool = false) -> void:
	spawn_effect("damage_number", position, {
		"amount": amount,
		"is_critical": is_critical
	})


# =============================================================================
# HEALTH PICKUP SPAWNING
# =============================================================================

## Try to spawn a health pickup at enemy position
func _try_spawn_health_pickup(enemy: Node) -> void:
	if enemy == null:
		return
	
	# Calculate drop chance based on player health
	var drop_chance = _calculate_drop_chance()
	
	# Roll for drop
	if randf() > drop_chance:
		return  # No drop this time
	
	# Spawn the pickup
	spawn_health_pickup(enemy.global_position, _get_enemy_heal_amount(enemy))


## Spawn a health pickup at position
func spawn_health_pickup(pos: Vector2, heal_amount: int = 15) -> void:
	var pickup = health_pickup_scene.instantiate()
	pickup.heal_amount = heal_amount
	pickup.global_position = pos + Vector2(randf_range(-8, 8), randf_range(-8, 8))  # Slight random offset
	
	# Add to scene
	var container = _get_effects_container()
	container.add_child(pickup)


## Calculate drop chance based on player health
func _calculate_drop_chance() -> float:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return BASE_DROP_CHANCE
	
	var health_percent = 1.0
	if player.has_node("HealthComponent"):
		var health = player.get_node("HealthComponent")
		health_percent = health.get_health_percent()
	
	# Bonus for low health: +8% per 10% missing health
	var missing_health_percent = 1.0 - health_percent
	var bonus = (missing_health_percent / 0.1) * LOW_HEALTH_DROP_BONUS
	
	var final_chance = clampf(BASE_DROP_CHANCE + bonus, MIN_DROP_CHANCE, MAX_DROP_CHANCE)
	return final_chance


## Get heal amount based on enemy type
func _get_enemy_heal_amount(enemy: Node) -> int:
	if enemy == null:
		return HEAL_AMOUNTS["default"]
	
	var enemy_name = enemy.name.to_lower()
	
	# Check for boss
	if "boss" in enemy_name or enemy.is_in_group("bosses"):
		return HEAL_AMOUNTS["boss"]
	
	# Check for specific enemy types
	for enemy_type in HEAL_AMOUNTS.keys():
		if enemy_type in enemy_name:
			return HEAL_AMOUNTS[enemy_type]
	
	return HEAL_AMOUNTS["default"]


# =============================================================================
# SCREEN SHAKE
# =============================================================================

## Shake the camera with given intensity and duration
func screen_shake(intensity: float = 3.0, duration: float = 0.15) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null or not player.has_node("Camera2D"):
		return
	
	var camera: Camera2D = player.get_node("Camera2D")
	
	# Store original offset if starting new shake
	if shake_timer <= 0.0:
		original_camera_offset = camera.offset
	
	# Use strongest shake if overlapping
	shake_intensity = max(shake_intensity, intensity)
	shake_duration = duration
	shake_timer = duration


## Light shake for minor impacts
func shake_light() -> void:
	screen_shake(2.0, 0.1)


## Medium shake for regular hits
func shake_medium() -> void:
	screen_shake(4.0, 0.15)


## Heavy shake for big impacts
func shake_heavy() -> void:
	screen_shake(6.0, 0.2)


# =============================================================================
# IMPACT FREEZE (HITSTOP)
# =============================================================================

## Briefly freeze the game for impact feel
func impact_freeze(duration: float = 0.05) -> void:
	if is_frozen:
		return  # Don't stack freezes
	
	is_frozen = true
	Engine.time_scale = 0.0
	
	# Create timer that ignores time_scale (process_always)
	freeze_timer = get_tree().create_timer(duration, true, false, true)
	freeze_timer.timeout.connect(_on_freeze_timeout)


func _on_freeze_timeout() -> void:
	Engine.time_scale = 1.0
	is_frozen = false


## Light hitstop for regular hits
func hitstop_light() -> void:
	impact_freeze(0.03)


## Heavy hitstop for kills/big hits
func hitstop_heavy() -> void:
	impact_freeze(0.08)


# =============================================================================
# POOLING HELPERS
# =============================================================================

func _get_or_create_effect(effect_name: String) -> Node:
	var pool = effect_pools.get(effect_name, [])
	
	# Try to find an available effect in pool
	for effect in pool:
		if effect != null and not effect.visible:
			return effect
	
	# Create new effect if pool not full
	if pool.size() < POOL_SIZE:
		var scene = effect_scenes[effect_name]
		var new_effect = scene.instantiate()
		pool.append(new_effect)
		effect_pools[effect_name] = pool
		return new_effect
	
	# Pool full, reuse oldest (first in array)
	if pool.size() > 0:
		return pool[0]
	
	return null


func _get_effects_container() -> Node:
	# Get or create a container for effects in the current scene
	var root = get_tree().current_scene
	if root == null:
		return self
	
	var container = root.get_node_or_null("EffectsContainer")
	if container == null:
		container = Node2D.new()
		container.name = "EffectsContainer"
		root.add_child(container)
	
	return container

# =============================================================================
# EVENT HANDLERS
# =============================================================================

func _on_player_hit_enemy(enemy: Node) -> void:
	if enemy == null:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		spawn_hit_spark(player.global_position, enemy.global_position)
	
	# Light hitstop for hitting enemy
	hitstop_light()


func _on_enemy_damaged(enemy: Node, amount: int) -> void:
	if enemy == null:
		return
	
	# Spawn damage number above the enemy
	spawn_damage_number(enemy.global_position + Vector2(0, -16), amount)
	
	# Light screen shake for enemy damage
	shake_light()


func _on_enemy_defeated(enemy: Node) -> void:
	if enemy == null:
		return
	
	spawn_death_poof(enemy.global_position)
	
	# Heavy effects for kill
	shake_medium()
	hitstop_heavy()
	
	# Try to spawn health pickup
	_try_spawn_health_pickup(enemy)


func _on_player_dodged() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		spawn_dust(player.global_position)


func _on_player_damaged(amount: int) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		spawn_damage_number(player.global_position + Vector2(0, -10), amount)
	
	# Screen shake when player takes damage
	shake_medium()


func _on_player_special_attacked() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Spawn dust puffs in a circle around player for spin effect
		for i in range(4):
			var angle = (i / 4.0) * TAU
			var offset = Vector2(cos(angle), sin(angle)) * 12.0
			spawn_dust(player.global_position + offset)
		
		# Light screen shake for power
		shake_light()


func _on_combo_hit(combo_count: int) -> void:
	if combo_count == 0:
		return
	
	# Shake intensity increases with combo
	var index = mini(combo_count - 1, COMBO_SHAKE_MULTIPLIERS.size() - 1)
	var multiplier = COMBO_SHAKE_MULTIPLIERS[index]
	screen_shake(4.0 * multiplier, 0.15)
	
	# Hit 3 gets extra hitstop
	if combo_count == 3:
		hitstop_heavy()


func _on_combo_completed(total_damage: int) -> void:
	# Big screen shake for full combo
	shake_heavy()
	
	# Brief time slow for impact
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.1 * 0.5).timeout
	Engine.time_scale = 1.0


func _on_player_level_up(new_level: int) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Create level up visual
	_create_level_up_effect(player)
	
	# Screen effects
	screen_shake(8.0, 0.3)
	_flash_screen(Color(1, 0.95, 0.6, 0.4), 0.3)


func _create_level_up_effect(target: Node2D) -> void:
	# Create expanding ring of particles
	_create_ring_effect(target.global_position)
	
	# Create floating "LEVEL UP!" text
	var label = Label.new()
	label.text = "LEVEL UP!"
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	label.add_theme_color_override("font_outline_color", Color(0.3, 0.2, 0))
	label.add_theme_constant_override("outline_size", 2)
	label.global_position = target.global_position + Vector2(-35, -35)
	label.z_index = 100
	get_tree().current_scene.add_child(label)
	
	# Animate text floating up and fading
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - 40, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0).set_delay(0.5)
	tween.chain().tween_callback(label.queue_free)


func _create_ring_effect(pos: Vector2) -> void:
	# Simple expanding circle using particles going outward
	for i in range(8):
		var angle = i * TAU / 8
		var particle = ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = Color(1, 0.9, 0.4, 1)
		particle.global_position = pos
		particle.z_index = 100
		get_tree().current_scene.add_child(particle)
		
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * 30
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, 0.4).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, 0.4)
		tween.chain().tween_callback(particle.queue_free)


func _flash_screen(color: Color, duration: float) -> void:
	var flash = ColorRect.new()
	flash.color = color
	flash.anchors_preset = Control.PRESET_FULL_RECT
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 1000
	
	# Add to CanvasLayer for HUD-level rendering
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	canvas.add_child(flash)
	get_tree().current_scene.add_child(canvas)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, duration)
	tween.tween_callback(canvas.queue_free)


func _on_exp_gained(amount: int, _level: int, _current: int, _to_next: int) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Create floating EXP text
	_create_exp_popup(player.global_position, amount)


func _create_exp_popup(pos: Vector2, amount: int) -> void:
	var label = Label.new()
	label.text = "+" + str(amount) + " EXP"
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(0.7, 0.5, 1.0))  # Purple
	label.add_theme_color_override("font_outline_color", Color(0.2, 0.1, 0.3))
	label.add_theme_constant_override("outline_size", 1)
	label.global_position = pos + Vector2(-15, -20)
	label.z_index = 90
	
	get_tree().current_scene.add_child(label)
	
	# Animate float up and fade
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - 25, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)


# =============================================================================
# PICKUP COLLECTION EFFECTS
# =============================================================================

## Spawn pickup collection particles
func spawn_pickup_effect(pos: Vector2, color: Color) -> void:
	# Spawn 5-8 small particles that burst outward
	var particle_count = randi_range(5, 8)
	for i in particle_count:
		var particle = ColorRect.new()
		particle.size = Vector2(2, 2)
		particle.color = color
		particle.position = pos - Vector2(1, 1)  # Center
		get_tree().current_scene.add_child(particle)
		
		# Animate outward and fade
		var tween = particle.create_tween()
		var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var end_pos = pos + direction * randf_range(12, 20)
		tween.set_parallel(true)
		tween.tween_property(particle, "position", end_pos, 0.25)
		tween.tween_property(particle, "modulate:a", 0.0, 0.25)
		tween.chain().tween_callback(particle.queue_free)


## Quick flash at position (for emphasis)
func flash_pickup(pos: Vector2, color: Color) -> void:
	var flash = ColorRect.new()
	flash.size = Vector2(12, 12)
	flash.position = pos - Vector2(6, 6)
	flash.color = color
	flash.modulate.a = 0.7
	get_tree().current_scene.add_child(flash)
	
	var tween = flash.create_tween()
	tween.set_parallel(true)
	tween.tween_property(flash, "scale", Vector2(1.5, 1.5), 0.12)
	tween.tween_property(flash, "modulate:a", 0.0, 0.12)
	tween.chain().tween_callback(flash.queue_free)

# =============================================================================
# COMBAT JUICE - SPECIAL ABILITIES
# =============================================================================

## Ground pound impact - massive shockwave effect
func _on_ground_pound_impact(damage: int, radius: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var pos = player.global_position
	
	# Heavy screen shake
	screen_shake(10.0, 0.35)
	
	# Heavy hitstop
	hitstop_heavy()
	
	# Camera punch (zoom effect)
	camera_punch(1.15, 0.2)
	
	# Shockwave ring effect
	_create_shockwave(pos, radius)
	
	# Dust burst in all directions
	for i in range(12):
		var angle = i * TAU / 12
		var dust_pos = pos + Vector2(cos(angle), sin(angle)) * 8
		spawn_dust(dust_pos, Vector2(cos(angle), sin(angle)))
	
	# Ground crack particles
	_create_ground_crack_particles(pos)
	
	# Screen flash
	_flash_screen(Color(1, 0.8, 0.3, 0.3), 0.15)


## Create expanding shockwave ring
func _create_shockwave(pos: Vector2, radius: float) -> void:
	# Create multiple expanding rings
	for ring_idx in range(3):
		var ring = _create_ring_sprite(pos)
		var delay = ring_idx * 0.05
		var target_scale = (radius / 10.0) * (1.0 + ring_idx * 0.3)
		
		var tween = create_tween()
		tween.tween_property(ring, "scale", Vector2(target_scale, target_scale), 0.4)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(delay)
		tween.parallel().tween_property(ring, "modulate:a", 0.0, 0.4).set_delay(delay)
		tween.tween_callback(ring.queue_free)


## Create a ring sprite for shockwave
func _create_ring_sprite(pos: Vector2) -> Node2D:
	# Use ColorRect as placeholder ring (circle approximation)
	var container = Node2D.new()
	container.global_position = pos
	container.z_index = 50
	get_tree().current_scene.add_child(container)
	
	# Create ring from multiple small rects
	for i in range(16):
		var angle = i * TAU / 16
		var rect = ColorRect.new()
		rect.size = Vector2(4, 4)
		rect.position = Vector2(cos(angle), sin(angle)) * 10 - Vector2(2, 2)
		rect.color = Color(1, 0.9, 0.5, 0.8)
		container.add_child(rect)
	
	return container


## Create ground crack particle burst
func _create_ground_crack_particles(pos: Vector2) -> void:
	for i in range(8):
		var particle = ColorRect.new()
		particle.size = Vector2(3, 3)
		particle.color = Color(0.6, 0.5, 0.3, 1)
		particle.global_position = pos
		particle.z_index = 5
		get_tree().current_scene.add_child(particle)
		
		var angle = randf() * TAU
		var distance = randf_range(15, 35)
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * distance
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, 0.3)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, 0.4)
		tween.tween_callback(particle.queue_free)


## Charge attack started - show charging glow
var charge_glow_node: Node2D = null

func _on_charge_started() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Create charging glow effect
	charge_glow_node = _create_charge_glow(player)


func _create_charge_glow(target: Node2D) -> Node2D:
	var glow = Node2D.new()
	glow.name = "ChargeGlow"
	glow.z_index = -1
	target.add_child(glow)
	
	# Pulsing glow circle
	var circle = ColorRect.new()
	circle.size = Vector2(24, 24)
	circle.position = Vector2(-12, -12)
	circle.color = Color(1, 0.6, 0.2, 0.4)
	glow.add_child(circle)
	
	# Animate pulsing
	var tween = create_tween().set_loops()
	tween.tween_property(circle, "scale", Vector2(1.3, 1.3), 0.3)
	tween.tween_property(circle, "scale", Vector2(1.0, 1.0), 0.3)
	
	# Color shift as charge builds
	var color_tween = create_tween().set_loops()
	color_tween.tween_property(circle, "color", Color(1, 0.3, 0.1, 0.6), 0.8)
	color_tween.tween_property(circle, "color", Color(1, 0.6, 0.2, 0.4), 0.8)
	
	return glow


## Charge attack released - flash and effects
func _on_charge_released(damage: int, charge_percent: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Remove charge glow
	if charge_glow_node and is_instance_valid(charge_glow_node):
		charge_glow_node.queue_free()
		charge_glow_node = null
	
	# Scale effects based on charge percent
	var intensity = 0.5 + charge_percent * 0.5  # 50% to 100%
	
	# Screen shake scaled to charge
	screen_shake(5.0 * intensity, 0.2)
	
	# Hitstop for powerful charged hits
	if charge_percent > 0.7:
		hitstop_heavy()
	else:
		hitstop_light()
	
	# Camera punch for fully charged
	if charge_percent > 0.9:
		camera_punch(1.1, 0.15)
	
	# Release flash
	var flash_color = Color(1, 0.8, 0.4, 0.4 * intensity)
	_flash_screen(flash_color, 0.1)
	
	# Burst particles
	_create_charge_release_burst(player.global_position, charge_percent)


func _create_charge_release_burst(pos: Vector2, charge_percent: float) -> void:
	var particle_count = int(6 + charge_percent * 8)  # 6-14 particles
	
	for i in range(particle_count):
		var particle = ColorRect.new()
		particle.size = Vector2(3 + charge_percent * 2, 3 + charge_percent * 2)
		particle.color = Color(1, 0.7, 0.3, 1)
		particle.global_position = pos
		particle.z_index = 60
		get_tree().current_scene.add_child(particle)
		
		var angle = randf() * TAU
		var speed = randf_range(40, 80) * (0.5 + charge_percent * 0.5)
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * speed * 0.3
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, 0.25)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, 0.3)
		tween.tween_callback(particle.queue_free)


## Parry success - satisfying feedback
func _on_parry_success(attacker: Node, reflected_damage: int) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var pos = player.global_position
	
	# Medium screen shake
	screen_shake(6.0, 0.2)
	
	# Hitstop for impact
	hitstop_heavy()
	
	# Blue parry flash
	_flash_screen(Color(0.3, 0.6, 1.0, 0.4), 0.15)
	
	# Parry spark effect
	_create_parry_sparks(pos)
	
	# "PARRY!" text popup
	_create_parry_text(pos)
	
	# Camera punch
	camera_punch(1.08, 0.12)


func _create_parry_sparks(pos: Vector2) -> void:
	# Blue/white sparks radiating outward
	for i in range(10):
		var spark = ColorRect.new()
		spark.size = Vector2(4, 2)
		spark.color = Color(0.5, 0.8, 1.0, 1)
		spark.global_position = pos
		spark.z_index = 70
		spark.rotation = randf() * TAU
		get_tree().current_scene.add_child(spark)
		
		var angle = i * TAU / 10 + randf_range(-0.2, 0.2)
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * randf_range(20, 35)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(spark, "global_position", end_pos, 0.2)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_property(spark, "modulate:a", 0.0, 0.25)
		tween.tween_callback(spark.queue_free)


func _create_parry_text(pos: Vector2) -> void:
	var label = Label.new()
	label.text = "PARRY!"
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.2, 0.4))
	label.add_theme_constant_override("outline_size", 2)
	label.global_position = pos + Vector2(-25, -40)
	label.z_index = 100
	get_tree().current_scene.add_child(label)
	
	# Pop and float animation
	label.scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
	tween.parallel().tween_property(label, "global_position:y", pos.y - 55, 0.6)
	tween.tween_property(label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(label.queue_free)


# =============================================================================
# CAMERA PUNCH (ZOOM EFFECT)
# =============================================================================

var camera_punch_active: bool = false

## Quick zoom in/out for impact feel
func camera_punch(zoom_amount: float = 1.1, duration: float = 0.15) -> void:
	if camera_punch_active:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player or not player.has_node("Camera2D"):
		return
	
	var camera: Camera2D = player.get_node("Camera2D")
	var original_zoom = camera.zoom
	var punch_zoom = original_zoom * zoom_amount
	
	camera_punch_active = true
	
	var tween = create_tween()
	tween.tween_property(camera, "zoom", punch_zoom, duration * 0.3)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(camera, "zoom", original_zoom, duration * 0.7)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func(): camera_punch_active = false)
