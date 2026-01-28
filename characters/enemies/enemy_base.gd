extends CharacterBody2D
class_name EnemyBase

@export var patrol_speed: float = 30.0
@export var chase_speed: float = 60.0
@export var detection_range: float = 80.0
@export var attack_range: float = 20.0
@export var lose_interest_range: float = 120.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0
@export var knockback_force: float = 80.0
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


func _setup_health_bar() -> void:
	# Create and add health bar
	health_bar = HEALTH_BAR_SCENE.instantiate()
	add_child(health_bar)
	# Position above the enemy sprite
	health_bar.position = Vector2(-12, -18)


func is_alive() -> bool:
	if health:
		return not health.is_dead()
	return true

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
	velocity = knockback_dir * knockback_force
	
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
		var scene = drop.get("scene")
		var chance = drop.get("chance", 0.0)
		if scene and randf() <= chance:
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
