extends BaseZone
## The backyard zone - a more confined area with tougher enemies.
## Connected to the neighborhood via an alley.

const CROW_MATRIARCH_SCENE = preload("res://characters/enemies/crow_matriarch.tscn")
const QuestItemPickupScript = preload("res://components/quest_item_pickup/quest_item_pickup.gd")

# =============================================================================
# SPAWN POINTS
# =============================================================================

## Named spawn points in this zone
var spawn_points: Dictionary = {
	"default": Vector2(60, 140),
	"from_neighborhood": Vector2(60, 140),
	"center": Vector2(192, 108)
}

# =============================================================================
# LIFECYCLE
# =============================================================================

func _setup_zone() -> void:
	zone_id = "backyard"
	
	# Build mini-boss trigger (Crow Matriarch)
	_build_mini_boss_trigger()
	
	# Build quest item pickups
	_build_quest_pickups()
	
	# Check if we have a pending spawn from zone transition
	var pending_spawn = GameManager.get_pending_spawn()
	if not pending_spawn.is_empty() and spawn_points.has(pending_spawn):
		spawn_player_at(spawn_points[pending_spawn])
	elif spawn_points.has("default"):
		spawn_player_at(spawn_points["default"])

# =============================================================================
# MINI-BOSS TRIGGER (Crow Matriarch)
# =============================================================================

var _crow_matriarch_spawned: bool = false

func _build_mini_boss_trigger() -> void:
	# Check if already defeated
	if GameManager.mini_bosses_defeated.get("crow_matriarch", false):
		return
	
	var trigger_pos = Vector2(192, 108)  # Center of backyard zone
	
	# Warning decor - dark feather circle on ground
	var warning = Polygon2D.new()
	warning.name = "MiniBossWarning"
	var points: PackedVector2Array = []
	for i in range(8):
		var angle = i * TAU / 8.0
		points.append(Vector2(cos(angle), sin(angle)) * 18.0)
	warning.polygon = points
	warning.color = Color(0.2, 0.15, 0.3, 0.3)  # Faint dark purple
	warning.position = trigger_pos
	warning.z_index = 0
	add_child(warning)
	
	# Trigger Area2D
	var trigger = Area2D.new()
	trigger.name = "CrowMatriarchTrigger"
	trigger.collision_layer = 0
	trigger.collision_mask = 2
	trigger.position = trigger_pos
	add_child(trigger)
	
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(70, 50)
	shape.shape = rect
	trigger.add_child(shape)
	
	trigger.body_entered.connect(_on_crow_matriarch_trigger)

func _on_crow_matriarch_trigger(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _crow_matriarch_spawned:
		return
	if GameManager.mini_bosses_defeated.get("crow_matriarch", false):
		return
	
	_crow_matriarch_spawned = true
	
	var boss = CROW_MATRIARCH_SCENE.instantiate()
	boss.global_position = Vector2(192, 90)  # Slightly above center
	add_child(boss)
	
	# Remove trigger and warning
	var trigger_node = get_node_or_null("CrowMatriarchTrigger")
	if trigger_node:
		trigger_node.queue_free()
	var warning_node = get_node_or_null("MiniBossWarning")
	if warning_node:
		var tween = create_tween()
		tween.tween_property(warning_node, "modulate:a", 0.0, 0.5)
		tween.tween_callback(warning_node.queue_free)
	
	# Play boss music
	if AudioManager.has_method("play_music"):
		AudioManager.play_music("boss_fight_b")


# =============================================================================
# QUEST ITEM PICKUPS
# =============================================================================

func _build_quest_pickups() -> void:
	_build_lost_ball_pickup()

func _build_lost_ball_pickup() -> void:
	# Lost ball for "Find the Lost Ball" quest (Kids Gang fetch quest)
	# Placed in the backyard near the back area, away from the main path
	var pickup = Area2D.new()
	pickup.set_script(QuestItemPickupScript)
	pickup.name = "LostBallPickup"
	pickup.item_id = "lost_ball"
	pickup.quest_id = "find_lost_ball"  # Only visible when quest is active
	pickup.pickup_color = Color(0.9, 0.3, 0.3)  # Red ball
	pickup.label_text = "Ball"
	pickup.position = Vector2(300, 80)  # Back-right area of backyard
	add_child(pickup)
