extends "res://characters/enemies/enemy_base.gd"
class_name MiniBossBase
## Base class for all mini-boss enemies.
## Extends EnemyBase with attack pattern cycling, one-time defeat tracking,
## unique loot drops, and mini-boss health bar integration.

# =============================================================================
# MINI-BOSS CONFIGURATION
# =============================================================================

## Display name shown on health bar
@export var boss_name: String = "Mini-Boss"

## Save key for one-time defeat tracking (e.g., "alpha_raccoon")
@export var is_defeated_key: String = ""

## Equipment ID to grant on defeat (from EquipmentDatabase)
@export var loot_equipment_id: String = ""

# =============================================================================
# ATTACK PATTERN SYSTEM
# =============================================================================

## Array of state names to cycle through (e.g., ["AlphaSlam", "AlphaSummon"])
var attack_patterns: Array[String] = []
var current_attack_index: int = 0

# =============================================================================
# MINI-BOSS STATE
# =============================================================================

var is_mini_boss: bool = true
var defeat_tracked: bool = false

## Track spawned reinforcements for cleanup on death
var spawned_minions: Array[Node] = []

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	super._ready()
	add_to_group("mini_bosses")
	
	# Remove the small enemy health bar — mini-boss uses the HUD bar
	if health_bar:
		health_bar.queue_free()
		health_bar = null
	
	# Emit spawn event for HUD health bar
	Events.mini_boss_spawned.emit(self, boss_name)

# =============================================================================
# ATTACK PATTERN CYCLING
# =============================================================================

## Get the next attack state name (cycles through attack_patterns array)
func get_next_attack_state() -> String:
	if attack_patterns.is_empty():
		return "MiniBossIdle"
	var state_name = attack_patterns[current_attack_index]
	current_attack_index = (current_attack_index + 1) % attack_patterns.size()
	return state_name

## Alias for BossIdle pattern compatibility — BossIdle calls get_attack_state_name()
func get_attack_state_name() -> String:
	return get_next_attack_state()

# =============================================================================
# DEATH OVERRIDE
# =============================================================================

func _on_died() -> void:
	# Emit mini-boss defeat signal (NOT boss_defeated — separate signal)
	Events.mini_boss_defeated.emit(self, is_defeated_key)
	
	# Grant equipment loot
	_grant_loot()
	
	# Spawn regular drops (coins, health)
	_spawn_drops()
	
	# Clean up spawned reinforcements
	_cleanup_minions()
	
	# Play mini-boss death sequence (lighter than full boss)
	_play_mini_boss_death()

## Grant rare equipment on defeat
func _grant_loot() -> void:
	if loot_equipment_id.is_empty():
		return
	if GameManager.equipment_manager:
		GameManager.equipment_manager.add_equipment(loot_equipment_id)
	# Show floating notification
	_show_loot_notification()

## Show floating text notification for loot
func _show_loot_notification() -> void:
	var equip_data = EquipmentDatabase.get_equipment(loot_equipment_id)
	if equip_data.is_empty():
		return
	var label = Label.new()
	label.text = "Got %s!" % equip_data.get("name", "???")
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(1, 0.85, 0.2))  # Gold
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-40, -30)
	add_child(label)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 25, 1.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(0.5)
	tween.chain().tween_callback(label.queue_free)

## Clean up any spawned reinforcement enemies on mini-boss death
func _cleanup_minions() -> void:
	for minion in spawned_minions:
		if is_instance_valid(minion):
			minion.queue_free()
	spawned_minions.clear()

## Mini-boss death sequence (lighter than full boss)
func _play_mini_boss_death() -> void:
	# Disable collision
	set_collision_layer_value(3, false)
	velocity = Vector2.ZERO
	
	# Flash sequence (3 flashes — shorter than boss's 5)
	for i in range(3):
		if sprite:
			sprite.modulate = Color(2, 2, 2) if i % 2 == 0 else Color(1, 0.5, 0.5)
		EffectsManager.screen_shake(6.0, 0.2)
		await get_tree().create_timer(0.25).timeout
	
	# Burst particles
	_spawn_death_particles()
	
	# Remove
	queue_free()

## Death particles (12 — fewer than boss's 20)
func _spawn_death_particles() -> void:
	for i in range(12):
		var particle = ColorRect.new()
		particle.size = Vector2(5, 5)
		particle.color = Color(0.5, 0.4, 0.6)
		particle.global_position = global_position
		get_parent().add_child(particle)
		
		var angle = randf() * TAU
		var speed = randf_range(40, 120)
		var end_pos = global_position + Vector2(cos(angle), sin(angle)) * speed
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, 0.5)
		tween.tween_property(particle, "modulate:a", 0.0, 0.5)
		tween.chain().tween_callback(particle.queue_free)
