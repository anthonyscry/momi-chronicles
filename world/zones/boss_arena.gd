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
	
	# Don't respawn boss if already defeated
	if GameManager.boss_defeated:
		_show_empty_arena()
		return
	
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
	GameManager.game_complete = true
	
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
	
	# Show victory screen after a beat
	await get_tree().create_timer(1.5).timeout
	_show_victory_screen()

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
	DebugLogger.log_zone("Victory exit spawned — walk south to leave!")


func _show_empty_arena() -> void:
	# Boss already defeated — show peaceful arena with exit
	_unlock_doors()
	
	# Spawn exit immediately
	_spawn_victory_exit()
	
	# Show completion message
	var label = Label.new()
	label.name = "CompletionMsg"
	label.text = "The Raccoon King has been defeated.\nThe neighborhood is safe."
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(0.8, 0.85, 0.6))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(92, 70)
	label.size = Vector2(200, 40)
	add_child(label)
	
	if AudioManager:
		AudioManager.play_music("victory")
	
	Events.zone_entered.emit(zone_name)
	DebugLogger.log_zone("Boss arena re-entered — boss already defeated")


func _show_victory_screen() -> void:
	# Create CanvasLayer so it renders above everything
	var canvas = CanvasLayer.new()
	canvas.name = "VictoryScreen"
	canvas.layer = 10
	add_child(canvas)
	
	# Semi-transparent black background
	var bg = ColorRect.new()
	bg.name = "VictoryBG"
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0, 0, 0, 0.0)
	canvas.add_child(bg)
	
	# Fade in background
	var bg_tween = create_tween()
	bg_tween.tween_property(bg, "color:a", 0.75, 0.8)
	
	# Container for all victory content
	var container = VBoxContainer.new()
	container.name = "VictoryContent"
	container.position = Vector2(42, 20)
	container.size = Vector2(300, 176)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.modulate.a = 0.0
	canvas.add_child(container)
	
	# Title
	var title = Label.new()
	title.text = "THE NEIGHBORHOOD IS SAFE!"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(title)
	
	# Spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 8)
	container.add_child(spacer1)
	
	# Stats
	var player = get_tree().get_first_node_in_group("player")
	var level_text = "Level %d" % player.get_current_level() if player and player.has_method("get_current_level") else "Level ?"
	var coins_text = "%d Coins" % GameManager.coins
	
	var mini_boss_count: int = 0
	for key in GameManager.mini_bosses_defeated:
		if GameManager.mini_bosses_defeated[key]:
			mini_boss_count += 1
	
	var stats_text = "%s  •  %s  •  %d/4 Mini-Bosses" % [level_text, coins_text, mini_boss_count]
	var stats = Label.new()
	stats.text = stats_text
	stats.add_theme_font_size_override("font_size", 8)
	stats.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(stats)
	
	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 6)
	container.add_child(spacer2)
	
	# Flavor text
	var flavor = Label.new()
	flavor.text = "Momi and the Bulldog Squad\nprotected their neighborhood."
	flavor.add_theme_font_size_override("font_size", 8)
	flavor.add_theme_color_override("font_color", Color(0.7, 0.75, 0.65))
	flavor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(flavor)
	
	# Spacer
	var spacer3 = Control.new()
	spacer3.custom_minimum_size = Vector2(0, 12)
	container.add_child(spacer3)
	
	# Buttons container
	var btn_container = HBoxContainer.new()
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_child(btn_container)
	
	# Continue Playing button
	var continue_btn = Button.new()
	continue_btn.text = "Continue Playing"
	continue_btn.add_theme_font_size_override("font_size", 8)
	continue_btn.pressed.connect(_on_victory_continue)
	btn_container.add_child(continue_btn)
	
	# Spacer between buttons
	var btn_spacer = Control.new()
	btn_spacer.custom_minimum_size = Vector2(16, 0)
	btn_container.add_child(btn_spacer)
	
	# Return to Title button
	var title_btn = Button.new()
	title_btn.text = "Title Screen"
	title_btn.add_theme_font_size_override("font_size", 8)
	title_btn.pressed.connect(_on_victory_title)
	btn_container.add_child(title_btn)
	
	# Fade in content
	await get_tree().create_timer(0.5).timeout
	var content_tween = create_tween()
	content_tween.tween_property(container, "modulate:a", 1.0, 0.6)
	
	DebugLogger.log_zone("Victory screen displayed")


func _on_victory_continue() -> void:
	# Save and dismiss victory screen, show exit
	SaveManager.save_game()
	var victory_screen = get_node_or_null("VictoryScreen")
	if victory_screen:
		victory_screen.queue_free()
	_spawn_victory_exit()
	DebugLogger.log_zone("Player chose: Continue Playing")


func _on_victory_title() -> void:
	# Save and return to title screen
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://ui/menus/title_screen.tscn")
	DebugLogger.log_zone("Player chose: Title Screen")


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
