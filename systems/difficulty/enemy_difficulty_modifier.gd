extends Node
class_name EnemyDifficultyModifier
## Component that applies difficulty-based modifiers to enemies.
## Attach to enemy nodes to automatically scale damage, drops, and AI behavior.
## Listens to Events.difficulty_changed to update modifiers on-the-fly.

## Reference to parent enemy (auto-assigned in _ready)
var parent_enemy: Node = null

## Cached multipliers for performance
var damage_multiplier: float = 1.0
var drop_multiplier: float = 1.0
var ai_aggression_multiplier: float = 1.0


func _ready() -> void:
	# Get parent enemy reference
	parent_enemy = get_parent()
	if not parent_enemy:
		push_error("EnemyDifficultyModifier: No parent node found!")
		return

	# Wait for DifficultyManager to be ready (it's an autoload)
	if not DifficultyManager:
		push_error("EnemyDifficultyModifier: DifficultyManager autoload not found!")
		return

	# Connect to difficulty change events
	Events.difficulty_changed.connect(_on_difficulty_changed)

	# Apply initial difficulty modifiers
	_update_modifiers()


## Update multipliers from DifficultyManager
func _update_modifiers() -> void:
	if not DifficultyManager:
		return

	damage_multiplier = DifficultyManager.get_damage_multiplier()
	drop_multiplier = DifficultyManager.get_drop_multiplier()
	ai_aggression_multiplier = DifficultyManager.get_ai_aggression_multiplier()

	# Apply modifiers to parent enemy
	_apply_to_parent()


## Apply modifiers to parent enemy components
func _apply_to_parent() -> void:
	if not parent_enemy:
		return

	# Apply damage multiplier to attack components
	var attack_comp = parent_enemy.get_node_or_null("AttackComponent")
	if attack_comp and attack_comp.has_method("set_damage_multiplier"):
		attack_comp.set_damage_multiplier(damage_multiplier)

	# Apply drop multiplier to loot components
	var loot_comp = parent_enemy.get_node_or_null("LootComponent")
	if loot_comp and loot_comp.has_method("set_drop_multiplier"):
		loot_comp.set_drop_multiplier(drop_multiplier)

	# Apply AI aggression to behavior/state machine
	var ai_comp = parent_enemy.get_node_or_null("AIComponent")
	if ai_comp and ai_comp.has_method("set_aggression_multiplier"):
		ai_comp.set_aggression_multiplier(ai_aggression_multiplier)

	# Also check for state machine (common pattern)
	var state_machine = parent_enemy.get_node_or_null("StateMachine")
	if state_machine and state_machine.has_method("set_speed_multiplier"):
		state_machine.set_speed_multiplier(ai_aggression_multiplier)


## Handle difficulty changes at runtime
func _on_difficulty_changed(_new_difficulty: int) -> void:
	_update_modifiers()


## Get current damage multiplier (utility for parent enemy)
func get_damage_multiplier() -> float:
	return damage_multiplier


## Get current drop multiplier (utility for parent enemy)
func get_drop_multiplier() -> float:
	return drop_multiplier


## Get current AI aggression multiplier (utility for parent enemy)
func get_ai_aggression_multiplier() -> float:
	return ai_aggression_multiplier


## Apply damage scaling to a base damage value
## Use this in enemy attack scripts: var final_damage = modifier.apply_damage(base_damage)
func apply_damage(base_damage: float) -> float:
	return base_damage * damage_multiplier


## Check if a drop should occur based on difficulty
## Use this in loot logic: if modifier.should_drop(base_chance): spawn_loot()
func should_drop(base_chance: float) -> bool:
	var modified_chance = base_chance * drop_multiplier
	return randf() < modified_chance


## Get modified AI cooldown/timer duration
## Use this for attack cooldowns: var cooldown = modifier.get_ai_cooldown(base_cooldown)
func get_ai_cooldown(base_cooldown: float) -> float:
	# Higher aggression = shorter cooldowns (inverse relationship)
	return base_cooldown / ai_aggression_multiplier if ai_aggression_multiplier > 0 else base_cooldown
