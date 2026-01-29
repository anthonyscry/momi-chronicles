class_name BaseZone
extends Node2D
## Base class for all game zones.
## Handles common zone functionality like camera limits, spawn points, and transitions.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Size of the zone in pixels
@export var zone_size: Vector2 = Vector2(384, 216)

## Unique identifier for this zone
@export var zone_id: String = "unnamed_zone"

## Player spawn position (local to zone)
@export var player_spawn: Vector2 = Vector2(50, 100)

## Enable enemy respawning
@export var respawn_enabled: bool = true

## Time before enemies respawn (seconds)
@export var respawn_delay: float = 150.0  # 2.5 minutes

## Minimum distance from player for respawn (off-camera)
@export var respawn_min_distance: float = 200.0

# =============================================================================
# PRELOADS (avoid global class_name resolution issues)
# =============================================================================

const _InteractiveGrass = preload("res://components/effects/interactive_grass.gd")

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var player: Player = $Player
@onready var ground_tilemap: TileMap = $GroundTileMap if has_node("GroundTileMap") else null
@onready var wall_tilemap: TileMap = $WallTileMap if has_node("WallTileMap") else null
@onready var enemies_container: Node2D = $Enemies if has_node("Enemies") else null

# =============================================================================
# RESPAWN TRACKING
# =============================================================================

## Stores spawn data for each enemy type
## Key: enemy scene path, Value: Array of {position, death_time}
var enemy_spawn_data: Dictionary = {}

## Original enemy configs (scene path, position) captured at start
var original_enemy_configs: Array = []

## Timer for checking respawns
var respawn_check_timer: float = 0.0
const RESPAWN_CHECK_INTERVAL: float = 5.0  # Check every 5 seconds

# =============================================================================
# COMPANION SPAWNING
# =============================================================================

## Companion scenes (preloaded for zone entry)
const COMPANION_SCENES: Dictionary = {
	"momi": preload("res://characters/companions/momi_companion.tscn"),
	"cinnamon": preload("res://characters/companions/cinnamon_companion.tscn"),
	"philo": preload("res://characters/companions/philo_companion.tscn"),
}

## Spawn offsets from player position for each companion
const COMPANION_OFFSETS: Dictionary = {
	"momi": Vector2(-20, 10),
	"cinnamon": Vector2(20, 10),
	"philo": Vector2(0, 20),
}

## Spawned companion nodes (tracked for cleanup)
var spawned_companions: Array[Node] = []

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_setup_camera()
	_setup_zone()
	_capture_enemy_spawn_data()
	_connect_enemy_death_signals()
	_spawn_companions()
	_spawn_grass()
	Events.zone_entered.emit(zone_id)


func _process(delta: float) -> void:
	if respawn_enabled:
		_update_respawn_system(delta)


func _setup_camera() -> void:
	if player:
		player.set_camera_limits(Rect2(Vector2.ZERO, zone_size))


func _setup_zone() -> void:
	# Override in child classes for custom setup
	pass


## Spawn companion party members near the player
func _spawn_companions() -> void:
	if not player:
		return
	
	# Don't double-spawn if companions already exist in scene
	if get_tree().get_nodes_in_group("companions").size() > 0:
		return
	
	# Spawn each companion from the party
	for companion_id in COMPANION_SCENES.keys():
		var scene = COMPANION_SCENES[companion_id]
		var companion = scene.instantiate()
		
		# Position near player with offset
		var offset = COMPANION_OFFSETS.get(companion_id, Vector2(0, 15))
		companion.global_position = player.global_position + offset
		
		# Add to scene tree — companion's _ready() auto-registers with party_manager
		add_child(companion)
		spawned_companions.append(companion)
	
	# After all companions registered, set AI follow targets to player node
	# (non-active companions follow the player via AI)
	await get_tree().process_frame
	for companion in spawned_companions:
		if is_instance_valid(companion) and companion.ai and not companion.is_player_controlled:
			companion.ai.set_follow_target(player)
	
	print("[Zone] Spawned %d companions" % spawned_companions.size())


## Spawn interactive grass tufts throughout the zone
func _spawn_grass() -> void:
	# Scatter grass clusters across walkable areas
	var grass_count = randi_range(8, 14)
	var margin = 30  # Keep away from zone edges
	
	for i in range(grass_count):
		var grass = _InteractiveGrass.new()
		
		# Random position within zone bounds (avoiding edges)
		var x = randf_range(margin, zone_size.x - margin)
		var y = randf_range(margin, zone_size.y - margin)
		grass.global_position = Vector2(x, y)
		
		# Slight color variance per zone
		match zone_id:
			"backyard":
				grass.blade_color = Color(0.25, 0.65, 0.2, 0.8)  # Darker green
			"boss_arena":
				grass.blade_color = Color(0.4, 0.55, 0.2, 0.6)  # Dry/yellow
				grass.blade_count = 2
			_:
				grass.blade_color = Color(0.3, 0.7, 0.25, 0.8)  # Default green
		
		add_child(grass)
	
	print("[Zone] Spawned %d grass tufts" % grass_count)

# =============================================================================
# ZONE MANAGEMENT
# =============================================================================

## Spawn player at a specific position
func spawn_player_at(pos: Vector2) -> void:
	if player:
		player.global_position = pos


## Get all enemies in the zone
func get_enemies() -> Array[Node]:
	if enemies_container:
		return enemies_container.get_children()
	return []


