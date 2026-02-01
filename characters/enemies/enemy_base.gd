extends CharacterBody2D
class_name EnemyBase

@export var patrol_speed: float = 30.0
@export var chase_speed: float = 60.0
@export var detection_range: float = 80.0
@export var attack_range: float = 20.0
@export var lose_interest_range: float = 120.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0

## Knockback configuration
## How far this enemy gets knocked back when hit.
## TUNING GUIDE (recommended values by enemy type):
##   Light enemies (rats, crows): 120-150 — flies back satisfyingly
##   Medium enemies (raccoons, cats): 80-100 — good knockback feel
##   Heavy enemies (mini-bosses, large): 30-50 — barely budges, feels heavy
##   Boss enemies: 10-20 or override _on_hurt() to reduce velocity
@export var knockback_force: float = 80.0

## Knockback resistance multiplier (0.0 = full knockback, 1.0 = immune)
## Alternative to low knockback_force. Useful for dynamic resistance changes.
## Example: 0.7 = take 30% of knockback, 0.0 = take 100% of knockback
@export_range(0.0, 1.0) var knockback_resistance: float = 0.0

@export var exp_value: int = 10  # Base EXP for generic enemy

@onready var sprite: Polygon2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var health: HealthComponent = $HealthComponent
@onready var detection_area: Area2D = $DetectionArea

## Enemy health bar (loaded dynamically)
var health_bar = null  # EnemyHealthBar - removed type to avoid cyclic dependency
const HEALTH_BAR_SCENE = preload("res://components/health/enemy_health_bar.tscn")

## Pickup scenes for drop table
const HEALTH_PICKUP_SCENE = preload("res://components/health/health_pickup.tscn")
const COIN_PICKUP_SCENE = preload("res://components/pickup/coin_pickup.tscn")

## Drop table: Array of {scene, chance, min, max}
## Override in subclass using _init_default_drops() or configure in editor
var drop_table: Array[Dictionary] = []

var target = null  # Player - removed type to avoid cyclic dependency
var facing_direction: Vector2 = Vector2.DOWN
var facing_left: bool = false
var patrol_points: Array[Vector2] = []
var current_patrol_index: int = 0
var can_attack: bool = true
var attack_timer: float = 0.0

## Stun state
var is_stunned: bool = false
var stun_timer: float = 0.0

## Debug: Hitbox visualizer (created at runtime)
var hitbox_visualizer: HitboxVisualizer = null

func _ready() -> void:
	add_to_group("enemies")
	state_machine.init(self)
	_connect_signals()
	_setup_health_bar()
	if hitbox:
		hitbox.damage = attack_damage

	# Initialize drop table if not set by subclass or editor
	if drop_table.is_empty():
		_init_default_drops()

	# Setup debug hitbox visualizer
	_setup_hitbox_visualizer()


func _setup_health_bar() -> void:
	# Create and add health bar
	health_bar = HEALTH_BAR_SCENE.instantiate()
	add_child(health_bar)
	# Position above the enemy sprite
	health_bar.position = Vector2(-12, -18)


## Setup hitbox visualizer for debug mode
func _setup_hitbox_visualizer() -> void:
	# Create visualizer instance
	hitbox_visualizer = HitboxVisualizer.new()
	hitbox_visualizer.name = "HitboxVisualizer"
	add_child(hitbox_visualizer)

	# Auto-track all hitboxes and hurtboxes
	hitbox_visualizer.auto_track_parent()


## Override to use a different attack state (e.g. CatPounce instead of Attack)
func get_attack_state_name() -> String:
	return "Attack"


func is_alive() -> bool:
	if health:
		return not health.is_dead()
	return true

func _unhandled_input(event: InputEvent) -> void:
	# F3 toggles hitbox visualizer (same key as debug panel)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			if hitbox_visualizer:
				hitbox_visualizer.toggle()


func _process(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true

	# Stun timer
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0:
			_end_stun()

## Apply stun effect
func apply_stun(duration: float) -> void:
	is_stunned = true
	stun_timer = duration
	
	# Visual feedback - blue tint for stunned
	if sprite:
		sprite.modulate = Color(0.7, 0.7, 1.0)
	
	# Stop movement
	velocity = Vector2.ZERO

func _end_stun() -> void:
	is_stunned = false
	
	# Reset visual
	if sprite:
		sprite.modulate = Color.WHITE

## Check if enemy can act (for AI states)
func can_act() -> bool:
	return not is_stunned and is_alive()

func _connect_signals() -> void:
	if hurtbox:
		hurtbox.hurt.connect(_on_hurt)
	if health:
		health.died.connect(_on_died)
	if detection_area:
		detection_area.body_entered.connect(_on_detection_body_entered)
		detection_area.body_exited.connect(_on_detection_body_exited)

func _on_hurt(attacking_hitbox: Hitbox) -> void:
	var damage_amount = attacking_hitbox.damage if attacking_hitbox else 10

	if health:
		health.take_damage(damage_amount)
		# Update health bar
		if health_bar:
			health_bar.update_health(health.get_current_health(), health.get_max_health())

	# Emit damage event for effects (damage numbers, shake, etc.)
	Events.enemy_damaged.emit(self, damage_amount)

	var knockback_dir = (global_position - attacking_hitbox.global_position).normalized()

	# Calculate knockback: use enemy's knockback_force as base, factor in attacker's force and resistance
	# This allows both per-enemy tuning AND per-attack variation
	var attacker_force_multiplier = 1.0
	if attacking_hitbox and attacking_hitbox.knockback_force > 0:
		# Scale by attacker's knockback force (100 = normal, 200 = double, 50 = half)
		attacker_force_multiplier = attacking_hitbox.knockback_force / 100.0

	# Apply resistance (0.0 = full knockback, 1.0 = immune)
	var resistance_multiplier = 1.0 - knockback_resistance

	# Improved knockback: burst initial velocity then fast deceleration
	# Multiplier gives a snappy "pop" that decays quickly
	velocity = knockback_dir * knockback_force * attacker_force_multiplier * resistance_multiplier * 1.6

	# Visual: slight sprite pop in knockback direction for weight feel
	# Scale pop by resistance for heavier enemies
	var pop_distance = 3.0 * resistance_multiplier
	if sprite and pop_distance > 0.5:
		var pop_tween = create_tween()
		pop_tween.tween_property(sprite, "position", knockback_dir * pop_distance, 0.05)\
			.set_ease(Tween.EASE_OUT)
		pop_tween.tween_property(sprite, "position", Vector2.ZERO, 0.12)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)

	if health and not health.is_dead():
		state_machine.transition_to("Hurt")

