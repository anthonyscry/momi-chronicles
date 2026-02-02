extends Node
class_name CompanionAI

## Preload companion data to avoid autoload parse-time dependency
const _CompanionData = preload("res://systems/party/companion_data.gd")

## AI behavior presets
var preset: int = _CompanionData.AIPreset.BALANCED

## Distance settings per preset
const PRESET_DISTANCES: Dictionary = {
	_CompanionData.AIPreset.AGGRESSIVE: {"follow": 60, "attack": 120},
	_CompanionData.AIPreset.BALANCED: {"follow": 80, "attack": 100},
	_CompanionData.AIPreset.DEFENSIVE: {"follow": 40, "attack": 80},
}

## Reference to owner
var owner_node: CharacterBody2D = null

## Target tracking
var current_target: Node2D = null
var target_update_timer: float = 0.0
const TARGET_UPDATE_INTERVAL: float = 0.5

## Attack cooldown
var attack_cooldown: float = 0.0
var attack_rate: float = 1.5  # Seconds between attacks

## Reference to active (player-controlled) companion for following
var follow_target: Node2D = null

func setup(owner: CharacterBody2D, ai_preset: int) -> void:
	owner_node = owner
	preset = ai_preset

func _process(delta: float) -> void:
	if not owner_node:
		return
	
	# Don't run AI if player controlled
	if owner_node.is_player_controlled:
		return
	
	attack_cooldown = max(0, attack_cooldown - delta)
	target_update_timer += delta
	
	if target_update_timer >= TARGET_UPDATE_INTERVAL:
		target_update_timer = 0.0
		_update_target()

func get_ai_move_direction() -> Vector2:
	if not owner_node:
		return Vector2.ZERO
	
	var distances = PRESET_DISTANCES[preset]
	
	# Priority 1: Attack nearby enemy
	if current_target and is_instance_valid(current_target):
		var dist = owner_node.global_position.distance_to(current_target.global_position)
		if dist <= distances.attack:
			# Move toward enemy
			return (current_target.global_position - owner_node.global_position).normalized()
	
	# Priority 2: Follow active companion
	if follow_target and is_instance_valid(follow_target):
		var dist = owner_node.global_position.distance_to(follow_target.global_position)
		if dist > distances.follow:
			return (follow_target.global_position - owner_node.global_position).normalized()
	
	return Vector2.ZERO

func should_attack() -> bool:
	if attack_cooldown > 0:
		return false
	
	if current_target and is_instance_valid(current_target):
		var dist = owner_node.global_position.distance_to(current_target.global_position)
		var attack_range = 30.0  # Close range for melee
		
		if dist <= attack_range:
			attack_cooldown = attack_rate / owner_node.attack_speed_multiplier
			return true
	
	return false

func should_block() -> bool:
	# Tank preset blocks more
	if preset != _CompanionData.AIPreset.DEFENSIVE:
		return false
	
	# Check if enemy is attacking nearby
	if current_target and is_instance_valid(current_target):
		var dist = owner_node.global_position.distance_to(current_target.global_position)
		if dist < 50.0 and current_target.has_method("is_attacking") and current_target.is_attacking():
			return true
	
	return false

func _update_target() -> void:
	if not owner_node:
		return
	
	# Find closest enemy
	var enemies = EntityRegistry.get_enemies()
	var closest: Node2D = null
	var closest_dist: float = INF
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_dead") and enemy.is_dead():
			continue
		
		var dist = owner_node.global_position.distance_to(enemy.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = enemy
	
	current_target = closest

func set_follow_target(target: Node2D) -> void:
	follow_target = target
