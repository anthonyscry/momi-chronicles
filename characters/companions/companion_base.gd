extends CharacterBody2D
class_name CompanionBase

signal knocked_out
signal revived
signal meter_changed(current: float, max_val: float)
signal health_changed(current: int, max_hp: int)

## Companion ID (momi, cinnamon, philo)
@export var companion_id: String = ""

## Whether player is controlling this companion
var is_player_controlled: bool = false

## Stats
var max_health: int = 100
var current_health: int = 100
var attack_damage: int = 20
var move_speed: float = 80.0
var attack_speed_multiplier: float = 1.0

## Meter system
var meter_value: float = 0.0
var meter_max: float = 100.0
var meter_name: String = "Meter"
var meter_build_rate: float = 5.0
var meter_drain_rate: float = 10.0
var meter_active: bool = false  # For Momi's Zoomies activation

## Knocked out state
var is_knocked_out: bool = false

## Attack state
var is_attacking: bool = false
var attack_timer: float = 0.0
const ATTACK_DURATION: float = 0.15

## Components
@onready var sprite: Polygon2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox_area: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hurtbox_area: Area2D = $Hurtbox
@onready var ai: CompanionAI = $CompanionAI

func _ready() -> void:
	add_to_group("companions")
	add_to_group("player_allies")
	
	# Load companion data
	_load_companion_data()
	
	# Connect signals
	if hurtbox_area:
		hurtbox_area.area_entered.connect(_on_hurtbox_area_entered)
	
	# Register with party manager
	if GameManager.party_manager:
		GameManager.party_manager.register_companion(companion_id, self)
	
	# Setup AI
	if ai:
		var preset = CompanionData.AIPreset.BALANCED
		if GameManager.party_manager:
			preset = GameManager.party_manager.ai_presets.get(companion_id, preset)
		ai.setup(self, preset)
	
	# Disable hitbox by default
	if hitbox_shape:
		hitbox_shape.disabled = true

func _load_companion_data() -> void:
	var data = CompanionData.get_companion(companion_id)
	if data.is_empty():
		return
	
	# Base stats
	var stats = data.base_stats
	max_health = stats.max_health
	current_health = max_health
	attack_damage = stats.attack_damage
	move_speed = stats.move_speed
	attack_speed_multiplier = stats.attack_speed
	
	# Meter
	var meter = data.meter
	meter_name = meter.name
	meter_max = meter.max_value
	meter_value = meter.start_value  # Important: Philo starts at 100!
	meter_build_rate = meter.build_rate
	meter_drain_rate = meter.drain_rate
	
	# Visuals
	if sprite:
		sprite.color = data.color

func _physics_process(delta: float) -> void:
	if is_knocked_out:
		return
	
	# Update attack timer
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			if hitbox_shape:
				hitbox_shape.disabled = true
	
	# Process meter
	_update_meter(delta)
	
	# Movement
	var direction: Vector2
	if is_player_controlled:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	else:
		direction = ai.get_ai_move_direction() if ai else Vector2.ZERO
	
	var speed = move_speed * _get_speed_multiplier()
	velocity = direction * speed
	move_and_slide()
	
	# Attack logic
	if _should_attack():
		_perform_attack()

func _should_attack() -> bool:
	if is_attacking:
		return false
	if is_player_controlled:
		return Input.is_action_just_pressed("attack")
	else:
		return ai.should_attack() if ai else false

func _perform_attack() -> void:
	is_attacking = true
	attack_timer = ATTACK_DURATION
	
	# Enable hitbox
	if hitbox_shape:
		hitbox_shape.disabled = false
	
	# Flash visual
	if sprite:
		sprite.modulate = Color(1.2, 1.2, 0.8)
		await get_tree().create_timer(0.1).timeout
		if sprite:
			sprite.modulate = Color.WHITE
	
	# Build meter on attack (Momi's Zoomies)
	_on_attack_performed()

## Override in subclasses for unique meter behavior
func _update_meter(_delta: float) -> void:
	pass  # Implemented in subclasses

func _on_attack_performed() -> void:
	pass  # Override for meter building

func _get_speed_multiplier() -> float:
	return 1.0  # Override for Zoomies

func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Check if it's a hitbox
	var parent = area.get_parent()
	if parent and parent.has_method("get") and parent.get("damage"):
		take_damage(parent.damage)
	elif area.get("damage"):
		take_damage(area.damage)

func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = max(0, current_health)
	
	health_changed.emit(current_health, max_health)
	
	# Flash effect
	_flash_hurt()
	
	if current_health <= 0:
		_knock_out()

func _flash_hurt() -> void:
	if sprite:
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		if sprite:
			sprite.modulate = Color.WHITE

func _knock_out() -> void:
	is_knocked_out = true
	visible = false  # Hide knocked out companion
	knocked_out.emit()

func revive(health_percent: float = 0.5) -> void:
	is_knocked_out = false
	current_health = int(max_health * health_percent)
	visible = true
	health_changed.emit(current_health, max_health)
	revived.emit()

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func set_player_controlled(controlled: bool) -> void:
	is_player_controlled = controlled
	
	# Update AI follow target
	if ai and not controlled:
		var active = GameManager.party_manager.get_active_companion() if GameManager.party_manager else null
		ai.set_follow_target(active)

func set_ai_preset(preset: int) -> void:
	if ai:
		ai.preset = preset

## Getters for HUD
func get_current_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

func get_meter_value() -> float:
	return meter_value

func get_meter_max() -> float:
	return meter_max

## Called when ally takes damage (for Philo)
func on_ally_damaged(_amount: int) -> void:
	pass  # Override in Philo

## Is this companion dead?
func is_dead() -> bool:
	return is_knocked_out
