extends Node2D
class_name BossArena
## Boss arena zone - locked encounter with Raccoon King

const BOSS_SCENE = preload("res://characters/enemies/boss_raccoon_king.tscn")
const HEALTH_PICKUP_SCENE = preload("res://components/health/health_pickup.tscn")
const ZONE_EXIT_SCENE = preload("res://components/zone_exit/zone_exit.tscn")

# =============================================================================
# ARENA STATE
# =============================================================================

var boss: BossRaccoonKing = null
var doors_locked: bool = false
var boss_defeated: bool = false
var zone_name: String = "boss_arena"

@onready var boss_spawn_point: Marker2D = $BossSpawnPoint
@onready var player_spawn_point: Marker2D = $PlayerSpawnPoints/Default
@onready var entrance_door: StaticBody2D = $Doors/EntranceDoor
@onready var exit_blocker: StaticBody2D = $Doors/ExitBlocker

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Connect to boss events
	Events.boss_defeated.connect(_on_boss_defeated)
	
	# Position player and set camera limits for this small arena
	var player = get_tree().get_first_node_in_group("player")
	if player and player_spawn_point:
		player.global_position = player_spawn_point.global_position
	if player and player.has_method("set_camera_limits"):
		player.set_camera_limits(Rect2(Vector2.ZERO, Vector2(384, 216)))
	
	# Spawn boss
	_spawn_boss()
	
	# Lock doors after brief delay (let player enter)
	await get_tree().create_timer(1.0).timeout
	_lock_doors()
	
	# Play boss music
	if AudioManager:
		AudioManager.play_music("boss_fight")
	
	Events.zone_entered.emit(zone_name)

func _spawn_boss() -> void:
	boss = BOSS_SCENE.instantiate()
	var spawn_pos = boss_spawn_point.global_position if boss_spawn_point else Vector2(192, 80)
	boss.global_position = spawn_pos
	add_child(boss)

func _lock_doors() -> void:
	doors_locked = true
	
	# Enable door collisions
	if entrance_door:
		entrance_door.set_collision_layer_value(1, true)
		_animate_door_close(entrance_door)
	if exit_blocker:
		exit_blocker.set_collision_layer_value(1, true)
	
	# Visual feedback
	EffectsManager.screen_shake(3.0, 0.2)

func _unlock_doors() -> void:
	doors_locked = false
	
	# Disable door collisions
	if entrance_door:
		entrance_door.set_collision_layer_value(1, false)
		_animate_door_open(entrance_door)
	if exit_blocker:
		exit_blocker.set_collision_layer_value(1, false)

func _on_boss_defeated(_boss: Node) -> void:
	boss_defeated = true
	
	# Dramatic pause
	Engine.time_scale = 0.3
	await get_tree().create_timer(0.5 * 0.3).timeout
	Engine.time_scale = 1.0
	
	# Unlock doors
	_unlock_doors()
	
	# Victory music
	if AudioManager:
		AudioManager.play_music("victory")
	
	# Spawn rewards
	_spawn_victory_rewards()
	
	# Spawn exit back to sewers
	_spawn_victory_exit()

func _spawn_victory_rewards() -> void:
	# Spawn multiple health pickups
	for i in range(3):
		var pickup = HEALTH_PICKUP_SCENE.instantiate()
		var spawn_pos = boss_spawn_point.global_position if boss_spawn_point else Vector2(192, 80)
		pickup.global_position = spawn_pos + Vector2(randf_range(-30, 30), randf_range(-30, 30))
		add_child(pickup)

func _spawn_victory_exit() -> void:
	# Create exit at the entrance door position (bottom of arena)
	var exit = ZONE_EXIT_SCENE.instantiate()
	exit.exit_id = "victory_exit"
	exit.target_zone = "neighborhood"
	exit.target_spawn = "default"
	exit.require_interaction = false
	exit.position = Vector2(192, 200)  # Entrance door position
	add_child(exit)
	print("[BossArena] Victory exit spawned — walk south to leave!")


# =============================================================================
# DOOR ANIMATIONS
# =============================================================================

func _animate_door_close(door: Node2D) -> void:
	if not door:
		return
	
	# Flash then darken
	door.modulate = Color(1.5, 1, 1)
	var tween = create_tween()
	tween.tween_property(door, "modulate", Color(0.5, 0.4, 0.4), 0.3)

func _animate_door_open(door: Node2D) -> void:
	if not door:
		return
	
	var tween = create_tween()
	tween.tween_property(door, "modulate", Color(1, 1, 1), 0.3)