## Check if all enemies are defeated
func all_enemies_defeated() -> bool:
	var enemies = get_enemies()
	for enemy in enemies:
		if enemy.has_method("is_alive") and enemy.is_alive():
			return false
	return true

# =============================================================================
# ZONE TRANSITIONS
# =============================================================================

## Called when player enters a zone exit
func _on_zone_exit_entered(exit_id: String, target_zone: String, target_spawn: String) -> void:
	Events.zone_transition_requested.emit(target_zone, target_spawn)

# =============================================================================
# ENEMY RESPAWN SYSTEM
# =============================================================================

## Capture initial enemy positions for respawning
func _capture_enemy_spawn_data() -> void:
	original_enemy_configs.clear()
	
	if not enemies_container:
		return
	
	for enemy in enemies_container.get_children():
		if enemy is CharacterBody2D:
			var config = {
				"scene_path": enemy.scene_file_path,
				"scene_resource": load(enemy.scene_file_path),  # Cache at zone init (not hot path)
				"position": enemy.global_position,
				"name": enemy.name
			}
			original_enemy_configs.append(config)


## Connect to enemy death signals
func _connect_enemy_death_signals() -> void:
	if not enemies_container:
		return
	
	for enemy in enemies_container.get_children():
		if enemy.has_node("HealthComponent"):
			var health = enemy.get_node("HealthComponent")
			if not health.died.is_connected(_on_enemy_died):
				health.died.connect(_on_enemy_died.bind(enemy))


## Called when an enemy dies - record for respawn
func _on_enemy_died(enemy: Node) -> void:
	if not respawn_enabled:
		return
	
	# Find the original config for this enemy
	for config in original_enemy_configs:
		if config.name == enemy.name:
			# Record death for this spawn point
			var spawn_entry = {
				"scene_path": config.scene_path,
				"scene_resource": config.get("scene_resource"),
				"position": config.position,
				"death_time": Time.get_ticks_msec() / 1000.0,
				"name": config.name
			}
			
			if not enemy_spawn_data.has(config.scene_path):
				enemy_spawn_data[config.scene_path] = []
			enemy_spawn_data[config.scene_path].append(spawn_entry)
			break


## Update respawn system - check for enemies to respawn
func _update_respawn_system(delta: float) -> void:
	respawn_check_timer += delta
	if respawn_check_timer < RESPAWN_CHECK_INTERVAL:
		return
	
	respawn_check_timer = 0.0
	_check_respawns()


## Check if any enemies should respawn
func _check_respawns() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	var player_pos = player.global_position if player else Vector2.ZERO
	
	for scene_path in enemy_spawn_data.keys():
		var spawn_list: Array = enemy_spawn_data[scene_path]
		var to_remove: Array = []
		
		for i in range(spawn_list.size()):
			var spawn_entry = spawn_list[i]
			var time_since_death = current_time - spawn_entry.death_time
			
			# Check if enough time has passed
			if time_since_death < respawn_delay:
				continue
			
			# Check if spawn position is off-camera (far from player)
			var distance_to_player = player_pos.distance_to(spawn_entry.position)
			if distance_to_player < respawn_min_distance:
				# Too close to player - wait longer
				continue
			
			# Respawn the enemy!
			_respawn_enemy(spawn_entry)
			to_remove.append(i)
		
		# Remove respawned entries (iterate backwards)
		for i in range(to_remove.size() - 1, -1, -1):
			spawn_list.remove_at(to_remove[i])


## Actually spawn a new enemy at the position
func _respawn_enemy(spawn_entry: Dictionary) -> void:
	if not enemies_container:
		return
	
	var scene_path = spawn_entry.scene_path
	if scene_path.is_empty():
		return
	
	# Use cached PackedScene (no runtime load stutter)
	var enemy_scene = spawn_entry.get("scene_resource")
	if not enemy_scene:
		# Fallback: find in original configs
		for config in original_enemy_configs:
			if config.scene_path == scene_path:
				enemy_scene = config.get("scene_resource")
				break
	
	if not enemy_scene:
		push_warning("No cached scene for: %s" % scene_path)
		return
	
	var new_enemy = enemy_scene.instantiate()
	new_enemy.name = spawn_entry.name + "_respawn"
	new_enemy.global_position = spawn_entry.position
	
	enemies_container.add_child(new_enemy)
	
	# Connect death signal for this new enemy
	if new_enemy.has_node("HealthComponent"):
		var health = new_enemy.get_node("HealthComponent")
		health.died.connect(_on_respawned_enemy_died.bind(new_enemy, spawn_entry))
	
	print("[Zone] Respawned enemy at %s" % spawn_entry.position)


## Called when a respawned enemy dies
func _on_respawned_enemy_died(enemy: Node, original_spawn: Dictionary) -> void:
	if not respawn_enabled:
		return
	
	# Re-record for another respawn cycle
	var spawn_entry = {
		"scene_path": original_spawn.scene_path,
		"scene_resource": original_spawn.get("scene_resource"),
		"position": original_spawn.position,
		"death_time": Time.get_ticks_msec() / 1000.0,
		"name": original_spawn.name
	}
	
	if not enemy_spawn_data.has(original_spawn.scene_path):
		enemy_spawn_data[original_spawn.scene_path] = []
	enemy_spawn_data[original_spawn.scene_path].append(spawn_entry)