func _on_died() -> void:
	state_machine.transition_to("Death")
	Events.enemy_defeated.emit(self)
	
	# Spawn drops from drop table
	_spawn_drops()


## Override in subclass to set default drops
func _init_default_drops() -> void:
	# Base enemy: 30% health, 50% coin (1)
	drop_table = [
		{"scene": HEALTH_PICKUP_SCENE, "chance": 0.3, "min": 1, "max": 1},
		{"scene": COIN_PICKUP_SCENE, "chance": 0.5, "min": 1, "max": 1},
	]


## Spawn drops on death based on drop table
func _spawn_drops() -> void:
	for drop in drop_table:
		var chance = drop.get("chance", 0.0)
		if randf() > chance:
			continue
		
		# Item drops go directly to inventory (no pickup scene needed)
		var item_id = drop.get("item_id", "")
		if item_id != "":
			var qty = randi_range(drop.get("min", 1), drop.get("max", 1))
			if GameManager.inventory:
				GameManager.inventory.add_item(item_id, qty)
				# Floating text notification
				_show_item_drop_text(item_id, qty)
			continue
		
		# Scene-based drops (health_pickup, coin_pickup)
		var scene = drop.get("scene")
		if scene:
			var min_count = drop.get("min", 1)
			var max_count = drop.get("max", 1)
			var count = randi_range(min_count, max_count)
			for i in count:
				_spawn_single_drop(scene, i)


## Spawn a single drop with slight offset to prevent stacking
func _spawn_single_drop(scene: PackedScene, index: int) -> void:
	var pickup = scene.instantiate()
	# Offset drops slightly so they don't stack
	var offset = Vector2(randf_range(-8, 8), randf_range(-8, 8))
	pickup.global_position = global_position + offset
	# Add to parent (the zone) so it persists after enemy is freed
	get_parent().add_child(pickup)

## Show floating text when an item drops directly to inventory
func _show_item_drop_text(item_id: String, qty: int) -> void:
	var item_data = ItemDatabase.get_item(item_id)
	if item_data.is_empty():
		return
	var label = Label.new()
	var item_name = item_data.get("name", item_id)
	label.text = "+%d %s" % [qty, item_name] if qty > 1 else "+%s" % item_name
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", item_data.get("color", Color.WHITE))
	label.global_position = global_position + Vector2(-20, -25)
	label.z_index = 100
	get_parent().add_child(label)
	# Float up and fade
	var tween = label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 20, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)


func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body

func _on_detection_body_exited(body: Node2D) -> void:
	if body == target:
		target = null

func get_direction_to_target() -> Vector2:
	if not target:
		return Vector2.ZERO
	return (target.global_position - global_position).normalized()

## Get separation force from nearby enemies to prevent stacking
func get_separation_force() -> Vector2:
	var separation = Vector2.ZERO
	var neighbors = get_tree().get_nodes_in_group("enemies")
	for enemy in neighbors:
		if enemy == self or not is_instance_valid(enemy):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < 20.0 and dist > 0.01:  # Within separation range
			var away = (global_position - enemy.global_position).normalized()
			separation += away * (20.0 - dist) / 20.0  # Stronger when closer
	return separation

func get_distance_to_target() -> float:
	if not target:
		return INF
	return global_position.distance_to(target.global_position)

func is_target_in_attack_range() -> bool:
	return get_distance_to_target() <= attack_range

func is_target_in_detection_range() -> bool:
	return get_distance_to_target() <= detection_range

func should_lose_interest() -> bool:
	return get_distance_to_target() > lose_interest_range

func start_attack_cooldown() -> void:
	can_attack = false
	attack_timer = attack_cooldown

func get_next_patrol_point() -> Vector2:
	if patrol_points.is_empty():
		return global_position
	current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
	return patrol_points[current_patrol_index]

func get_current_patrol_point() -> Vector2:
	if patrol_points.is_empty():
		return global_position
	return patrol_points[current_patrol_index]

func update_facing(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	facing_direction = direction
	if abs(direction.x) > abs(direction.y):
		facing_left = direction.x < 0
		sprite.scale.x = -1 if facing_left else 1

func flash_damage() -> void:
	var original_color = sprite.color
	sprite.color = Color(1, 0.3, 0.3, 1)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self) and sprite:
		sprite.color = original_color
