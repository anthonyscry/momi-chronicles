extends CharacterBody2D
class_name TestEnemy
## Test enemy demonstrating difficulty integration.
## Simple enemy with basic attack and health that scales with difficulty settings.
## Used for verifying the difficulty system works correctly.

## Base damage for attacks (before difficulty modifiers)
@export var base_damage: float = 10.0

## Base health
@export var max_health: float = 50.0

## Base attack cooldown in seconds
@export var base_attack_cooldown: float = 2.0

## Base drop chance (0.0 to 1.0)
@export var base_drop_chance: float = 0.5

## Reference to difficulty modifier component
@onready var difficulty_modifier: EnemyDifficultyModifier = $EnemyDifficultyModifier

## Current health
var current_health: float = 50.0

## Attack timer
var attack_timer: float = 0.0

## Visual indicator (ColorRect for simple visualization)
var visual: ColorRect

## Health label for debugging
var health_label: Label


func _ready() -> void:
	current_health = max_health

	# Create simple visual representation
	_setup_visual()

	# Create health label
	_setup_health_label()

	# Add to enemy group for easy querying
	add_to_group("enemies")

	# Log difficulty modifiers on spawn
	if difficulty_modifier:
		print("TestEnemy spawned with modifiers - Damage: %.2fx, Drops: %.2fx, AI: %.2fx" % [
			difficulty_modifier.get_damage_multiplier(),
			difficulty_modifier.get_drop_multiplier(),
			difficulty_modifier.get_ai_aggression_multiplier()
		])


func _setup_visual() -> void:
	# Simple colored square to represent the enemy
	visual = ColorRect.new()
	visual.name = "Visual"
	visual.size = Vector2(32, 32)
	visual.position = Vector2(-16, -16)  # Center the square
	visual.color = Color(0.8, 0.2, 0.2)  # Red color for enemy
	add_child(visual)


func _setup_health_label() -> void:
	# Show health above enemy
	health_label = Label.new()
	health_label.name = "HealthLabel"
	health_label.position = Vector2(-20, -30)
	health_label.add_theme_font_size_override("font_size", 10)
	health_label.add_theme_color_override("font_color", Color.WHITE)
	health_label.add_theme_color_override("font_outline_color", Color.BLACK)
	health_label.add_theme_constant_override("outline_size", 2)
	add_child(health_label)
	_update_health_label()


func _update_health_label() -> void:
	if health_label:
		health_label.text = "HP: %.0f/%.0f" % [current_health, max_health]


func _process(delta: float) -> void:
	# Update attack timer
	attack_timer -= delta

	# Update health display
	_update_health_label()

	# Simple AI: attack player if nearby
	if attack_timer <= 0:
		_try_attack()


## Try to attack player if in range
func _try_attack() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Check distance
	var distance = global_position.distance_to(player.global_position)
	if distance < 64:  # Attack range
		_perform_attack(player)


## Perform attack with difficulty-scaled damage
func _perform_attack(target: Node) -> void:
	if not difficulty_modifier:
		return

	# Apply difficulty modifier to base damage
	var final_damage = difficulty_modifier.apply_damage(base_damage)

	# Get modified attack cooldown based on AI aggression
	var modified_cooldown = difficulty_modifier.get_ai_cooldown(base_attack_cooldown)
	attack_timer = modified_cooldown

	# Visual feedback
	_attack_flash()

	# Deal damage to target
	var health_comp = target.get_node_or_null("HealthComponent")
	if health_comp and health_comp.has_method("take_damage"):
		health_comp.take_damage(final_damage)
		print("TestEnemy dealt %.1f damage (base: %.1f, multiplier: %.2fx)" % [
			final_damage,
			base_damage,
			difficulty_modifier.get_damage_multiplier()
		])


## Visual feedback when attacking
func _attack_flash() -> void:
	if not visual:
		return

	# Flash yellow briefly
	var original_color = visual.color
	visual.color = Color(1, 1, 0.3)  # Yellow flash

	var tween = create_tween()
	tween.tween_property(visual, "color", original_color, 0.2)


## Take damage from player or other sources
func take_damage(amount: float) -> void:
	current_health -= amount

	# Visual feedback
	_damage_flash()

	# Check if dead
	if current_health <= 0:
		_die()


## Visual feedback when taking damage
func _damage_flash() -> void:
	if not visual:
		return

	# Flash white briefly
	var original_color = visual.color
	visual.color = Color.WHITE

	var tween = create_tween()
	tween.tween_property(visual, "color", original_color, 0.15)


## Handle enemy death
func _die() -> void:
	print("TestEnemy defeated!")

	# Check for loot drop using difficulty modifier
	if difficulty_modifier and difficulty_modifier.should_drop(base_drop_chance):
		_spawn_loot()
		print("  - Loot dropped! (chance: %.1f%%, multiplier: %.2fx)" % [
			base_drop_chance * 100,
			difficulty_modifier.get_drop_multiplier()
		])
	else:
		print("  - No loot (chance: %.1f%%, multiplier: %.2fx)" % [
			base_drop_chance * 100,
			difficulty_modifier.get_drop_multiplier() if difficulty_modifier else 1.0
		])

	# Remove from scene
	queue_free()


## Spawn loot on death
func _spawn_loot() -> void:
	# Simple visual indicator for loot
	var loot = ColorRect.new()
	loot.name = "Loot"
	loot.size = Vector2(16, 16)
	loot.color = Color(1, 0.8, 0.2)  # Gold color
	loot.position = global_position - Vector2(8, 8)
	get_parent().add_child(loot)

	# Animate loot
	var tween = create_tween()
	tween.tween_property(loot, "modulate:a", 0.0, 2.0)
	tween.tween_callback(loot.queue_free)
